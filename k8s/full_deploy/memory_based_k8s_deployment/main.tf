resource "kubernetes_deployment_v1" "deployment" {
  wait_for_rollout = true
  metadata {
    name = "${var.app}-deployment"
  }
  timeouts {
    create = "25m"
    update = "25m"
  }
  spec {
    progress_deadline_seconds = var.progress_deadline_seconds
    replicas                  = tostring(var.min_instances)
    selector {
      match_labels = {
        app = var.app
      }
    }
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "100%"
        max_unavailable = "0"
      }
    }
    template {
      metadata {
        labels = {
          app       = var.app
          glean-app = "True"
        }
      }
      spec {
        dynamic "volume" {
          content {
            empty_dir {}
            name = "file-volume"
          }
          for_each = var.include_user_local_lib_volume ? [1] : []
        }
        toleration {
          key      = "glean-app"
          operator = "Equal"
          value    = "True"
          effect   = "NoSchedule"
        }
        dynamic "toleration" {
          for_each = var.additional_tolerations
          content {
            key      = toleration.value.key
            operator = toleration.value.operator
            value    = toleration.value.value
            effect   = toleration.value.effect
          }
        }
        # TODO: add support for affinity among a range of groups here
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = var.required_nodegroup_node_selector_key
                  operator = "In"
                  values   = [var.required_nodegroup_node_selector_value]
                }
              }
            }
            dynamic "preferred_during_scheduling_ignored_during_execution" {
              for_each = var.preferential_node_groups
              content {
                weight = preferred_during_scheduling_ignored_during_execution.value.weight
                preference {
                  match_expressions {
                    key = preferred_during_scheduling_ignored_during_execution.value.node_selector_key
                    values = [
                      preferred_during_scheduling_ignored_during_execution.value.node_selector_value
                    ]
                    operator = "In"
                  }
                }
              }
            }
          }
        }
        service_account_name             = var.k8s_service_account
        termination_grace_period_seconds = var.termination_grace_period_seconds
        container {
          name              = var.app
          image             = var.image_uri
          image_pull_policy = "Always"
          readiness_probe {
            http_get {
              path = var.readiness_check_path
              port = "8080"
            }
            timeout_seconds   = var.liveness_timeout_seconds
            period_seconds    = var.liveness_period_seconds
            failure_threshold = var.liveness_failure_threshold
          }
          liveness_probe {
            http_get {
              path = var.liveness_check_path
              port = "8080"
            }
            timeout_seconds   = var.liveness_timeout_seconds
            period_seconds    = var.liveness_period_seconds
            failure_threshold = var.liveness_failure_threshold
          }
          startup_probe {
            http_get {
              path = var.startup_check_path
              port = "8080"
            }
            timeout_seconds   = var.startup_timeout_seconds
            period_seconds    = var.startup_period_seconds
            failure_threshold = var.startup_failure_threshold
          }
          port {
            container_port = 8080
            protocol       = "TCP"
          }
          env {
            name  = "ROLLOUT_ID"
            value = var.rollout_id
          }
          dynamic "env" {
            for_each = var.default_env_vars
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env" {
            for_each = var.referential_env_vars
            content {
              name = env.key
              value_from {
                field_ref {
                  field_path = env.value
                }
              }
            }
          }
          dynamic "env" {
            for_each = toset(var.app_name_env_vars)
            content {
              name  = env.key
              value = var.app
            }
          }
          dynamic "volume_mount" {
            for_each = var.volume_mounts
            content {
              mount_path = volume_mount.value.mount_path
              read_only  = volume_mount.value.read_only
              name       = volume_mount.value.name
            }
          }
          resources {
            limits = {
              cpu    = "${var.cpu_limit}m"
              memory = "${var.memory_limit}Gi"
            }
            requests = {
              cpu    = "${var.cpu_request}m"
              memory = "${var.memory_request}Gi"
            }
          }
          dynamic "lifecycle" {
            for_each = var.lifecycle_prestop_command != null ? [1] : []
            content {
              pre_stop {
                exec {
                  command = var.lifecycle_prestop_command
                }
              }
            }
          }
        }

        dynamic "volume" {
          for_each = var.empty_dir_volumes
          content {
            name = volume.value.name
            empty_dir {}
          }
        }
      }
    }
  }
  lifecycle {
    # Ensures terraform doesn't overwrite the autoscaler
    ignore_changes = [spec[0].replicas]
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "hpa" {
  metadata {
    name = "${var.app}-hpa"
  }
  spec {
    min_replicas = var.min_instances
    max_replicas = var.max_instances
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.deployment.metadata[0].name
    }
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = tostring(var.autoscaling_max_cpu_percent)
        }
      }
    }
    behavior {
      scale_down {
        stabilization_window_seconds = var.scale_down_stabilization_window_seconds
        policy {
          # Default scale-down policy
          period_seconds = 15
          type           = "Percent"
          value          = 100
        }
        select_policy = "Max"
      }
      scale_up {
        stabilization_window_seconds = 300
        policy {
          # Default scale-up percent policy
          period_seconds = 15
          type           = "Percent"
          value          = 100
        }
        policy {
          # Default scale-up pods policy
          period_seconds = 15
          type           = "Pods"
          value          = 4
        }
        select_policy = "Max"
      }
    }
  }
}

# We have to use the _v1 version here since the original version doesn't work with imports
resource "kubernetes_pod_disruption_budget_v1" "pdb" {
  metadata {
    name = "${var.app}-pdb"
  }
  spec {
    min_available = tostring(var.min_instances)
    selector {
      match_labels = {
        app = kubernetes_deployment_v1.deployment.spec[0].template[0].metadata[0].labels.app
      }
    }
  }
}


resource "kubernetes_service_v1" "service" {
  metadata {
    name = var.service_name_override != null ? var.service_name_override : "${var.app}-service"
    labels = {
      app = var.app
    }
    annotations = var.use_lb_service ? merge(var.private_load_balancer_via_k8s_service_info.common_annotations, {
      (var.private_load_balancer_via_k8s_service_info.load_balancer_name_key) : "${var.app}-internal-lb"
    }) : {}
  }
  spec {
    # Note: we have to explicitly set some of these so terraform doesn't detect any drift when deployed in eks
    type = var.use_lb_service ? "LoadBalancer" : "NodePort"
    # Cluster external traffic policy can only be used if the service type is `LoadBalancer` or `NodePort`
    external_traffic_policy = "Cluster"
    session_affinity        = "None"
    ip_families = [
      "IPv4"
    ]
    ip_family_policy                  = "SingleStack"
    allocate_load_balancer_node_ports = true
    load_balancer_class               = var.use_lb_service ? var.private_load_balancer_via_k8s_service_info.load_balancer_class_name : null
    internal_traffic_policy           = "Cluster"
    selector = {
      app = kubernetes_deployment_v1.deployment.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = "8080"
    }
  }
  wait_for_load_balancer = var.use_lb_service
}
