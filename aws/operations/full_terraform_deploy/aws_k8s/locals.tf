locals {
  config_update_general_info = {
    version_tag                 = var.version_tag
    app_name_env_vars           = var.app_name_env_vars
    config_handler_image_uri    = var.config_handler_image_uri
    default_env_vars            = var.default_env_vars
    namespace                   = var.deploy_jobs_namespace
    nodegroup                   = var.deploy_jobs_nodegroup
    nodegroup_node_selector_key = var.nodegroup_node_selector_key
    referential_env_vars        = var.referential_env_vars
    service_account             = var.deploy_jobs_service_account
  }
  opensearch_s3_secret_name = "s3-glean-secret"
  opensearch_snapshot_secret_data = {
    "s3.client.default.role_arn"          = var.elastic_compute_role_arn
    "s3.client.default.role_session_name" = "elastic-compute-snapshot-session"
  }
}
