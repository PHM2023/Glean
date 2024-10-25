### CORE GLEAN K8s RESOURCES ###

# TODO: add the real deployment/service/statefulset resources here

### DSE ###
resource "kubernetes_service_account" "dse" {
  metadata {
    name      = "datasource-events"
    namespace = "default"

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.dse
    }
  }
}


module "dse_deployment" {
  source                                     = "./memory_based_k8s_deployment"
  app                                        = "dse"
  progress_deadline_seconds                  = 600
  app_name_env_vars                          = var.app_name_env_vars
  autoscaling_max_cpu_percent                = var.dse_k8s_configs.autoscaling_max_cpu_percent
  cpu_limit                                  = var.dse_k8s_configs.cpu_limit
  cpu_request                                = var.dse_k8s_configs.cpu_request
  default_env_vars                           = var.default_env_vars
  image_uri                                  = var.dse_image_uri
  k8s_service_account                        = kubernetes_service_account.dse.metadata[0].name
  liveness_period_seconds                    = var.dse_k8s_configs.liveness_check_period_seconds
  liveness_timeout_seconds                   = var.dse_k8s_configs.liveness_check_timeout_seconds
  max_instances                              = var.dse_k8s_configs.max_instances
  memory_limit                               = var.dse_k8s_configs.memory_limit_gi
  memory_request                             = var.dse_k8s_configs.memory_request_gi
  min_instances                              = var.dse_k8s_configs.min_instances
  referential_env_vars                       = var.referential_env_vars
  startup_failure_threshold                  = var.dse_k8s_configs.startup_check_failure_threshold
  startup_period_seconds                     = var.dse_k8s_configs.startup_check_period_seconds
  startup_timeout_seconds                    = var.dse_k8s_configs.startup_check_timeout_seconds
  version_tag                                = var.version_tag
  required_nodegroup_node_selector_key       = var.memory_based_nodegroup_node_selector_info.common_selector_key
  required_nodegroup_node_selector_value     = var.memory_based_nodegroup_node_selector_info.common_selector_value
  preferential_node_groups                   = local.memory_based_preferential_node_groups
  additional_tolerations                     = var.memory_based_nodegroup_node_selector_info.tolerations
  k8s_service_lb_controller_ids              = var.k8s_service_lb_controller_ids
  private_load_balancer_via_k8s_service_info = var.private_load_balancer_via_k8s_service_info
  rollout_id                                 = var.rollout_id
  depends_on = [
    # Must depend on the autoscaler so we don't try deploying before the nodes can scale to meet the need
    kubernetes_deployment.cluster_autoscaler,
    # Sql tables must be setup before startup
    module.sql,
    module.upgrade,
  ]
}

resource "kubernetes_service_v1" "dse_internal_lb_service" {
  metadata {
    name = "dse-internal-lb"
    labels = {
      app = "dse"
    }
  }

  spec {
    type                    = "LoadBalancer"
    external_traffic_policy = "Local"
    selector = {
      app = "dse"
    }
    port {
      port        = 80
      target_port = "8080"
    }
    load_balancer_class = var.private_load_balancer_via_k8s_service_info.load_balancer_class_name
  }
  wait_for_load_balancer = true
}

# A separate service exclusively used for ipjc
# TODO: this really isn't needed anymore, remove it from the ingress rules
resource "kubernetes_service_v1" "ipjc" {
  metadata {
    name = "ipjc-service"
    labels = {
      app = "ipjc"
    }
  }
  spec {
    type                    = "NodePort"
    external_traffic_policy = "Local"
    selector = {
      app = "dse"
    }
    port {
      port        = 80
      target_port = "8080"
    }
  }
  depends_on = [module.dse_deployment]
}


