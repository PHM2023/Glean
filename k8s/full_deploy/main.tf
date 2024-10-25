### NOTE: THIS ENTIRE MODULE IS MEANT TO BE PLATFORM-AGNOSTIC - DO NOT ADD ANY PLATFORM-SPECIFIC RESOURCES TO IT ###

resource "kubernetes_namespace" "deploy_jobs_namespace" {
  metadata {
    name = var.deploy_jobs_namespace
  }
}

resource "kubernetes_service_account" "deploy_job_k8s_service_account" {
  metadata {
    name      = var.deploy_jobs_service_account
    namespace = kubernetes_namespace.deploy_jobs_namespace.metadata[0].name

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.deploy_jobs
    }
  }
}

resource "helm_release" "k8s_event_logger_helm_install" {
  chart      = "k8s-event-logger"
  name       = "k8s-event-logger"
  repository = "https://charts.deliveryhero.io"
}

### START DEPLOY JOBS ###

module "initialize_config" {
  source       = "./deploy_job"
  operation    = "INITIALIZE_CONFIG"
  run_once     = true
  general_info = local.deploy_job_general_info
}

module "kms_config_update" {
  source       = "../config_update"
  general_info = local.config_update_general_info
  config_key_values = merge({
    "queryapi.queryParser.encryptedSecretFilename" : var.qp_encrypted_secret_file_name
  }, var.additional_kms_config_key_values)
  path        = "config_update"
  update_name = "kms-config-update"
  depends_on  = [module.initialize_config]
}

module "memcached_config_update" {
  source       = "../config_update"
  general_info = local.config_update_general_info
  config_key_values = merge({
    "memcached.discoveryEndpoints" : var.memcached_discovery_endpoints
  }, var.additional_kms_config_key_values)
  path        = "config_update"
  update_name = "memcached-config-update"
  depends_on  = [module.initialize_config]
}

module "git_crawler_config_update" {
  source       = "../config_update"
  general_info = local.config_update_general_info
  config_key_values = {
    "deploy.computeengine.git_crawler.url" : "http://${var.git_crawler_private_ip}:8080/git-crawler"
  }
  path        = "config_update"
  update_name = "git-crawler-config-update"
  depends_on  = [module.initialize_config]
}

module "proxy_config_update" {
  source            = "../config_update"
  general_info      = local.config_update_general_info
  config_key_values = local.proxy_config_updates
  path              = "config_update"
  update_name       = "proxy-config-update"
  depends_on        = [module.initialize_config]
}

module "initialize_sql" {
  source       = "./deploy_job"
  operation    = "INITIALIZE_SQL"
  run_once     = true
  general_info = local.deploy_job_general_info
  depends_on   = [var.sql_instance_ids, module.initialize_config]
}

module "sync_manifest" {
  source       = "./deploy_job"
  operation    = "SYNC_MANIFEST"
  general_info = local.deploy_job_general_info
  depends_on   = [module.initialize_config]
}

module "sql" {
  source       = "./deploy_job"
  operation    = "SQL"
  general_info = local.deploy_job_general_info
  depends_on   = [module.initialize_sql]
}

module "setup_qe_secrets" {
  source       = "./deploy_job"
  operation    = "SETUP_QE_SECRETS"
  run_once     = true
  general_info = local.deploy_job_general_info
  depends_on   = [module.sql, module.kms_config_update]
}

# This op just applies a bunch of huge k8s configs, so we could theoretically move it to terraform if we translated each
# of the configs individually. Whoever wants to do this, godspeed. If you're also wondering why we can't use the
# `kubernetes_manifest` resource in terraform, unfortunately, that resource doesn't work if you're trying to create
# the cluster and k8s resource in the same `apply` phase, which is what we do in our full terraform setup.
module "gmp_setup" {
  source       = "./deploy_job"
  operation    = "GMP_SETUP"
  general_info = local.deploy_job_general_info
  # Should only be run once so it doesn't accidentally delete/reset the other gmp resources
  run_once   = true
  depends_on = [module.initialize_config]
}

module "gmp" {
  source                    = "./google_managed_prometheus"
  cluster_name              = var.cluster_name
  deploy_job_general_info   = local.deploy_job_general_info
  monitoring_gcp_project_id = var.monitoring_gcp_project_id
  service_account_iam_annotation = {
    key   = var.service_account_iam_annotation_key
    value = var.service_account_iam_annotations.gmp_collector
  }
  set_google_credentials_file_content = var.set_google_credentials_file_content
  depends_on                          = [module.gmp_setup]
}

