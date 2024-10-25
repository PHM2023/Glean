resource "kubernetes_config_map_v1" "redis_config" {
  metadata {
    name = "redis-config"
  }
  data = {
    "redis.conf" = <<EOF
# https://raw.githubusercontent.com/redis/redis/7.2/redis.conf
dir /etc/redis/data/
EOF
  }
}

resource "kubernetes_stateful_set_v1" "redis" {
  metadata {
    name = "redis-deployment-statefulset"
  }
  spec {
    service_name = "redis-service"
    replicas     = "1"
    selector {
      match_labels = {
        app = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        automount_service_account_token = false
        enable_service_links            = false
        # TODO: move redis to new nodegroups and remove this
        node_selector = {
          (var.redis_nodegroup_selector_key) : var.redis_nodegroup_name
        }
        container {
          name  = "redis"
          image = var.redis_image_uri
          command = [
            "redis-server",
            "/etc/redis/redis.conf"
          ]
          liveness_probe {
            initial_delay_seconds = var.redis_k8s_configs.initial_delay_seconds
            exec {
              command = ["redis-cli", "ping"]
            }
            period_seconds    = var.redis_k8s_configs.liveness_check_period_seconds
            timeout_seconds   = var.redis_k8s_configs.liveness_check_timeout_seconds
            failure_threshold = 2
          }
          port {
            container_port = 6379
            protocol       = "TCP"
          }
          volume_mount {
            mount_path = "/etc/redis/data/"
            name       = "redis-data"
          }
          volume_mount {
            mount_path = "/etc/redis/redis.conf"
            name       = "config-volume"
            sub_path   = "redis.conf"
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
              value = "redis"
            }
          }
          resources {
            limits = {
              cpu    = "${var.redis_k8s_configs.cpu_limit}m"
              memory = "${var.redis_k8s_configs.memory_limit_gi}Gi"
            }
            requests = {
              cpu    = "${var.redis_k8s_configs.cpu_request}m"
              memory = "${var.redis_k8s_configs.memory_request_gi}Gi"
            }
          }
        }
        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map_v1.redis_config.metadata[0].name
          }
        }
        toleration {
          key      = "glean-app"
          operator = "Equal"
          value    = "True"
          effect   = "NoSchedule"
        }
        # Redis can be placed on the memory-based nodegroups, so it must also tolerate their taints
        dynamic "toleration" {
          for_each = var.memory_based_nodegroup_node_selector_info.tolerations
          content {
            key      = toleration.value.key
            operator = toleration.value.operator
            value    = toleration.value.value
            effect   = toleration.value.effect
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "redis-data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "${var.redis_k8s_configs.storage_request_gi}Gi"
          }
        }
        volume_mode        = "Filesystem"
        storage_class_name = var.storage_class_name
      }
    }
  }
  lifecycle {
    # We have to ignore this field because otherwise terraform will try to automatically set the namespace to
    # 'default' which will trigger a recreation of the statefulset:
    # https://github.com/hashicorp/terraform-provider-kubernetes/issues/691
    ignore_changes = [spec[0].volume_claim_template[0].metadata[0].namespace]
  }
  depends_on = [
    # Redis may not have a dedicated nodegroup, so we need the autoscaler to be up
    kubernetes_deployment.cluster_autoscaler
  ]
}

resource "kubernetes_service_v1" "redis" {
  # Redis needs a private lb, so the lb controller must be up first
  depends_on = [var.k8s_service_lb_controller_ids]
  metadata {
    name = "redis-service"
    annotations = merge(var.private_load_balancer_via_k8s_service_info.common_annotations, {
      (var.private_load_balancer_via_k8s_service_info.load_balancer_name_key) : "redis-internal-lb"
    })
  }
  spec {
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = "6379"
    }
    selector = {
      app = kubernetes_stateful_set_v1.redis.spec[0].template[0].metadata[0].labels["app"]
    }
    load_balancer_source_ranges = ["10.0.0.0/8"]
    load_balancer_class         = var.private_load_balancer_via_k8s_service_info.load_balancer_class_name
  }
}