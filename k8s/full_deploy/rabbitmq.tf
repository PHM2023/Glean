
resource "kubernetes_secret_v1" "rabbitmq_certs" {
  metadata {
    name = "rabbitmq-certs"
  }
  binary_data = {
    "tls.crt" = filebase64(data.external.rabbitmq_secret_gen.result["server_cert"])
    "tls.key" = filebase64(data.external.rabbitmq_secret_gen.result["server_key"])
  }
  type = "kubernetes.io/tls"
  lifecycle {
    # The above secret generation script will run every time, but we only need its output once on creation
    ignore_changes = [
      binary_data["tls.crt"],
      binary_data["tls.key"]
    ]
  }
}

resource "kubernetes_config_map_v1" "rabbitmq_config" {
  metadata {
    name = "rabbitmq-config"
  }
  data = {
    "rabbitmq.conf" = <<EOF
# RabbitMQ configuration
channel_max = 131072
# Controls memory high alarm for rmq server
# documentation: https://www.rabbitmq.com/memory.html
vm_memory_high_watermark.relative = 0.7
listeners.ssl.default = 5671
ssl_options.cacertfile = /etc/rabbitmq/certs/tls.crt
ssl_options.certfile = /etc/rabbitmq/certs/tls.crt
ssl_options.keyfile = /etc/rabbitmq/certs/tls.key
ssl_options.verify = verify_peer
ssl_options.fail_if_no_peer_cert = false
management.listener.port = 15671
management.listener.ssl = true
management.listener.ssl_opts.cacertfile = /etc/rabbitmq/certs/tls.crt
management.listener.ssl_opts.certfile = /etc/rabbitmq/certs/tls.crt
management.listener.ssl_opts.keyfile = /etc/rabbitmq/certs/tls.key
prometheus.tcp.port = 15692
EOF
  }
}


resource "kubernetes_stateful_set_v1" "rabbitmq_statefulset" {
  wait_for_rollout = true
  metadata {
    name = "rabbitmq-statefulset"
  }
  spec {
    service_name = "rabbitmq-service"
    replicas     = "1"
    persistent_volume_claim_retention_policy {
      when_deleted = "Retain"
      when_scaled  = "Retain"
    }
    pod_management_policy = "OrderedReady"
    selector {
      match_labels = {
        app = "rabbitmq"
      }
    }
    template {
      metadata {
        labels = {
          app                 = "rabbitmq"
          rabbitmq-prometheus = "true"
        }
      }
      spec {
        automount_service_account_token = false
        enable_service_links            = false
        toleration {
          key      = "service"
          operator = "Equal"
          value    = "rabbitmq"
          effect   = "NoSchedule"
        }
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "glean.com/node-pool-selector"
                  operator = "In"
                  values   = [var.rabbitmq_nodegroup]
                }
              }
            }
          }
        }
        container {
          name  = "rabbitmq"
          image = "heidiks/rabbitmq-delayed-message-exchange:3.12.10-management"
          port {
            container_port = 5671
            name           = "amqp"
          }
          port {
            container_port = 15671
            name           = "management"
          }
          port {
            container_port = 15692
            name           = "metrics"
          }
          volume_mount {
            mount_path = "/var/lib/rabbitmq"
            name       = "rabbitmq-data"
          }
          volume_mount {
            mount_path = "/etc/rabbitmq/rabbitmq.conf"
            name       = "config-volume"
            sub_path   = "rabbitmq.conf"
          }
          volume_mount {
            mount_path = "/etc/rabbitmq/certs"
            name       = "cert-volume"
          }
          security_context {
            allow_privilege_escalation = false
            run_as_non_root            = false
          }
          readiness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "rabbitmq-diagnostics check_running"
              ]
            }
            initial_delay_seconds = var.rabbitmq_k8s_configs.initial_delay_seconds
            period_seconds        = var.rabbitmq_k8s_configs.readiness_check_period_seconds
            timeout_seconds       = var.rabbitmq_k8s_configs.readiness_check_timeout_seconds
            failure_threshold     = 3
          }
          liveness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "rabbitmq-diagnostics check_running"
              ]
            }
            initial_delay_seconds = var.rabbitmq_k8s_configs.initial_delay_seconds
            period_seconds        = var.rabbitmq_k8s_configs.liveness_check_period_seconds
            timeout_seconds       = var.rabbitmq_k8s_configs.liveness_check_timeout_seconds
            failure_threshold     = 3

          }
          startup_probe {
            exec {
              command = [
                "sh",
                "-c",
                "rabbitmq-diagnostics check_running"
              ]
            }
            period_seconds    = var.rabbitmq_k8s_configs.startup_check_period_seconds
            timeout_seconds   = var.rabbitmq_k8s_configs.startup_check_timeout_seconds
            failure_threshold = var.rabbitmq_k8s_configs.startup_check_failure_threshold
          }
          resources {
            limits   = {}
            requests = {}
          }
        }
        volume {
          name = "config-volume"
          config_map {
            name     = kubernetes_config_map_v1.rabbitmq_config.metadata[0].name
            optional = false
          }
        }
        volume {
          name = "cert-volume"
          secret {
            secret_name = kubernetes_secret_v1.rabbitmq_certs.metadata[0].name
            optional    = false
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "rabbitmq-data"
      }
      spec {
        access_modes = [
          "ReadWriteOnce"
        ]
        resources {
          requests = {
            storage = format("%dGi", var.rabbitmq_k8s_configs.data_disk_size_gi)
          }
        }
        storage_class_name = var.storage_class_name
      }
    }
  }
  lifecycle {
    ignore_changes = [
      # Ignore any changes to storage requests, since it will cause the entire sts to be recreated. We currently don't
      # support scaling up rabbitmq
      spec[0].volume_claim_template[0].spec[0].resources[0].requests,
      # We also have to ignore this field because otherwise terraform will try to automatically set the namespace to
      # 'default' which will trigger a recreation of the statefulset:
      # https://github.com/hashicorp/terraform-provider-kubernetes/issues/691
      spec[0].volume_claim_template[0].metadata[0].namespace
    ]
    # Never destroy a statefulset
    prevent_destroy = true
  }
  depends_on = [kubernetes_deployment.cluster_autoscaler]
}

