
##################### CA K8s Deployment ###########################
# Documentation for CA for aws: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md

# The following tf code is an equivalent of (with some updates):
# https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
resource "kubernetes_cluster_role" "cluster_autoscaler" {
  metadata {
    name = "cluster-autoscaler"
  }

  rule {
    api_groups = [""]
    resources  = ["events", "endpoints"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups     = [""]
    resources      = ["endpoints"]
    resource_names = ["cluster-autoscaler"]
    verbs          = ["get", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list", "get", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "services", "replicationcontrollers", "persistentvolumeclaims", "persistentvolumes"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["watch", "list"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "csinodes", "csidrivers", "csistoragecapacities"]
    verbs      = ["watch", "list", "get"]
  }

  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "patch"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create"]
  }

  rule {
    api_groups     = ["coordination.k8s.io"]
    resources      = ["leases"]
    resource_names = ["cluster-autoscaler"]
    verbs          = ["get", "update"]
  }
}

resource "kubernetes_role" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "list", "watch"]
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
    verbs          = ["delete", "get", "update", "watch"]
  }

}

resource "kubernetes_role_binding" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }


  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.cluster_autoscaler.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cluster_autoscaler.metadata[0].name
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "cluster_autoscaler" {
  metadata {
    name = "cluster-autoscaler"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_autoscaler.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cluster_autoscaler.metadata[0].name
    namespace = "kube-system"
  }
}

resource "kubernetes_service_account" "cluster_autoscaler" {
  automount_service_account_token = true
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.cluster_autoscaler
    }
  }

}

resource "kubernetes_deployment" "cluster_autoscaler" {
  wait_for_rollout = true
  depends_on = [
    # Ensures the deployment only starts after the services account has all the required perms
    kubernetes_role_binding.cluster_autoscaler,
    kubernetes_cluster_role_binding.cluster_autoscaler
  ]
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "cluster-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          app = "cluster-autoscaler"
        }
      }

      spec {

        priority_class_name = "system-cluster-critical"

        security_context {
          run_as_non_root = true
          run_as_user     = 65534
          fs_group        = 65534
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        volume {
          name = "ssl-certs"
          host_path {
            path = "/etc/ssl/certs/ca-bundle.crt"
          }
        }

        toleration {
          key      = "autoscaler"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        node_selector = {
          autoscaler                        = "true"
          (var.nodegroup_node_selector_key) = var.cluster_autoscaler_nodegroup
        }

        container {
          name = "cluster-autoscaler"
          # update autoscaler version if needed: https://github.com/kubernetes/autoscaler/releases
          # cluster-autoscaler:v1.26.1 is used because that was the latest stable version available
          # Although the latest version offered right now is 1.28.X but the image for them is not available.
          image = "k8s.gcr.io/autoscaling/cluster-autoscaler:v1.26.1"

          command = [
            # TODO: Consider tuning the scale up and scale down buffer period
            # Refer the documentation mentioned at the top of this section
            # for information on the args
            "./cluster-autoscaler",
            "--v=4",
            "--stderrthreshold=info",
            "--cloud-provider=${var.cluster_autoscaler_cloud_provider}",
            "--skip-nodes-with-local-storage=false",
            "--expander=least-waste",
            "--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${var.cluster_name}"
          ]

          resources {
            limits = {
              cpu    = "200m"
              memory = "500Mi"
            }

            requests = {
              cpu    = "100m"
              memory = "300Mi"
            }
          }

          volume_mount {
            mount_path = "/etc/ssl/certs/ca-certificates.crt"
            name       = "ssl-certs"
            read_only  = true
          }

        }

        service_account_name = kubernetes_service_account.cluster_autoscaler.metadata[0].name
      }
    }
  }
}