### CLAMAV_SCANNER ###
module "clamav_scanner_deployment" {
  source                                     = "./memory_based_k8s_deployment"
  app                                        = "clamav-scanner"
  progress_deadline_seconds                  = 600
  app_name_env_vars                          = var.app_name_env_vars
  autoscaling_max_cpu_percent                = var.clamav_scanner_k8s_configs.autoscaling_max_cpu_percent
  cpu_limit                                  = var.clamav_scanner_k8s_configs.cpu_limit
  cpu_request                                = var.clamav_scanner_k8s_configs.cpu_request
  default_env_vars                           = var.default_env_vars
  image_uri                                  = var.clamav_scanner_image_uri
  k8s_service_account                        = null # No explicit service account
  liveness_period_seconds                    = var.clamav_scanner_k8s_configs.liveness_check_period_seconds
  liveness_timeout_seconds                   = var.clamav_scanner_k8s_configs.liveness_check_timeout_seconds
  max_instances                              = var.clamav_scanner_k8s_configs.max_instances
  memory_limit                               = var.clamav_scanner_k8s_configs.memory_limit_gi
  memory_request                             = var.clamav_scanner_k8s_configs.memory_request_gi
  min_instances                              = var.clamav_scanner_k8s_configs.min_instances
  referential_env_vars                       = var.referential_env_vars
  startup_failure_threshold                  = var.clamav_scanner_k8s_configs.startup_check_failure_threshold
  startup_period_seconds                     = var.clamav_scanner_k8s_configs.startup_check_period_seconds
  startup_timeout_seconds                    = var.clamav_scanner_k8s_configs.startup_check_timeout_seconds
  version_tag                                = var.version_tag
  required_nodegroup_node_selector_key       = var.memory_based_nodegroup_node_selector_info.common_selector_key
  required_nodegroup_node_selector_value     = var.memory_based_nodegroup_node_selector_info.common_selector_value
  preferential_node_groups                   = local.memory_based_preferential_node_groups
  additional_tolerations                     = var.memory_based_nodegroup_node_selector_info.tolerations
  k8s_service_lb_controller_ids              = var.k8s_service_lb_controller_ids
  private_load_balancer_via_k8s_service_info = var.private_load_balancer_via_k8s_service_info
  rollout_id                                 = var.rollout_id
  startup_check_path                         = local.clamav_scanner_info.ping_path
  readiness_check_path                       = local.clamav_scanner_info.ping_path
  liveness_check_path                        = local.clamav_scanner_info.ping_path
  depends_on = [
    # Must depend on the autoscaler so we don't try deploying before the nodes can scale to meet the need
    kubernetes_deployment.cluster_autoscaler,
    # Sql tables must be setup before startup
    module.sql,
    module.upgrade,
  ]
}


### QE ###
resource "kubernetes_service_account" "qe_service_account" {
  metadata {
    name      = "query-endpoint"
    namespace = "default"

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.qe
    }
  }
}


module "qe_deployment" {
  source                                     = "./memory_based_k8s_deployment"
  app                                        = "qe"
  progress_deadline_seconds                  = 1500
  app_name_env_vars                          = var.app_name_env_vars
  autoscaling_max_cpu_percent                = var.qe_k8s_configs.autoscaling_max_cpu_percent
  cpu_limit                                  = var.qe_k8s_configs.cpu_limit
  cpu_request                                = var.qe_k8s_configs.cpu_request
  default_env_vars                           = var.default_env_vars
  image_uri                                  = var.qe_image_uri
  k8s_service_account                        = kubernetes_service_account.qe_service_account.metadata[0].name
  liveness_period_seconds                    = var.qe_k8s_configs.liveness_check_period_seconds
  liveness_timeout_seconds                   = var.qe_k8s_configs.liveness_check_timeout_seconds
  max_instances                              = var.qe_k8s_configs.max_instances
  memory_limit                               = var.qe_k8s_configs.memory_limit_gi
  memory_request                             = var.qe_k8s_configs.memory_request_gi
  min_instances                              = var.qe_k8s_configs.min_instances
  referential_env_vars                       = var.referential_env_vars
  startup_failure_threshold                  = var.qe_k8s_configs.startup_check_failure_threshold
  startup_period_seconds                     = var.qe_k8s_configs.startup_check_period_seconds
  startup_timeout_seconds                    = var.qe_k8s_configs.startup_check_timeout_seconds
  version_tag                                = var.version_tag
  required_nodegroup_node_selector_key       = var.memory_based_nodegroup_node_selector_info.common_selector_key
  required_nodegroup_node_selector_value     = var.memory_based_nodegroup_node_selector_info.common_selector_value
  preferential_node_groups                   = local.memory_based_preferential_node_groups
  additional_tolerations                     = var.memory_based_nodegroup_node_selector_info.tolerations
  k8s_service_lb_controller_ids              = var.k8s_service_lb_controller_ids
  private_load_balancer_via_k8s_service_info = var.private_load_balancer_via_k8s_service_info
  rollout_id                                 = var.rollout_id
  depends_on = [
    # Must depend on the autoscaler so we don't try deploying before the nodes can scale to meet the need
    kubernetes_deployment.cluster_autoscaler,
    # QE needs all of these for startup to work
    module.qp_deployment,
    module.scholastic_deployment,
    module.setup_qe_secrets,
    module.create_opensearch_setup_only,
    module.experiment_configs,
    module.put_elastic_scoring_scripts,
    module.set_glean_azure_resource_configuration,
    module.upgrade,
  ]
}