resource "kubernetes_service_v1" "rabbitmq_service" {
  # This has to be here since we need the ALB plugin to handle creating the load balancers for us
  depends_on = [var.k8s_service_lb_controller_ids]
  metadata {
    name = "rabbitmq-service"
    annotations = merge(var.private_load_balancer_via_k8s_service_info.common_annotations, {
      (var.private_load_balancer_via_k8s_service_info.load_balancer_name_key) : "rabbitmq-internal-lb"
    })
  }
  spec {
    type = "LoadBalancer"
    port {
      port = 5671
      name = "amqp"
    }
    port {
      port = 15671
      name = "management"
    }
    port {
      port = 15692
      name = "metrics"
    }
    selector = {
      app = kubernetes_stateful_set_v1.rabbitmq_statefulset.spec[0].template[0].metadata[0].labels.app
    }
    external_traffic_policy = "Cluster"
    session_affinity        = "None"
    ip_families = [
      "IPv4"
    ]
    ip_family_policy                  = "SingleStack"
    allocate_load_balancer_node_ports = true
    load_balancer_class               = var.private_load_balancer_via_k8s_service_info.load_balancer_class_name
    internal_traffic_policy           = "Cluster"
  }
  wait_for_load_balancer = true
}

# Run INITIALIZE_RABBITMQ to enable some feature flags
module "initialize_rabbitmq" {
  source       = "./deploy_job"
  operation    = "INITIALIZE_RABBITMQ"
  general_info = local.deploy_job_general_info
  depends_on   = [kubernetes_stateful_set_v1.rabbitmq_statefulset, module.initialize_config]
}

# Finally, set the rabbitmq.internalLBHost config so task-push knows where to connect
module "rabbitmq_config_update" {
  source       = "../config_update"
  general_info = local.config_update_general_info
  config_key_values = merge({
    "rabbitmq.internalLBHost" : kubernetes_service_v1.rabbitmq_service.status[0].load_balancer[0].ingress[0].hostname
  }, var.additional_kms_config_key_values)
  path        = "config_update"
  update_name = "rabbitmq-config-update"
  depends_on  = [module.initialize_config]
}
