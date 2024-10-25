
locals {
  additional_k8s_role_entries = [
    for role_arn in var.additional_k8s_admin_role_arns :
    {
      rolearn  = role_arn
      username = "user-${element(split("/", role_arn), length(split("/", role_arn)) - 1)}"
      groups = [
        "system:masters"
      ]
    }
  ]
}


resource "kubernetes_config_map_v1_data" "aws_auth_config_map" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    "mapRoles" = yamlencode(concat([
      {
        rolearn  = var.eks_worker_node_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      },
      {
        rolearn  = var.self_hosted_airflow_nodes_iam_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      },
      {
        rolearn  = var.codebuild_role_arn
        username = "codebuild"
        groups = [
          "system:masters"
        ]
      },
      {
        rolearn  = var.cron_helper_role_arn
        username = "cron-helper:{{SessionName}}"
        groups = [
          "system:masters"
        ]
      },
      {
        rolearn  = var.flink_invoker_role_arn
        username = "flink-invoker-ksa:{{SessionName}}"
        groups = [
          "system:masters"
        ]
      },
      {
        rolearn  = var.glean_viewer_role_arn
        username = "glean-viewer:{{SessionName}}"
        groups = [
          "glean-viewer-group"
        ]
      },
      {
        rolearn  = var.gmp_collector_role_arn
        username = "gmp-collector:{{SessionName}}"
        groups = [
          "system:masters"
        ]
      },
      {
        # TODO: use tighter permissions than system:masters
        rolearn  = "arn:aws:iam::${var.account_id}:role/UpgradeOpensearchRole"
        username = "upgrade_opensearch"
        groups = [
          "system:masters"
        ]
      },
      {
        rolearn  = "arn:aws:iam::${var.account_id}:role/GleanAdmin"
        username = "user-GleanAdmin"
        groups = [
          "system:masters"
        ]
      },
      {
        rolearn  = "arn:aws:iam::${var.account_id}:role/flink-direct-memory-oom-detection"
        username = "flink-direct-memory-oom-detection"
        groups = [
          "system:masters"
        ]
      },
      {
        rolearn  = var.deploy_job_role_arn
        username = "deploy-job-runner"
        groups = [
          "system:masters"
        ]
      },
    ], local.additional_k8s_role_entries))
  }
  force = true
}

# Allows the glean-viewer role to view k8s resources in the EKS console
resource "kubernetes_cluster_role_binding_v1" "connector_role_binding" {
  metadata {
    name = "glean-viewer-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind      = "Group"
    name      = "glean-viewer-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

# the default `view` role above does not grant access to view nodes, so we need to add that ourselves
resource "kubernetes_cluster_role_v1" "node_viewer_role" {
  metadata {
    name = "glean-node-viewer"
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "glean_node_viewer_role_binding" {
  metadata {
    name = "glean-node-viewer-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.node_viewer_role.metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "glean-viewer-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