### CRAWLER (AKA TASK HANDLERS) ###
resource "kubernetes_service_account" "task_handlers_service_account" {
  metadata {
    name      = "task-handlers"
    namespace = "default"

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.crawler
    }
  }
}

module "crawler_deployment" {
  source                                     = "./memory_based_k8s_deployment"
  app                                        = "crawler"
  progress_deadline_seconds                  = 1500
  app_name_env_vars                          = var.app_name_env_vars
  autoscaling_max_cpu_percent                = var.crawler_k8s_configs.autoscaling_max_cpu_percent
  cpu_limit                                  = var.crawler_k8s_configs.cpu_limit
  cpu_request                                = var.crawler_k8s_configs.cpu_request
  default_env_vars                           = var.default_env_vars
  image_uri                                  = var.crawler_image_uri
  k8s_service_account                        = kubernetes_service_account.task_handlers_service_account.metadata[0].name
  liveness_period_seconds                    = var.crawler_k8s_configs.liveness_check_period_seconds
  liveness_timeout_seconds                   = var.crawler_k8s_configs.liveness_check_timeout_seconds
  max_instances                              = var.crawler_k8s_configs.max_instances
  memory_limit                               = var.crawler_k8s_configs.memory_limit_gi
  memory_request                             = var.crawler_k8s_configs.memory_request_gi
  min_instances                              = var.crawler_k8s_configs.min_instances
  referential_env_vars                       = var.referential_env_vars
  startup_failure_threshold                  = var.crawler_k8s_configs.startup_check_failure_threshold
  startup_period_seconds                     = var.crawler_k8s_configs.startup_check_period_seconds
  startup_timeout_seconds                    = var.crawler_k8s_configs.startup_check_timeout_seconds
  version_tag                                = var.version_tag
  required_nodegroup_node_selector_value     = var.crawler_nodegroup
  required_nodegroup_node_selector_key       = var.nodegroup_node_selector_key
  k8s_service_lb_controller_ids              = var.k8s_service_lb_controller_ids
  private_load_balancer_via_k8s_service_info = var.private_load_balancer_via_k8s_service_info
  scale_down_stabilization_window_seconds    = 1200
  termination_grace_period_seconds           = 90
  rollout_id                                 = var.rollout_id
  depends_on = [
    module.queues,
    module.upgrade,
    # Must depend on the autoscaler so we don't try deploying before the nodes can scale to meet the need
    kubernetes_deployment.cluster_autoscaler,
  ]
}

### QP ###
resource "kubernetes_service_account" "query_parser_service_account" {
  metadata {
    name      = "query-parser"
    namespace = "default"

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.qp
    }
  }
}

