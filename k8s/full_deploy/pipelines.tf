# DOCBUILDER and ENTITY_BUILDER both depend on opensearch schemas being in place
module "docbuilder" {
  source       = "./deploy_job"
  operation    = "DOCBUILDER"
  general_info = local.deploy_job_general_info
  depends_on = [
    module.update_opensearch_index_schemas,
    module.sql,
    helm_release.flink_kubernetes_operator,
    kubernetes_cluster_role_binding.flink_watchdog_cluster_role_binding,
    kubernetes_annotations.flink_sa_role_annotation,
  ]
}

module "entity_builder" {
  source       = "./deploy_job"
  operation    = "ENTITY_BUILDER"
  general_info = local.deploy_job_general_info
  depends_on = [
    module.update_opensearch_index_schemas,
    module.sql,
    helm_release.flink_kubernetes_operator,
    kubernetes_cluster_role_binding.flink_watchdog_cluster_role_binding,
    kubernetes_annotations.flink_sa_role_annotation,
  ]
}


module "pipelines" {
  for_each     = toset(local.processed_pipelines_list)
  source       = "./deploy_job"
  operation    = upper(each.key)
  general_info = local.deploy_job_general_info
  depends_on = [
    module.initialize_config,
    module.sync_general_query_metadata
  ]
  # Each of these jobs should be relatively quick since they're just copying s3 artifacts over from aws-glean-engineering
  timeout_minutes = 8
}