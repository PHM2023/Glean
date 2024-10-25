locals {
  deploy_job_general_info = {
    glean_instance_name             = var.glean_instance_name
    default_env_vars                = var.default_env_vars
    app_name_env_vars               = var.app_name_env_vars
    deploy_image_uri                = var.deploy_image_uri
    deploy_jobs_k8s_service_account = kubernetes_service_account.deploy_job_k8s_service_account.metadata[0].name
    deploy_jobs_namespace           = kubernetes_namespace.deploy_jobs_namespace.metadata[0].name
    deploy_jobs_nodegroup           = var.deploy_jobs_nodegroup
    nodegroup_node_selector_key     = var.nodegroup_node_selector_key
    referential_env_vars            = var.referential_env_vars
    tag                             = var.version_tag
    extra_args                      = var.deploy_jobs_extra_args
  }

  config_update_general_info = {
    version_tag                 = var.version_tag
    app_name_env_vars           = var.app_name_env_vars
    config_handler_image_uri    = var.config_handler_image_uri
    default_env_vars            = var.default_env_vars
    namespace                   = kubernetes_namespace.deploy_jobs_namespace.metadata[0].name
    nodegroup                   = var.deploy_jobs_nodegroup
    nodegroup_node_selector_key = var.nodegroup_node_selector_key
    referential_env_vars        = var.referential_env_vars
    service_account             = kubernetes_service_account.deploy_job_k8s_service_account.metadata[0].name
  }

  proxy_config_updates = merge({
    "setup.proxy.ip" : var.proxy_ip,
    "setup.transit.ip" : var.transit_ip
  }, var.additional_proxy_config_updates)

  qp_scholastic_volume_info = {
    empty_dir_volumes = [
      {
        name = "file-volume"
      }
    ]
    volume_mounts = [
      {
        # This is used by nltk / pbert and other models to store data.
        mount_path = "/usr/local/lib"
        name       = "file-volume"
        read_only  = false
      }
    ]
  }
  # Ensures that the pod is removed from the NEG before killing itself.
  qp_scholastic_lifecycle_prestop_command = ["sleep", "10"]

  # The nodegroup selection for memory based workloads is non-deterministic but weighted based on this list. Usually,
  # lower cost nodes would get a higher weight.
  # TODO: explore Karpenter
  memory_based_preferential_node_groups = [
    for i, nodegroup in var.memory_based_nodegroup_node_selector_info.nodegroups : {
      node_selector_key   = var.nodegroup_node_selector_key
      node_selector_value = nodegroup
      weight              = length(var.memory_based_nodegroup_node_selector_info.nodegroups) - i
    }
  ]

  clamav_scanner_info = {
    ping_path = "/ping"
  }

  # filter out DOCBUILDER and ENTITY_BUILDER since those have special dependencies
  processed_pipelines_list = [for pipeline in var.pipelines_list : upper(pipeline) if !contains(["DOCBUILDER", "ENTITY_BUILDER"], upper(pipeline))]

  ingress_rules = [
    for rule_index, rule_string in data.external.ingress_rules.result : {
      path         = split(",", rule_string)[0]
      path_type    = split(",", rule_string)[1]
      service_name = split(",", rule_string)[2]
      port         = tonumber(split(",", rule_string)[3])
    }
  ]
}