## Same as the GMP_SETUP deploy job - this just installs a bunch of k8s configs that we haven't taken the time
## to move to terraform
module "gmp_operator_and_pod_monitoring" {
  source       = "./deploy_job"
  operation    = "GMP_OPERATORS_AND_POD_MONITORING"
  general_info = local.deploy_job_general_info
  # These should all be created after the gmp resources are in place
  depends_on = [module.gmp]
}

module "create_opensearch_setup_only" {
  # Custom job to create all resources needed for opensearch
  # TODO: move the helm chart install and nodegroup setup to terraform
  source       = "./deploy_job"
  run_once     = true
  operation    = "CREATE_ELASTIC_NODE_POOL_IN_GLEAN_CLUSTER_SETUP_ONLY"
  general_info = local.deploy_job_general_info
  depends_on = [
    # Opensearch uses this storage class in the helm chart, so we have to add this dependency manually
    var.storage_class_name,
    # Opensearch also uses special secrets for the snapshot repository, but this is usually specific to the cloud platform
    var.opensearch_snapshot_secrets,
    kubernetes_service_account.elastic_compute_ksa_1,
    kubernetes_service_account.elastic_compute_ksa_2,
    # Manifest must be synced first to set up google credentials properly from the deploy job
    module.sync_manifest
  ]
}

module "queues" {
  source       = "./deploy_job"
  operation    = "QUEUES"
  general_info = local.deploy_job_general_info
  depends_on = [
    module.task_push_config_update
  ]
}

module "experiment_configs" {
  source       = "./deploy_job"
  operation    = "EXPERIMENT_CONFIGS"
  general_info = local.deploy_job_general_info
  depends_on   = [module.qp_deployment, module.scholastic_deployment]
}

module "set_glean_azure_resource_configuration" {
  source       = "./deploy_job"
  operation    = "SET_GLEAN_AZURE_RESOURCE_CONFIGURATION"
  general_info = local.deploy_job_general_info
  depends_on   = [module.initialize_config]
}

module "put_elastic_scoring_scripts" {
  source       = "./deploy_job"
  operation    = "PUT_ELASTIC_SCORING_SCRIPTS"
  general_info = local.deploy_job_general_info
  depends_on   = [module.create_opensearch_setup_only]
}

module "setup_ugc" {
  source       = "./deploy_job"
  operation    = "SETUP_UGC"
  run_once     = true
  general_info = local.deploy_job_general_info
  depends_on = [
    # Needs queues to be up before launching ugc crawls
    module.queues
  ]
}

module "update_opensearch_index_schemas" {
  source       = "./deploy_job"
  operation    = "UPDATE_OPENSEARCH_INDEX_SCHEMAS"
  general_info = local.deploy_job_general_info
  depends_on = [
    module.create_opensearch_setup_only
  ]
}

module "sync_general_query_metadata" {
  source       = "./deploy_job"
  operation    = "SYNC_GENERAL_QUERY_METADATA"
  general_info = local.deploy_job_general_info
  depends_on = [
    module.initialize_config,
  ]
}

module "upgrade" {
  source       = "./deploy_job"
  operation    = "UPGRADE"
  general_info = local.deploy_job_general_info
  depends_on = [
    module.sql
  ]
}

module "cron" {
  source       = "./deploy_job"
  operation    = "CRON"
  general_info = local.deploy_job_general_info
  depends_on = [
    module.initialize_config
  ]
}

module "elastic_plugin" {
  source       = "./deploy_job"
  operation    = "ELASTIC_PLUGIN"
  general_info = local.deploy_job_general_info
  depends_on = [
    module.create_opensearch_setup_only
  ]
}

module "flink_invoker_image" {
  source       = "./deploy_job"
  operation    = "FLINK_INVOKER_IMAGE"
  general_info = local.deploy_job_general_info
  depends_on = [
    module.sql
  ]
}

module "python_flink_harness_base_image" {
  source       = "./deploy_job"
  operation    = "PYTHON_FLINK_HARNESS_BASE_IMAGE"
  general_info = local.deploy_job_general_info
  depends_on = [
    module.sql
  ]
}