# TODO: Add support for qp/scholastic canary versions
module "qp_deployment" {
  source                                     = "./memory_based_k8s_deployment"
  app                                        = "qp"
  progress_deadline_seconds                  = 1200
  app_name_env_vars                          = var.app_name_env_vars
  autoscaling_max_cpu_percent                = var.qp_k8s_configs.autoscaling_max_cpu_percent
  cpu_limit                                  = var.qp_k8s_configs.cpu_limit
  cpu_request                                = var.qp_k8s_configs.cpu_request
  default_env_vars                           = var.default_env_vars
  image_uri                                  = var.qp_image_uri
  k8s_service_account                        = kubernetes_service_account.query_parser_service_account.metadata[0].name
  liveness_period_seconds                    = var.qp_k8s_configs.liveness_check_period_seconds
  liveness_timeout_seconds                   = var.qp_k8s_configs.liveness_check_timeout_seconds
  max_instances                              = var.qp_k8s_configs.max_instances
  memory_limit                               = var.qp_k8s_configs.memory_limit_gi
  memory_request                             = var.qp_k8s_configs.memory_request_gi
  min_instances                              = var.qp_k8s_configs.min_instances
  referential_env_vars                       = var.referential_env_vars
  startup_failure_threshold                  = var.qp_k8s_configs.startup_check_failure_threshold
  startup_period_seconds                     = var.qp_k8s_configs.startup_check_period_seconds
  startup_timeout_seconds                    = var.qp_k8s_configs.startup_check_timeout_seconds
  version_tag                                = var.version_tag
  required_nodegroup_node_selector_key       = var.memory_based_nodegroup_node_selector_info.common_selector_key
  required_nodegroup_node_selector_value     = var.memory_based_nodegroup_node_selector_info.common_selector_value
  preferential_node_groups                   = local.memory_based_preferential_node_groups
  additional_tolerations                     = var.memory_based_nodegroup_node_selector_info.tolerations
  empty_dir_volumes                          = local.qp_scholastic_volume_info.empty_dir_volumes
  volume_mounts                              = local.qp_scholastic_volume_info.volume_mounts
  lifecycle_prestop_command                  = local.qp_scholastic_lifecycle_prestop_command
  k8s_service_lb_controller_ids              = var.k8s_service_lb_controller_ids
  private_load_balancer_via_k8s_service_info = var.private_load_balancer_via_k8s_service_info
  use_lb_service                             = true
  rollout_id                                 = var.rollout_id
  depends_on = [
    # Must depend on the autoscaler so we don't try deploying before the nodes can scale to meet the need
    kubernetes_deployment.cluster_autoscaler,
    # Sql tables must be setup before startup
    module.sql,
    module.upgrade,
  ]
}

module "qp_lb_config_update" {
  source       = "../config_update"
  general_info = local.config_update_general_info
  path         = "config_update"
  config_key_values = {
    "eks.qp.internalLbBaseUrl" : "http://${module.qp_deployment.lb_host_name}"
  }
  update_name = "qp-lb-config-update"
}

### SCHOLASTIC ###
resource "kubernetes_service_account" "scholastic_service_account" {
  metadata {
    name      = "scholastic"
    namespace = "default"

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.scholastic
    }
  }
}


module "scholastic_deployment" {
  source                                     = "./memory_based_k8s_deployment"
  app                                        = "scholastic"
  progress_deadline_seconds                  = 1200
  app_name_env_vars                          = var.app_name_env_vars
  autoscaling_max_cpu_percent                = var.scholastic_k8s_configs.autoscaling_max_cpu_percent
  cpu_limit                                  = var.scholastic_k8s_configs.cpu_limit
  cpu_request                                = var.scholastic_k8s_configs.cpu_request
  default_env_vars                           = var.default_env_vars
  image_uri                                  = var.scholastic_image_uri
  k8s_service_account                        = kubernetes_service_account.scholastic_service_account.metadata[0].name
  liveness_period_seconds                    = var.scholastic_k8s_configs.liveness_check_period_seconds
  liveness_timeout_seconds                   = var.scholastic_k8s_configs.liveness_check_timeout_seconds
  max_instances                              = var.scholastic_k8s_configs.max_instances
  memory_limit                               = var.scholastic_k8s_configs.memory_limit_gi
  memory_request                             = var.scholastic_k8s_configs.memory_request_gi
  min_instances                              = var.scholastic_k8s_configs.min_instances
  referential_env_vars                       = var.referential_env_vars
  startup_failure_threshold                  = var.scholastic_k8s_configs.startup_check_failure_threshold
  startup_period_seconds                     = var.scholastic_k8s_configs.startup_check_period_seconds
  startup_timeout_seconds                    = var.scholastic_k8s_configs.startup_check_timeout_seconds
  version_tag                                = var.version_tag
  required_nodegroup_node_selector_key       = var.memory_based_nodegroup_node_selector_info.common_selector_key
  required_nodegroup_node_selector_value     = var.memory_based_nodegroup_node_selector_info.common_selector_value
  preferential_node_groups                   = local.memory_based_preferential_node_groups
  additional_tolerations                     = var.memory_based_nodegroup_node_selector_info.tolerations
  empty_dir_volumes                          = local.qp_scholastic_volume_info.empty_dir_volumes
  volume_mounts                              = local.qp_scholastic_volume_info.volume_mounts
  lifecycle_prestop_command                  = local.qp_scholastic_lifecycle_prestop_command
  k8s_service_lb_controller_ids              = var.k8s_service_lb_controller_ids
  private_load_balancer_via_k8s_service_info = var.private_load_balancer_via_k8s_service_info
  use_lb_service                             = true
  rollout_id                                 = var.rollout_id
  depends_on = [
    # Must depend on the autoscaler so we don't try deploying before the nodes can scale to meet the need
    kubernetes_deployment.cluster_autoscaler,
    # Sql tables must be setup before startup
    module.sql,
    module.upgrade,
  ]
}

