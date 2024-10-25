module "task_push_deployment" {
  source                                     = "./memory_based_k8s_deployment"
  app                                        = "task-push"
  progress_deadline_seconds                  = 600
  app_name_env_vars                          = var.app_name_env_vars
  autoscaling_max_cpu_percent                = var.task_push_k8s_configs.autoscaling_max_cpu_percent
  cpu_limit                                  = var.task_push_k8s_configs.cpu_limit
  cpu_request                                = var.task_push_k8s_configs.cpu_request
  default_env_vars                           = var.default_env_vars
  image_uri                                  = var.task_push_image_uri
  k8s_service_account                        = kubernetes_service_account.task_push_service_account.metadata[0].name
  liveness_period_seconds                    = var.task_push_k8s_configs.liveness_check_period_seconds
  liveness_timeout_seconds                   = var.task_push_k8s_configs.liveness_check_timeout_seconds
  max_instances                              = var.task_push_k8s_configs.max_instances
  memory_limit                               = var.task_push_k8s_configs.memory_limit_gi
  memory_request                             = var.task_push_k8s_configs.memory_request_gi
  min_instances                              = var.task_push_k8s_configs.min_instances
  referential_env_vars                       = var.referential_env_vars
  startup_failure_threshold                  = var.task_push_k8s_configs.startup_check_failure_threshold
  startup_period_seconds                     = var.task_push_k8s_configs.startup_check_period_seconds
  startup_timeout_seconds                    = var.task_push_k8s_configs.startup_check_timeout_seconds
  version_tag                                = var.version_tag
  required_nodegroup_node_selector_value     = var.task_push_nodegroup
  required_nodegroup_node_selector_key       = var.nodegroup_node_selector_key
  k8s_service_lb_controller_ids              = var.k8s_service_lb_controller_ids
  use_lb_service                             = true
  private_load_balancer_via_k8s_service_info = var.private_load_balancer_via_k8s_service_info
  additional_tolerations = [
    {
      key      = "service"
      operator = "Equal"
      value    = "task-push"
      effect   = "NoSchedule"
    }
  ]
  rollout_id = var.rollout_id
  depends_on = [
    module.rabbitmq_config_update,
    module.initialize_rabbitmq,
    module.sql,
    # Must depend on the autoscaler so we don't try deploying before the nodes can scale to meet the need
    kubernetes_deployment.cluster_autoscaler
  ]
}

module "task_push_config_update" {
  source       = "../config_update"
  general_info = local.config_update_general_info
  config_key_values = merge({
    "task_push.internalLBBaseURL" : format("http://%s:80", module.task_push_deployment.lb_host_name)
  }, var.additional_kms_config_key_values)
  path        = "config_update"
  update_name = "task-push-config-update"
  depends_on  = [module.initialize_config]
}
