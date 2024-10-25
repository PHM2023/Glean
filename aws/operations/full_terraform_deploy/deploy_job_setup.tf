locals {
  deploy_jobs_namespace          = "deploy-jobs"
  deploy_job_k8s_service_account = "deploy-job-runner"
}

data "aws_secretsmanager_secret" "ipjc_auth_token" {
  name = "ipjc_auth_token"
}

resource "aws_iam_policy" "deploy_job_policy" {
  name = "GleanDeployJobPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Deploy job runner needs access to describe the rds instances and set various values based on their
        # configuration
        Effect   = "Allow",
        Action   = "rds:DescribeDBInstances",
        Resource = "arn:aws:rds:${var.region}:${var.account_id}:db:*"
      },
      {
        # Deploy job runner needs to tag this role (which is created after the first RDS instance is set up) to
        # propagate the default tags fully
        Effect   = "Allow",
        Action   = "iam:TagRole",
        Resource = "arn:aws:iam::${var.account_id}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Resource = data.aws_secretsmanager_secret.ipjc_auth_token.arn
      },
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListNodegroups",
          "eks:TagResource"
        ]
        Resource = "arn:aws:eks:${var.region}:${var.account_id}:cluster/${module.eks_phase_1.cluster_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeNodegroup"
        ]
        Resource = "arn:aws:eks:${var.region}:${var.account_id}:nodegroup/${module.eks_phase_1.cluster_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:DescribeImages"
        ]
        # Deploy jobs should only need to look at images from the Glean central ECR repos
        Resource = "arn:aws:ecr:us-east-1:518642952506:repository/*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeSubnets"
        ]
        Resource = "*",
        Condition = {
          "StringEquals" : {
            "ec2:Region" : var.region
          }
        }
      },
      {
        # For reading storage resources in Glean's central s3 buckets
        Effect = "Allow",
        Action = [
          "sts:AssumeRole",
        ]
        Resource = ["arn:aws:iam::518642952506:role/CentralStorageSourcesReader"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectAttributes",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${module.s3.elastic_plugin_bucket}/*",
          "arn:aws:s3:::${module.s3.flink_artifacts_bucket}/*",
          "arn:aws:s3:::${module.s3.dataflow_bucket}/*",
          "arn:aws:s3:::${module.s3.general_query_metadata_bucket}/*",
          "arn:aws:s3:::${module.s3.upgrade_operations_bucket}/*",
          "arn:aws:s3:::${module.s3.elastic_plugin_bucket}/*"
        ]
      },
      {
        "Action" : [
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucket",
          "s3:ListBucketVersions"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${module.s3.elastic_plugin_bucket}",
          "arn:aws:s3:::${module.s3.flink_artifacts_bucket}",
          "arn:aws:s3:::${module.s3.dataflow_bucket}",
          "arn:aws:s3:::${module.s3.general_query_metadata_bucket}",
          "arn:aws:s3:::${module.s3.upgrade_operations_bucket}",
          "arn:aws:s3:::${module.s3.elastic_plugin_bucket}"
        ]
      },
      # NOTE: only let the deploy job runner create nodegroups for opensearch, nothing else
      # TODO: remove this after the deploy job runner no longer needs to create nodegroups
      {
        "Action" : [
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "ec2:CreateLaunchTemplate",
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            # If you're trying to change this, you're doing something wrong. Please put your nodegroups in terraform
            "aws:RequestTag/Name" : "elastic-node-pool-?-launch-template"
          }
        }
      },
      {
        "Action" : [
          "ec2:CreateLaunchTemplate",
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            # If you're trying to change this, you're doing something wrong. Please put your nodegroups in terraform
            "aws:RequestTag/flink-nodegroup" : "true"
          }
        }
      },
      {
        "Action" : [
          "ec2:CreateLaunchTemplateVersion"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            # If you're trying to change this, you're doing something wrong. Please put your nodegroups in terraform
            "aws:ResourceTag/Name" : "elastic-node-pool-?-launch-template"
          }
        }
      },
      {
        "Action" : [
          "ec2:CreateLaunchTemplateVersion"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
        # We also can't scope this down much more because sometimes the job runner may have to update an old nodegroups
        # template (which won't have the required tags).
      },
      {
        "Action" : [
          "ec2:RunInstances",
          "ec2:CreateTags"
        ],
        "Effect" : "Allow",
        # unfortunately it's hard to scope this down any further
        "Resource" : "*",
      },
      {
        "Action" : "autoscaling:CreateOrUpdateTags",
        "Effect" : "Allow",
        # Unfortunately it's a bit hard to scope this one down since the flink nodegroups are not logically named, and
        # that's the only condition key we can attach to this to keep it scoped to a specific set of nodegroups.
        "Resource" : "*",
      },
      {
        "Action" : [
          "eks:DeleteNodegroup",
          "eks:UpdateNodegroupVersion",
          "eks:UpdateNodegroupConfig"
        ],
        "Effect" : "Allow",
        "Resource" : [
          # If you're trying to change this, you're doing something wrong. Please put your nodegroups in terraform
          "arn:aws:eks:${var.region}:${var.account_id}:nodegroup/glean-cluster/elastic-node-pool-1/*",
          "arn:aws:eks:${var.region}:${var.account_id}:nodegroup/glean-cluster/elastic-node-pool-2/*"
        ]
      },
      {
        "Action" : [
          "eks:DeleteNodegroup",
          "eks:UpdateNodegroupVersion",
          "eks:UpdateNodegroupConfig"
        ],
        "Effect" : "Allow",
        "Resource" : [
          # If you're trying to change this, you're doing something wrong. Please put your nodegroups in terraform
          "arn:aws:eks:${var.region}:${var.account_id}:nodegroup/glean-cluster/*"
        ],
        "Condition" : {
          "StringEquals" : {
            # If you're trying to change this, you're doing something wrong. Please put your nodegroups in terraform
            "aws:ResourceTag/flink-nodegroup" : "true"
          }
        }
      },
      {
        "Action" : [
          "eks:CreateNodegroup",
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:eks:${var.region}:${var.account_id}:cluster/${module.eks_phase_1.cluster_name}"
        "Condition" : {
          "StringLike" : {
            # If you're trying to change this, you're doing something wrong. Please put your nodegroups in terraform
            "aws:RequestTag/Name" : "elastic-node-pool-?"
          }
        }
      },
      {
        "Action" : [
          "eks:CreateNodegroup",
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:eks:${var.region}:${var.account_id}:cluster/${module.eks_phase_1.cluster_name}"
        "Condition" : {
          "StringEquals" : {
            # If you're trying to change this, you're doing something wrong. Please put your nodegroups in terraform
            "aws:RequestTag/flink-nodegroup" : "true"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : module.eks_phase_1.worker_node_arn,
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : "eks.amazonaws.com"
          }
        }
      },
      {
        "Action" : [
          "iam:GetRole",
          "iam:ListAttachedRolePolicies"
        ],
        "Effect" : "Allow",
        "Resource" : [
          # These are all sadly needed for eks:CreateNodegroup to work
          module.eks_phase_1.worker_node_arn,
          module.eks_phase_1.eks_cluster_role_arn,
          "arn:aws:iam::${var.account_id}:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup"
        ]
      },
    ]
  })
}

resource "aws_iam_role" "deploy_job_role" {
  name                 = "GleanDeployJobRunner"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${module.eks_phase_1.oidc_provider}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${module.eks_phase_1.oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks_phase_1.oidc_provider}:sub" : "system:serviceaccount:${local.deploy_jobs_namespace}:${local.deploy_job_k8s_service_account}"
          }
        }
      }
    ]
  })
  managed_policy_arns = [
    aws_iam_policy.deploy_job_policy.arn,
    module.s3.config_bucket_reader_policy_arn,
    module.s3.config_bucket_writer_policy_arn,
    module.s3.elastic_plugin_bucket_reader_policy_arn,
    module.eks_phase_1.cloudwatch_logs_policy_arn,
    module.sql.root_sql_access_policy_arn,
    module.sql.sql_connect_policy_arn,
    module.kms.ipjc_signing_key_sign_policy_arn,
    module.kms.secret_store_cryptor_policy_arn
  ]
}