module "scholastic_lb_config_update" {
  source       = "../config_update"
  general_info = local.config_update_general_info
  path         = "config_update"
  config_key_values = {
    "eks.scholastic.internalLbBaseUrl" : "http://${module.scholastic_deployment.lb_host_name}"
  }
  update_name = "scholastic-lb-config-update"
}

### ADMIN CONSOLE ###
resource "kubernetes_service_account" "admin_console_service_account" {
  metadata {
    name      = "admin-console"
    namespace = "default"

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.admin_console
    }
  }
}


module "admin_deployment" {
  source                                     = "./memory_based_k8s_deployment"
  app                                        = "admin"
  progress_deadline_seconds                  = 600
  app_name_env_vars                          = var.app_name_env_vars
  autoscaling_max_cpu_percent                = var.admin_k8s_configs.autoscaling_max_cpu_percent
  cpu_limit                                  = var.admin_k8s_configs.cpu_limit
  cpu_request                                = var.admin_k8s_configs.cpu_request
  default_env_vars                           = var.default_env_vars
  image_uri                                  = var.admin_image_uri
  k8s_service_account                        = kubernetes_service_account.admin_console_service_account.metadata[0].name
  liveness_period_seconds                    = var.admin_k8s_configs.liveness_check_period_seconds
  liveness_timeout_seconds                   = var.admin_k8s_configs.liveness_check_timeout_seconds
  max_instances                              = var.admin_k8s_configs.max_instances
  memory_limit                               = var.admin_k8s_configs.memory_limit_gi
  memory_request                             = var.admin_k8s_configs.memory_request_gi
  min_instances                              = var.admin_k8s_configs.min_instances
  referential_env_vars                       = var.referential_env_vars
  startup_failure_threshold                  = var.admin_k8s_configs.startup_check_failure_threshold
  startup_period_seconds                     = var.admin_k8s_configs.startup_check_period_seconds
  startup_timeout_seconds                    = var.admin_k8s_configs.startup_check_timeout_seconds
  version_tag                                = var.version_tag
  required_nodegroup_node_selector_key       = var.memory_based_nodegroup_node_selector_info.common_selector_key
  required_nodegroup_node_selector_value     = var.memory_based_nodegroup_node_selector_info.common_selector_value
  preferential_node_groups                   = local.memory_based_preferential_node_groups
  additional_tolerations                     = var.memory_based_nodegroup_node_selector_info.tolerations
  k8s_service_lb_controller_ids              = var.k8s_service_lb_controller_ids
  private_load_balancer_via_k8s_service_info = var.private_load_balancer_via_k8s_service_info
  rollout_id                                 = var.rollout_id
  depends_on = [
    # Must depend on the autoscaler so we don't try deploying before the nodes can scale to meet the need
    kubernetes_deployment.cluster_autoscaler,
    # Sql tables must be setup before startup
    module.sql,
    module.upgrade,
  ]
}


### TASK PUSH ###
resource "kubernetes_service_account" "task_push_service_account" {
  metadata {
    name      = "task-push"
    namespace = "default"

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.task_push
    }
  }
}

### OPENSEARCH ###
resource "kubernetes_namespace" "elasticsearch_1_namespace" {
  metadata {
    name = "elasticsearch-1-namespace"
  }
}

resource "kubernetes_namespace" "elasticsearch_2_namespace" {
  metadata {
    name = "elasticsearch-2-namespace"
  }
}

resource "kubernetes_service_account" "elastic_compute_ksa_1" {
  metadata {
    name      = "elastic-compute-ksa"
    namespace = kubernetes_namespace.elasticsearch_1_namespace.metadata[0].name

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.opensearch_1
    }
  }
}

resource "kubernetes_service_account" "elastic_compute_ksa_2" {
  metadata {
    name      = "elastic-compute-ksa"
    namespace = kubernetes_namespace.elasticsearch_2_namespace.metadata[0].name

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.opensearch_2
    }
  }
}


