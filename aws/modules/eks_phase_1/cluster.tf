# IAM Role/attachments for nodes

#####################  EKS worker node  ##################################
resource "aws_iam_role" "eks_worker_node" {
  name                 = "eksWorkerNode"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    data.aws_iam_policy.cloudwatch_agent_policy.arn,
    data.aws_iam_policy.ebs_csi_driver_policy.arn
  ]
}


data "aws_iam_policy" "cloudwatch_agent_policy" {
  name = "CloudWatchAgentServerPolicy"
}

data "aws_iam_policy" "ebs_csi_driver_policy" {
  name = "AmazonEBSCSIDriverPolicy"
}

## The following instance profile will be supplied when nodegroups are launched
resource "aws_iam_instance_profile" "eks_worker_node" {
  name = "eksWorkerNode"
  role = aws_iam_role.eks_worker_node.name
}

##################  EKS cluster role  ##################################
data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name                 = "eksClusterRole"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy   = data.aws_iam_policy_document.eks_assume_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]
}


##########################  EKS Cluster  ##################################


resource "aws_eks_cluster" "glean_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [var.public_subnet_id, var.eks_private_subnet_id]

    endpoint_public_access  = false
    endpoint_private_access = true
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.secrets_encryption_kms_key_arn
    }
  }


  enabled_cluster_log_types = ["api", "audit", "controllerManager", "scheduler"]


  lifecycle {
    prevent_destroy = true
  }

  depends_on = [aws_cloudwatch_log_group.cluster_audit_logs]
}

locals {
  oidc_provider = replace(aws_eks_cluster.glean_cluster.identity[0].oidc[0].issuer, "https://", "")
}


##########################  OIDC Provider  ##################################
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = aws_eks_cluster.glean_cluster.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.oidc_root_ca.certificates[0].sha1_fingerprint
  ]

  depends_on = [
    aws_eks_cluster.glean_cluster
  ]
}

data "tls_certificate" "oidc_root_ca" {
  url = aws_eks_cluster.glean_cluster.identity[0].oidc[0].issuer
}

###############################################################################

## Security group rules for allowing eks access from the private lambdas


resource "aws_vpc_security_group_ingress_rule" "eks_lambda_ingress_allow" {
  security_group_id            = aws_eks_cluster.glean_cluster.vpc_config[0].cluster_security_group_id
  description                  = "For allowing lambda connections"
  referenced_security_group_id = var.lambda_security_group_id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}


####################### Allow Codebuild Access To Eks Control Plane ################################

resource "aws_security_group_rule" "allow_codebuild_access" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = var.codebuild_security_group_id

  security_group_id = aws_eks_cluster.glean_cluster.vpc_config[0].cluster_security_group_id
}
###############################################################################
# This ensures that all the ebs volumes created henceforth are encrypted by default
resource "aws_ebs_encryption_by_default" "enable_ebs_encryption" {
  enabled = true
}

module "core_add_on_node_group" {
  source          = "../eks_node_group_v2"
  node_group_name = "core-addon-node-group"
  cluster_name    = aws_eks_cluster.glean_cluster.name
  node_role_arn   = aws_iam_role.eks_worker_node.arn
  subnet_ids      = [var.eks_private_subnet_id]
  default_tags    = var.default_tags
  min_size        = 1
  max_size        = 4
  desired_size    = 1
  # TODO: this is unfortunate but we have to set these next two to null so terraform won't detect any drift
  #  between the nodegroups/launch templates. If we don't do this, the new nodegroup module will force both
  #  nodegroup and template to update, and the nodegroup update will fail because EKS has a restriction where
  #  you cannot use a launch template to define the instance_type if you specified the instance type when you
  #  originally created the nodegroup. The disk size also needs to be null so the template doesn't get
  #  updated unnecessarily (we can use the same specs that we're already using).
  #  To fix this, we need to create new groups that the addons can use, migrate them to that group, then delete
  #  this one altogether. We can do that at some point in the future. For now, this will suffice
  instance_type = null
  disk_size_gi  = null
  depends_on = [
    aws_ebs_encryption_by_default.enable_ebs_encryption,
    # Node group creation depends on these addons
    aws_eks_addon.vpc_cni,
    aws_eks_addon.kube_proxy
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.glean_cluster.name
  addon_name   = "vpc-cni"
}

#resource "aws_eks_addon" "efs_csi" {
#  cluster_name = aws_eks_cluster.glean_cluster.name
#  addon_name   = "efs-csi"
#  depends_on = [aws_eks_node_group.core_add_on_node_group]
#}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.glean_cluster.name
  addon_name   = "coredns"
  depends_on   = [module.core_add_on_node_group]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.glean_cluster.name
  addon_name   = "kube-proxy"
}


resource "aws_cloudwatch_log_group" "cluster_audit_logs" {
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/glean-cluster/cluster"
  retention_in_days = 30
}


resource "aws_iam_role" "ebs_csi_role" {
  name                 = "ebsCsiRole"
  permissions_boundary = var.iam_permissions_boundary_arn
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${local.oidc_provider}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.oidc_provider}:aud" : "sts.amazonaws.com",
            # ebs-csi-controller-sa is the kubernetes service account that will be automatically created for the addon
            "${local.oidc_provider}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}


# Needed to create persistent volumes for stateful sets
resource "aws_eks_addon" "ebs_csi_driver" {
  addon_name               = "aws-ebs-csi-driver"
  cluster_name             = aws_eks_cluster.glean_cluster.name
  service_account_role_arn = aws_iam_role.ebs_csi_role.arn
  depends_on               = [module.core_add_on_node_group]
}