### CRON JOBS ###
# TODO: rename this to something platform-agnostic
resource "kubernetes_service_account" "lambda_service_account" {
  metadata {
    name      = "lambda-invoker"
    namespace = "default"

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.cron_job
    }
  }
}

### EXTERNAL INGRESS (LOAD BALANCER) ###
resource "kubernetes_ingress_v1" "glean_ingress" {
  wait_for_load_balancer = true
  metadata {
    name        = "glean-ingress"
    annotations = var.public_ingress_annotations
  }
  spec {
    rule {
      http {
        dynamic "path" {
          for_each = local.ingress_rules
          content {
            path      = path.value["path"]
            path_type = path.value["path_type"]
            backend {
              service {
                name = path.value["service_name"]
                port {
                  number = path.value["port"]
                }
              }
            }
          }
        }
      }
    }
  }
  # Ideally we wouldn't need this and could just refer to the services directly in the rules above. Unfortunately
  # though, to keep the ingress rule yamls from GCP in sync with terraform, we have to get the rule list from an
  # external data block, which means we need to manually declare the dependencies on those services here
  depends_on = [
    module.admin_deployment,
    module.dse_deployment,
    module.qe_deployment,
    module.qp_deployment,
    module.scholastic_deployment,
    kubernetes_service_v1.ipjc,
  ]
}

### CORE DAEMONSETS ###
resource "kubernetes_daemon_set_v1" "clamav" {
  metadata {
    name      = "clamav"
    namespace = "kube-system"
    labels = {
      "k8s-app" = "clamav-host-scanner"
    }
  }
  spec {
    selector {
      match_labels = {
        name = "clamav"
      }
    }
    template {
      metadata {
        labels = {
          name = "clamav"
        }
      }
      spec {
        automount_service_account_token = false
        enable_service_links            = false
        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }
        container {
          name  = "clamav-scanner"
          image = var.clamav_image_uri
          resources {
            limits = {
              cpu    = "500m"
              memory = "1.8Gi"
            }
            requests = {
              cpu    = "100m"
              memory = "1Gi"
            }
          }
          volume_mount {
            mount_path = "/data"
            name       = "data-vol"
          }
          volume_mount {
            mount_path = "/host-fs"
            name       = "host-fs"
            read_only  = true
          }
          volume_mount {
            mount_path = "/logs"
            name       = "logs"
          }
          liveness_probe {
            exec {
              command = [
                "/health.sh"
              ]
            }
            initial_delay_seconds = 240
            period_seconds        = 30
          }
        }
        termination_grace_period_seconds = 30
        volume {
          name = "data-vol"
          empty_dir {}
        }
        volume {
          name = "host-fs"
          host_path {
            path = "/"
          }
        }
        volume {
          name = "logs"
          host_path {
            path = "/var/log/clamav"
          }
        }
      }
    }
  }
}

resource "kubernetes_daemon_set_v1" "basic_fim" {
  metadata {
    name      = "basic-fim"
    namespace = "kube-system"
    labels = {
      "k8s-app" = "basic-fim-scanner"
    }
  }
  spec {
    selector {
      match_labels = {
        name = "basic-fim"
      }
    }
    template {
      metadata {
        labels = {
          name = "basic-fim"
        }
      }
      spec {
        automount_service_account_token = false
        enable_service_links            = false
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "glean.com/elastic-node-pool-selector"
                  operator = "In"
                  values = [
                    "elastic-node-pool-1",
                    "elastic-node-pool-2"
                  ]
                }
              }
            }
          }
        }
        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }
        container {
          name  = "basic-fim-scanner"
          image = var.basic_fim_image_uri
          resources {
            limits = {
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "500Mi"
            }
          }
          volume_mount {
            mount_path = "/host-fs"
            name       = "host-fs"
            read_only  = true
          }
          volume_mount {
            mount_path = "/logs"
            name       = "logs"
          }
        }
        container {
          name  = "basic-fim-logger"
          image = "docker.io/library/alpine:latest"
          args  = ["/bin/sh", "-c", "tail -n+1 -f /logs/scan.log"]
          resources {
            limits = {
              memory = "500Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
          volume_mount {
            mount_path = "/logs"
            name       = "logs"
          }
        }
        termination_grace_period_seconds = 30
        volume {
          name = "host-fs"
          host_path {
            path = "/"
          }
        }
        volume {
          name = "logs"
          host_path {
            path = "/var/log/basic-fim"
          }
        }
      }
    }
  }
}
