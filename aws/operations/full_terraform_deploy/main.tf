resource "null_resource" "version_check" {
  # This resource only exists to store the latest version tag used using the last_version_used output. This should be
  # checked in the plan approval phase to ensure we don't use older versions unintentionally
  triggers = {
    version_tag = var.version_tag
  }
}

module "lambda_ecr_repos" {
  source       = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\lambda_ecr_repos"
  region       = var.region
  account_id   = var.account_id
  default_tags = var.default_tags
}

module "iam" {
  source                       = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\iam"
  region                       = var.region
  account_id                   = var.account_id
  iam_permissions_boundary_arn = var.iam_permissions_boundary_arn
}

module "network" {
  source       = ""C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\network"
  region       = var.region
  default_tags = var.default_tags
}

module "eks_phase_1" {
  source                       = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\eks_phase_1"
  account_id                   = var.account_id
  region                       = var.region
  default_tags                 = var.default_tags
  iam_permissions_boundary_arn = var.iam_permissions_boundary_arn
  public_subnet_id             = module.network.public_subnet_id
  eks_private_subnet_id        = module.network.eks_private_subnet_id

  bastion_security_group_id      = module.network.bastion_security_group_id
  codebuild_security_group_id    = module.network.codebuild_security_group_id
  lambda_security_group_id       = module.network.lambda_security_group_id
  secrets_encryption_kms_key_arn = module.kms.secret_store_key_arn
}

module "bastion" {
  source                        = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\bastion"
  region                        = var.region
  subnet_id                     = module.network.bastion_subnet_id
  bastion_security_group        = module.network.bastion_security_group_id
  default_tags                  = var.default_tags
  iam_permissions_boundary_arn  = var.iam_permissions_boundary_arn
  eks_cluster_security_group_id = module.eks_phase_1.cluster_security_group_id
  bastion_instance_type         = var.bastion_instance_type
  depends_on = [
    # Adding these to ensure bastion only starts up after all relevant vpc endpoints and gateways are setup. Without
    # these, bastion can get caught in a bad state and require a manual restart
    module.network.ssm_vpc_endpoint_id,
    module.network.ec2messages_vpc_endpoint_id,
    module.network.ssmmessages_vpc_endpoint_id,
  ]
}


module "kms" {
  source               = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\kms"
  region               = var.region
  default_tags         = var.default_tags
  query_secrets_bucket = module.s3.query_secrets_bucket
}


module "s3_configs_read" {
  source     = "./read_config"
  region     = var.region
  account_id = var.account_id
  keys = [
    "aws.disableAccountBPA"
  ]
  default_config_path = var.default_config_path
  custom_config_path  = var.custom_config_path
}

module "s3" {
  source              = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\s3"
  account_id          = var.account_id
  region              = var.region
  default_tags        = var.default_tags
  disable_account_bpa = local.s3_configs["aws.disableAccountBPA"]
}

module "sns" {
  source       = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\sns"
  region       = var.region
  default_tags = var.default_tags
}

module "acm" {
  source         = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\acm"
  region         = var.region
  default_tags   = var.default_tags
  subdomain_name = var.glean_instance_name
}


# For all of our lambda function images, we unfortunately need to manually download the image from the Glean-central
# us-east-1 ECR repos, then re-upload them to the regional, account-specific ECR repos in this account. This is because
# lambda does not let you pull images from cross-region ECR repos, and Glean-central only builds in us-east-1
module "stackdriver_exporter_image" {
  source      = "./dedicated_image"
  account_id  = var.account_id
  region      = var.region
  repo_name   = module.lambda_ecr_repos.repo_names["aws_stackdriver_log_exporter"]
  version_tag = var.version_tag
}

module "stackdriver_exporter" {
  source                          = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\modules\\stackdriver_exporter"
  region                          = var.region
  account_id                      = var.account_id
  image_uri                       = module.stackdriver_exporter_image.image_uri
  default_tags                    = var.default_tags
  iam_permissions_boundary_arn    = var.iam_permissions_boundary_arn
  config_bucket_reader_policy_arn = module.s3.config_bucket_reader_policy_arn
  aws_waf_log_group_name          = module.waf.aws_waf_log_group_name
  gcp_connector_project_id        = var.gcp_connector_project_id
  gcp_connector_project_number    = var.gcp_connector_project_number
}

module "cron_helper_image" {
  source      = "./dedicated_image"
  account_id  = var.account_id
  region      = var.region
  repo_name   = module.lambda_ecr_repos.repo_names["cron_helper"]
  version_tag = var.version_tag
}

module "cron_helper" {
  source     = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\cron_helper"
  image_uri  = module.cron_helper_image.image_uri
  region     = var.region
  account_id = var.account_id
  # intentionally not using module.eks_phase_1.cluster_name since cron_helper doesn't need to wait on cluster creation
  cluster_name                 = "glean-cluster"
  default_tags                 = var.default_tags
  iam_permissions_boundary_arn = var.iam_permissions_boundary_arn

  ipjc_key_arn                    = module.kms.ipjc_signing_key_arn
  lambda_security_group_id        = module.network.lambda_security_group_id
  lambda_subnet_id                = module.network.lambda_subnet_id
  storage_secret_key_arn          = module.kms.storage_secrets_key_arn
  config_bucket_reader_policy_arn = module.s3.config_bucket_reader_policy_arn
  eks_worker_node_arn             = module.eks_phase_1.worker_node_arn
  eks_cluster_role_arn            = module.eks_phase_1.eks_cluster_role_arn
  depends_on = [
    # Ensures cron helper doesn't deploy until the log groups it writes to are setup
    module.stackdriver_exporter.application_log_group_name,
    module.stackdriver_exporter.operation_log_group_name
  ]
  gcp_connector_project_id     = var.gcp_connector_project_id
  gcp_connector_project_number = var.gcp_connector_project_number
}

module "sql_configs" {
  source              = "./read_config"
  account_id          = var.account_id
  default_config_path = var.default_config_path
  keys = [
    "deploy.sql.enable_slow_query_logs",
    "deploy.sql.slow_query_threshold",
    "sql.aws.backupWindow",
    "sql.aws.backendInstance.instanceClass",
    "sql.aws.backendInstance.parameterGroupName",
    "sql.aws.backendInstance.storageSize",
    "sql.aws.frontendInstance.instanceClass",
    "sql.aws.frontendInstance.parameterGroupName",
    "sql.aws.frontendInstance.storageSize",
    "sql.aws.maintenanceWindow",
    "sql.aws.maxStorageSizeGb",
    "sql.backendInstance.retainedBackups",
    "sql.backendInstance2.aws.instanceEndpoint",
    "sql.frontendInstance.retainedBackups",
  ]
  region = var.region
}

module "sql" {
  source                           = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\sql"
  region                           = var.region
  account_id                       = var.account_id
  default_tags                     = var.default_tags
  backend_backup_retention_period  = module.sql_configs.values["sql.backendInstance.retainedBackups"]
  backend_instance_2_identifier    = length(module.sql_configs.values["sql.backendInstance2.aws.instanceEndpoint"]) > 0 ? split(".", module.sql_configs.values["sql.backendInstance2.aws.instanceEndpoint"])[0] : null
  backend_instance_class           = data.external.backend_sql_configs.result["class"]
  backend_instance_storage         = tonumber(data.external.backend_sql_configs.result["size"])
  backend_long_query_time          = module.sql_configs.values["deploy.sql.slow_query_threshold"]
  backend_multi_instance_count     = length(module.sql_configs.values["sql.backendInstance2.aws.instanceEndpoint"]) > 0 ? 1 : 0
  backend_parameter_group_name     = module.sql_configs.values["sql.aws.backendInstance.parameterGroupName"]
  backend_slow_query_log           = module.sql_configs.values["deploy.sql.enable_slow_query_logs"] ? "1" : "0"
  backup_window                    = module.sql_configs.values["sql.aws.backupWindow"]
  frontend_backup_retention_period = module.sql_configs.values["sql.frontendInstance.retainedBackups"]
  frontend_instance_class          = module.sql_configs.values["sql.aws.frontendInstance.instanceClass"]
  frontend_instance_storage        = module.sql_configs.values["sql.aws.frontendInstance.storageSize"]
  frontend_long_query_time         = module.sql_configs.values["deploy.sql.slow_query_threshold"]
  frontend_parameter_group_name    = module.sql_configs.values["sql.aws.frontendInstance.parameterGroupName"]
  maintenance_window               = module.sql_configs.values["sql.aws.maintenanceWindow"]
  max_storage                      = module.sql_configs.values["sql.aws.maxStorageSizeGb"]
  rds_security_group               = module.network.rds_security_group_id
  rds_subnets                      = module.network.rds_subnet_ids
}


module "elasticache" {
  source                = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\elasticache"
  elasticache_vpc_id    = module.network.vpc_id
  eks_private_subnet_id = module.network.eks_private_subnet_id
  eks_security_group_id = module.eks_phase_1.cluster_security_group_id
}


module "deploy_build_image" {
  source      = "./dedicated_image"
  account_id  = var.account_id
  region      = var.region
  repo_name   = module.lambda_ecr_repos.repo_names["aws_deploy_build"]
  version_tag = var.version_tag
}

# We create the deploy_build function in aws accounts by applying a cloudformation template. To be able to manage it
# with terraform, we need to import the existing resource to our statefile, otherwise we would run into 409s
# Note this is intentionally NOT in full_terraform_imports.py because this resource will always need to be imported
# after the CFT bootstrap is installed. The other imports from full_terraform_imports.py only need to run on
# pre-existing deployments, and the script itself can be deleted after a few release cycles).
import {
  to = module.deploy_build.aws_lambda_function.deploy_build
  id = "deploy_build"
}

module "deploy_build" {
  source                 = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\deploy_build"
  image_uri              = module.deploy_build_image.image_uri
  region                 = var.region
  allow_untrusted_images = var.allow_untrusted_images
}

module "upgrade_opensearch_nodepool_image" {
  source      = "./dedicated_image"
  account_id  = var.account_id
  region      = var.region
  repo_name   = module.lambda_ecr_repos.repo_names["upgrade_opensearch_nodepool"]
  version_tag = var.version_tag
}

module "upgrade_opensearch_nodepool" {
  source                          = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\upgrade_opensearch_nodepool"
  image_uri                       = module.upgrade_opensearch_nodepool_image.image_uri
  region                          = var.region
  account_id                      = var.account_id
  cluster_name                    = module.eks_phase_1.cluster_name
  default_tags                    = var.default_tags
  iam_permissions_boundary_arn    = var.iam_permissions_boundary_arn
  config_bucket_reader_policy_arn = module.s3.config_bucket_reader_policy_arn
  lambda_security_group_id        = module.network.lambda_security_group_id
  lambda_subnet_id                = module.network.lambda_subnet_id
  storage_secrets_key_arn         = module.kms.storage_secrets_key_arn
}

module "expunge_deleted_opensearch_docs_image" {
  source      = "./dedicated_image"
  account_id  = var.account_id
  region      = var.region
  repo_name   = module.lambda_ecr_repos.repo_names["expunge_deleted_opensearch_docs"]
  version_tag = var.version_tag
}

module "expunge_deleted_opensearch_docs" {
  source                          = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\expunge_deleted_opensearch_docs"
  image_uri                       = module.expunge_deleted_opensearch_docs_image.image_uri
  region                          = var.region
  account_id                      = var.account_id
  cluster_name                    = module.eks_phase_1.cluster_name
  config_bucket_reader_policy_arn = module.s3.config_bucket_reader_policy_arn
  lambda_security_group_id        = module.network.lambda_security_group_id
  lambda_subnet_id                = module.network.lambda_subnet_id
  iam_permissions_boundary_arn    = var.iam_permissions_boundary_arn
}

module "ingress_logs_processor_image" {
  source      = "./dedicated_image"
  account_id  = var.account_id
  region      = var.region
  repo_name   = module.lambda_ecr_repos.repo_names["ingress_logs_processor"]
  version_tag = var.version_tag
}

module "ingress_logs_processor" {
  source                          = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\ingress_logs_processor"
  region                          = var.region
  image_uri                       = module.ingress_logs_processor_image.image_uri
  account_id                      = var.account_id
  default_tags                    = var.default_tags
  iam_permissions_boundary_arn    = var.iam_permissions_boundary_arn
  config_bucket_reader_policy_arn = module.s3.config_bucket_reader_policy_arn
  ingress_logs_bucket             = module.s3.ingress_logs_bucket
  ingress_logs_bucket_arn         = module.s3.ingress_logs_bucket_arn
  gcp_connector_project_id        = var.gcp_connector_project_id
  gcp_connector_project_number    = var.gcp_connector_project_number
}

module "s3_exporter_image" {
  source      = "./dedicated_image"
  account_id  = var.account_id
  region      = var.region
  repo_name   = module.lambda_ecr_repos.repo_names["s3_exporter"]
  version_tag = var.version_tag
}

module "s3_exporter" {
  source                       = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\s3_exporter"
  region                       = var.region
  image_uri                    = module.s3_exporter_image.image_uri
  account_id                   = var.account_id
  default_tags                 = var.default_tags
  iam_permissions_boundary_arn = var.iam_permissions_boundary_arn
}

module "probe_initiator_image" {
  source      = "./dedicated_image"
  account_id  = var.account_id
  region      = var.region
  repo_name   = module.lambda_ecr_repos.repo_names["probe_initiator"]
  version_tag = var.version_tag
}

module "probe_initiator" {
  source                          = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\probe_initiator"
  image_uri                       = module.probe_initiator_image.image_uri
  region                          = var.region
  account_id                      = var.account_id
  default_tags                    = var.default_tags
  iam_permissions_boundary_arn    = var.iam_permissions_boundary_arn
  config_bucket_reader_policy_arn = module.s3.config_bucket_reader_policy_arn
  lambda_security_group_id        = module.network.lambda_security_group_id
  lambda_subnet_id                = module.network.lambda_subnet_id
}

module "flink_direct_memory_oom_detection_image" {
  source      = "./dedicated_image"
  account_id  = var.account_id
  region      = var.region
  repo_name   = module.lambda_ecr_repos.repo_names["flink_direct_memory_oom_detection"]
  version_tag = var.version_tag
}


module "flink_direct_memory_oom_detection" {
  source                           = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\flink_direct_memory_oom_detection"
  region                           = var.region
  account_id                       = var.account_id
  image_uri                        = module.flink_direct_memory_oom_detection_image.image_uri
  default_tags                     = var.default_tags
  iam_permissions_boundary_arn     = var.iam_permissions_boundary_arn
  config_bucket_reader_policy_arn  = module.s3.config_bucket_reader_policy_arn
  fluent_bit_application_log_group = module.stackdriver_exporter.fluent_bit_application_log_group_name
  lambda_security_group_id         = module.network.lambda_security_group_id
  lambda_subnet_id                 = module.network.lambda_subnet_id
  gcp_connector_project_id         = var.gcp_connector_project_id
  gcp_connector_project_number     = var.gcp_connector_project_number
}

module "cloudwatch_metrics_exporter_phase_1" {
  source                                             = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\cloudwatch_metrics_exporter_phase_1"
  region                                             = var.region
  default_tags                                       = var.default_tags
  iam_permissions_boundary_arn                       = var.iam_permissions_boundary_arn
  cloud_watch_exporter_gcp_service_account_client_id = var.gcp_collector_service_account_client_id
}

module "git_crawler_configs" {
  source              = "./read_config"
  account_id          = var.account_id
  default_config_path = var.default_config_path
  keys = [
    "deploy.git_crawler.aws_machine_type",
    "git.vmCrawler.persistentDiskSize"
  ]
  region = var.region
}

module "git_crawler_image" {
  source      = "./image_uri"
  repo_name   = "git-crawler"
  version_tag = var.version_tag
}

module "git_crawler" {
  source                          = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\git_crawler"
  region                          = var.region
  machine_type                    = module.git_crawler_configs.values["deploy.git_crawler.aws_machine_type"]
  image_uri                       = module.git_crawler_image.image_uri
  default_tags                    = var.default_tags
  git_crawler_subnet_id           = module.network.git_crawler_subnet_id
  git_crawler_security_group      = module.network.git_crawler_security_group_id
  disk_size                       = replace(module.git_crawler_configs.values["git.vmCrawler.persistentDiskSize"], "GB", "")
  availability_zone               = module.network.git_crawler_availability_zone
  account_id                      = var.account_id
  iam_permissions_boundary_arn    = var.iam_permissions_boundary_arn
  cloud_watch_logs_policy_arn     = module.eks_phase_1.cloudwatch_logs_policy_arn
  config_bucket_reader_policy_arn = module.s3.config_bucket_reader_policy_arn
  crawl_temp_bucket               = module.s3.crawl_temp_bucket
  crawl_temp_bucket_arn           = module.s3.crawl_temp_bucket_arn
}


module "waf_configs_read" {
  source     = "./read_config"
  region     = var.region
  account_id = var.account_id
  keys = concat([
    for endpoint in local.rate_limited_endpoints : "waf.rateLimiting.${endpoint}.count"
    ], [
    for endpoint in local.rate_limited_endpoints : "waf.rateLimiting.${endpoint}.intervalSec"
    ], [
    "waf.countryRedList",
    "waf.ipRedList",
    "waf.ipGreenList",
    "waf.enableModSecurity",
    "waf.awsAnonymousIpPreview.enabled",
    "waf.awsAnonymousIpEnforcement.enabled",
    "waf.awsIpWafRuleListsPreview.enabled",
    "waf.awsIpWafRuleListsEnforcement.modules",
  ])
  default_config_path = var.default_config_path
}

module "waf" {
  source                           = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\waf"
  region                           = var.region
  default_tags                     = var.default_tags
  actas_rate_limiting_count        = local.throttle_counts["actas"]
  autocomplete_rate_limiting_count = local.throttle_counts["autocomplete"]
  ask_rate_limiting_count          = local.throttle_counts["ask"]
  search_rate_limiting_count       = local.throttle_counts["search"]
  country_red_list                 = local.waf_configs["waf.countryRedList"] == "" ? [] : split(",", local.waf_configs["waf.countryRedList"])
  ip_red_list                      = local.waf_configs["waf.ipRedList"] == "" ? [] : split(",", local.waf_configs["waf.ipRedList"])
  ip_green_list                    = local.waf_configs["waf.ipGreenList"] == "" ? [] : split(",", local.waf_configs["waf.ipGreenList"])
  nat_gateway_public_ip            = module.network.nat_gateway_public_ip
  enforce_baseline_rule_set        = local.waf_configs["waf.enableModSecurity"]
  anonymous_ip_preview             = local.waf_configs["waf.awsAnonymousIpPreview.enabled"]
  anonymous_ip_enforcement         = local.waf_configs["waf.awsAnonymousIpEnforcement.enabled"]
  ip_waf_rule_lists_preview        = local.waf_configs["waf.awsIpWafRuleListsPreview.enabled"]
  ip_waf_rule_lists_enforcement    = local.waf_configs["waf.awsIpWafRuleListsEnforcement.modules"] == "" ? [] : split(",", local.waf_configs["waf.awsIpWafRuleListsEnforcement.modules"])
  allow_canary_ipjc_ingress        = var.allow_canary_ipjc_ingress
}


module "proxy_image" {
  source      = "./image_uri"
  repo_name   = "proxy"
  version_tag = var.version_tag
}

module "proxy" {
  count                        = local.should_create_proxy ? 1 : 0
  source                       = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\modules\\proxy"
  account_id                   = var.account_id
  region                       = var.region
  iam_permissions_boundary_arn = var.iam_permissions_boundary_arn
  transit_vpc_cidr             = local.proxy_configs["transit_vpc_cidr"]
  proxy_image                  = module.proxy_image.image_uri

  eks_cluster_security_group_id = module.eks_phase_1.cluster_security_group_id

  proxy_remote_subnets = local.proxy_configs["proxy_remote_subnets"] == "" ? [] : split(",", local.proxy_configs["proxy_remote_subnets"])
  proxy_onprem_ips     = local.proxy_configs["proxy_onprem_ips"] == "" ? [] : split(",", local.proxy_configs["proxy_onprem_ips"])
  proxy_nameservers    = local.proxy_configs["proxy_nameservers"] == "" ? [] : split(",", local.proxy_configs["proxy_nameservers"])
  onprem_host_aliases = local.proxy_configs["onprem_host_aliases"] == "" ? {} : {
    for kv in split(",", local.proxy_configs["onprem_host_aliases"]) : split("=", kv)[0] => split("=", kv)[1]
  }
  vpn_peer_ip               = local.proxy_configs["vpn_peer_ip"]
  vpn_shared_secret         = lookup(local.proxy_configs, "vpn_shared_secret", null) == null ? null : local.proxy_configs["vpn_shared_secret"]
  transit_gateway_peering   = local.proxy_configs["transit_gateway_peering"]
  default_tags              = var.default_tags
  tgw_peer_account_id       = lookup(local.proxy_configs, "tgw_peer_account_id", null)
  tgw_peer_region           = lookup(local.proxy_configs, "tgw_peer_region", null)
  tgw_peer_gateway_id       = lookup(local.proxy_configs, "tgw_peer_gateway_id", null)
  tgw_peered_attachment_id  = lookup(local.proxy_configs, "tgw_peered_attachment_id", null)
  bastion_security_group_id = module.network.bastion_security_group_id
  cluster_security_group_id = module.eks_phase_1.cluster_security_group_id
  eks_private_subnet_az     = module.network.eks_private_subnet_az
  eks_private_subnet_id     = module.network.eks_private_subnet_id
  glean_vpc_cidr_block      = module.network.vpc_cidr_block
  glean_vpc_id              = module.network.vpc_id
  dse_internal_lb_hostname  = module.k8s.dse_internal_lb_service_hostname
}

resource "null_resource" "delete_old_proxy_tgw" {
  count = local.proxy_old_tgw_to_delete == null ? 0 : 1
  provisioner "local-exec" {
    command = "python ${path.module}/scripts/delete_old_proxy_tgw.py"
    # Environment vars are preferred over cmd line args to avoid injections
    environment = {
      REGION        = var.region,
      TGW_TO_DELETE = local.proxy_old_tgw_to_delete
    }
  }
  triggers = {
    tgw_to_delete = local.proxy_old_tgw_to_delete,
    region        = var.region,
  }
}

module "deploy_image" {
  source      = "./image_uri"
  repo_name   = "aws_deploy"
  version_tag = var.version_tag
}

module "config_handler_image" {
  source      = "./image_uri"
  repo_name   = "config_handler"
  version_tag = var.version_tag
}


module "rabbitmq_config_read" {
  source     = "./read_config"
  region     = var.region
  account_id = var.account_id
  keys = [
    for key in local.rabbitmq_config_keys_to_read : "rabbitmq.${key}"
  ]
  default_config_path = var.default_config_path
  custom_config_path  = var.custom_config_path
}


module "k8s_deployment_configs" {
  source              = "./read_config"
  region              = var.region
  account_id          = var.account_id
  keys                = local.all_k8s_deployment_config_keys
  default_config_path = var.default_config_path
  custom_config_path  = var.custom_config_path
}

module "task_push_image" {
  source      = "./image_uri"
  repo_name   = "task_push_aws"
  version_tag = var.version_tag
}

module "crawler_image" {
  source      = "./image_uri"
  repo_name   = "task_handlers"
  version_tag = var.version_tag
}

module "qp_image" {
  source      = "./image_uri"
  repo_name   = "qp"
  version_tag = var.version_tag
}

module "clamav_scanner_image" {
  source      = "./image_uri"
  repo_name   = "clamav-scanner"
  version_tag = var.version_tag
}


module "scholastic_image" {
  source      = "./image_uri"
  repo_name   = "scholastic"
  version_tag = var.version_tag
}

module "admin_image" {
  source      = "./image_uri"
  repo_name   = "admin"
  version_tag = var.version_tag
}

module "dse_image" {
  source      = "./image_uri"
  repo_name   = "datasource-events"
  version_tag = var.version_tag
}

module "redis_image" {
  source      = "./image_uri"
  repo_name   = "redis"
  version_tag = var.version_tag
}

module "qe_image" {
  source      = "./image_uri"
  repo_name   = "qe"
  version_tag = var.version_tag
}

module "clamav_image" {
  source      = "./image_uri"
  repo_name   = "clamav"
  version_tag = var.version_tag
}

module "basic_fim_image" {
  source      = "./image_uri"
  repo_name   = "basic-fim"
  version_tag = var.version_tag
}

module "k8s" {
  source              = "C:\\Users\\blueg\\OneDrive\\Documents\\Aflac\\Glean\\Terraform\\terraform_aws_full_deploy\\glean.com\\aws\\k8s\\full_deploy"
  glean_instance_name = var.glean_instance_name
  version_tag         = var.version_tag

  cluster_name         = module.eks_phase_1.cluster_name
  cluster_endpoint     = module.eks_phase_1.cluster_endpoint
  cluster_ca_cert_data = module.eks_phase_1.cluster_ca_cert_data

  # Ensures we only provision the k8s provider after the bastion connection is open
  bastion_port = var.use_bastion ? data.external.ssh_tunnel[0].result["port"] : null

  kubernetes_token_command                 = "aws"
  kubernetes_token_generation_command_args = ["eks", "get-token", "--cluster-name", module.eks_phase_1.cluster_name]

  service_account_iam_annotation_key = "eks.amazonaws.com/role-arn"
  service_account_iam_annotations = {
    deploy_jobs        = aws_iam_role.deploy_job_role.arn
    cluster_autoscaler = aws_iam_role.cluster_autoscaler_role.arn
    dse                = aws_iam_role.dse.arn
    qe                 = aws_iam_role.qe_iam_role.arn
    crawler            = aws_iam_role.task_handlers_iam_role.arn
    qp                 = aws_iam_role.query_parser_iam_role.arn
    scholastic         = aws_iam_role.scholastic_iam_role.arn
    admin_console      = aws_iam_role.admin_console_iam_role.arn
    task_push          = aws_iam_role.task_push_iam_role.arn
    opensearch_1       = aws_iam_role.elastic_compute_iam_role.arn
    opensearch_2       = aws_iam_role.elastic_compute_iam_role.arn
    cron_job           = aws_iam_role.lambda_invoker_iam_role.arn
    flink_watchdog     = aws_iam_role.flink_watchdog_iam_role.arn
    flink_java_jobs    = aws_iam_role.flink_java_jobs_iam_role.arn
    flink_invoker      = aws_iam_role.flink_invoker_iam_role.arn
    gmp_collector      = aws_iam_role.gmp_collector_role.arn
  }

  deploy_jobs_namespace       = local.deploy_jobs_namespace
  deploy_jobs_service_account = local.deploy_job_k8s_service_account
  deploy_jobs_nodegroup       = module.deploy_job_nodegroup.node_group_name
  nodegroup_node_selector_key = "eks.amazonaws.com/nodegroup"

  default_env_vars     = local.k8s_default_env_vars
  app_name_env_vars    = local.k8s_app_name_env_vars
  referential_env_vars = local.k8s_referential_env_vars

  qp_encrypted_secret_file_name = module.kms.query_secret_object_key
  additional_kms_config_key_values = {
    "secretstore.awskms.keyId" : module.kms.secret_store_key_arn
  }
  deploy_jobs_extra_args = {
    "account_id" : var.account_id,
    "skip_full_tf_check" : "true"
  }

  validated_ssl_cert_id             = module.aws_k8s.validated_ssl_cert_arn
  sql_instance_ids                  = [module.sql.frontend_sql_instance_id, module.sql.backend_sql_instance_id]
  memcached_discovery_endpoints     = module.elasticache.discovery_endpoint
  cluster_autoscaler_cloud_provider = "aws"
  cluster_autoscaler_nodegroup      = module.autoscaler_node_group.node_group_name
  flink_jobs_namespace              = module.flink_namespace_config_reads.values["flink.jobs.namespace"]
  flink_operator_namespace          = module.flink_namespace_config_reads.values["flink.operator.namespace"]

  git_crawler_private_ip = module.git_crawler.git_crawler_private_ip
  proxy_ip               = local.should_create_proxy ? module.proxy[0].proxy_ip : null
  transit_ip             = local.should_create_proxy ? module.proxy[0].transit_ip : null
  additional_proxy_config_updates = {
    "setup.aws.gleanTgwId" : local.should_create_proxy && local.proxy_configs["transit_gateway_peering"] ? module.proxy[0].glean_tgw_id : null
  }
  k8s_service_lb_controller_ids = [
    module.aws_k8s.alb_controller_id
  ]
  private_load_balancer_via_k8s_service_info = {
    load_balancer_name_key   = "alb.ingress.kubernetes.io/name"
    load_balancer_class_name = "service.k8s.aws/nlb"
    common_annotations = {
      "kubernetes.io/ingress.class" : "alb"
      "alb.ingress.kubernetes.io/scheme" : "internal"
      "alb.ingress.kubernetes.io/target-type" : "ip"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" : local.resource_tags_annotation,
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" : "ip",
      "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal",
      # Only permit traffic from within the vpc, otherwise this defaults to 0.0.0.0/0.
      # This is technically not needed since the load balancer is already private, but its good to keep the
      # security group rules locked down anyway.
      "service.beta.kubernetes.io/load-balancer-source-ranges" : module.network.vpc_cidr_block
    }
  }
  rabbitmq_k8s_configs = {
    initial_delay_seconds           = tonumber(local.rabbitmq_config_values["initialDelaySeconds"])
    readiness_check_period_seconds  = tonumber(local.rabbitmq_config_values["readinessCheckPeriodSecs"])
    readiness_check_timeout_seconds = tonumber(local.rabbitmq_config_values["readinessCheckTimeoutSecs"])
    liveness_check_period_seconds   = tonumber(local.rabbitmq_config_values["livenessCheckPeriodSecs"])
    liveness_check_timeout_seconds  = tonumber(local.rabbitmq_config_values["livenessCheckTimeoutSecs"])
    startup_check_period_seconds    = tonumber(local.rabbitmq_config_values["startupCheckPeriodSecs"])
    startup_check_timeout_seconds   = tonumber(local.rabbitmq_config_values["startupCheckTimeoutSecs"])
    startup_check_failure_threshold = tonumber(local.rabbitmq_config_values["startupCheckFailureThreshold"])
    data_disk_size_gi               = local.rabbitmq_disk_size_gi
  }
  rabbitmq_nodegroup = module.rabbitmq_nodegroup.node_group_name
  storage_class_name = module.aws_k8s.ebs_storage_class_name
  # TODO: use platform-agnostic k8s config keys to clean this up
  task_push_k8s_configs      = local.k8s_deployment_to_config["task_push"]
  task_push_nodegroup        = module.task_push_nodegroup.node_group_name
  monitoring_gcp_project_id  = var.gcp_connector_project_id
  crawler_k8s_configs        = local.k8s_deployment_to_config["crawler"]
  qp_k8s_configs             = local.k8s_deployment_to_config["qp"]
  clamav_scanner_k8s_configs = local.k8s_deployment_to_config["clamav_scanner"]
  crawler_nodegroup          = module.crawler_nodegroup.node_group_name

  memory_based_nodegroup_node_selector_info = {
    common_selector_key   = local.memory_based_nodegroup_selector_key
    common_selector_value = local.memory_based_nodegroup_selector_value
    nodegroups = [
      module.memory_based_small_nodegroup.node_group_name,
      module.memory_based_medium_nodegroup.node_group_name,
      module.memory_based_large_nodegroup.node_group_name,
      module.memory_based_xlarge_nodegroup.node_group_name,
    ]
    tolerations = local.memory_based_nodegroup_tolerations
  }
  admin_k8s_configs                   = local.k8s_deployment_to_config["admin"]
  dse_k8s_configs                     = local.k8s_deployment_to_config["dse"]
  scholastic_k8s_configs              = local.k8s_deployment_to_config["scholastic"]
  qe_k8s_configs                      = local.k8s_deployment_to_config["qe"]
  redis_k8s_configs                   = local.redis_k8s_configs
  rollout_id                          = var.rollout_id
  set_google_credentials_file_content = data.local_file.set_google_credentials_in_aws_file.content
  admin_image_uri                     = module.admin_image.image_uri
  config_handler_image_uri            = module.config_handler_image.image_uri
  crawler_image_uri                   = module.crawler_image.image_uri
  deploy_image_uri                    = module.deploy_image.image_uri
  dse_image_uri                       = module.dse_image.image_uri
  qe_image_uri                        = module.qe_image.image_uri
  qp_image_uri                        = module.qp_image.image_uri
  scholastic_image_uri                = module.scholastic_image.image_uri
  task_push_image_uri                 = module.task_push_image.image_uri
  basic_fim_image_uri                 = module.basic_fim_image.image_uri
  clamav_image_uri                    = module.clamav_image.image_uri
  redis_image_uri                     = module.redis_image.image_uri
  redis_nodegroup_selector_key        = local.redis_nodegroup_selector_key
  redis_nodegroup_name                = local.redis_nodegroup_name
  pipelines_list                      = var._do_not_set_manually_pipelines_list
  opensearch_snapshot_secrets         = module.aws_k8s.opensearch_snapshot_secrets
  clamav_scanner_image_uri            = module.clamav_scanner_image.image_uri
  ingress_paths_root                  = var.ingress_paths_root
  public_ingress_annotations = {
    "kubernetes.io/ingress.class" : "alb",
    "alb.ingress.kubernetes.io/name" : "glean-external-lb",
    "alb.ingress.kubernetes.io/scheme" : "internet-facing",
    "alb.ingress.kubernetes.io/target-type" : "ip",
    "alb.ingress.kubernetes.io/listen-ports" : "[{\"HTTPS\":443}]",
    "alb.ingress.kubernetes.io/certificate-arn" : module.acm.ssl_cert_arn,
    "alb.ingress.kubernetes.io/healthcheck-path" : "/liveness_check",
    "alb.ingress.kubernetes.io/healthy-threshold-count" : "3",
    "alb.ingress.kubernetes.io/wafv2-acl-arn" : module.waf.external_web_acl_arn,
    "alb.ingress.kubernetes.io/ssl-policy" : "ELBSecurityPolicy-TLS13-1-2-2021-06",
    "alb.ingress.kubernetes.io/load-balancer-attributes" : "idle_timeout.timeout_seconds=900,access_logs.s3.enabled=true,access_logs.s3.bucket=${module.s3.ingress_logs_bucket}",
    "alb.ingress.kubernetes.io/tags" : local.resource_tags_annotation,
    "alb.ingress.kubernetes.io/ssl-redirect" : "443"
  }
}

module "aws_k8s" {
  source              = "./aws_k8s"
  glean_instance_name = var.glean_instance_name
  version_tag         = var.version_tag

  cluster_name         = module.eks_phase_1.cluster_name
  cluster_endpoint     = module.eks_phase_1.cluster_endpoint
  cluster_ca_cert_data = module.eks_phase_1.cluster_ca_cert_data

  # Ensures we only provision the k8s provider after the bastion connection is open
  bastion_port = var.use_bastion ? data.external.ssh_tunnel[0].result["port"] : null

  kubernetes_token_command                 = "aws"
  kubernetes_token_generation_command_args = ["eks", "get-token", "--cluster-name", module.eks_phase_1.cluster_name]

  deploy_jobs_namespace       = local.deploy_jobs_namespace
  deploy_jobs_service_account = local.deploy_job_k8s_service_account
  deploy_jobs_nodegroup       = module.deploy_job_nodegroup.node_group_name
  nodegroup_node_selector_key = "eks.amazonaws.com/nodegroup"

  default_env_vars     = local.k8s_default_env_vars
  app_name_env_vars    = local.k8s_app_name_env_vars
  referential_env_vars = local.k8s_referential_env_vars

  config_handler_image_uri = module.config_handler_image.image_uri

  initialize_config_job_id               = module.k8s.initialize_config_job_id
  unvalidated_ssl_cert_arn               = module.acm.ssl_cert_arn
  account_id                             = var.account_id
  alb_nodegroup                          = module.alb_node_group.node_group_name
  alb_role_arn                           = aws_iam_role.alb_role.arn
  codebuild_role_arn                     = data.aws_iam_role.codebuild.arn
  cron_helper_role_arn                   = module.cron_helper.cron_helper_role_arn
  default_tags                           = var.default_tags
  deploy_job_role_arn                    = aws_iam_role.deploy_job_role.arn
  eks_worker_node_arn                    = module.eks_phase_1.worker_node_arn
  flink_invoker_role_arn                 = aws_iam_role.flink_invoker_iam_role.arn
  glean_viewer_role_arn                  = data.aws_iam_role.glean_viewer.arn
  gmp_collector_role_arn                 = aws_iam_role.gmp_collector_role.arn
  region                                 = var.region
  self_hosted_airflow_nodes_iam_role_arn = aws_iam_role.self_hosted_airflow_nodes_iam_role.arn
  opensearch_1_namespace                 = module.k8s.opensearch_1_namespace
  opensearch_2_namespace                 = module.k8s.opensearch_2_namespace
  elastic_compute_role_arn               = aws_iam_role.elastic_compute_iam_role.arn
  additional_k8s_admin_role_arns         = var.additional_k8s_admin_role_arns
  external_ingress_lb_host_name          = module.k8s.external_ingress_lb_host_name
}

module "preprocess_sagemaker_training_base_image" {
  source     = "./dedicated_image"
  account_id = var.account_id
  region     = var.region
  repo_name  = module.lambda_ecr_repos.repo_names["glean-sagemaker-training-base"]
  # TODO: currently all of our sagemaker job configs use the latest tag for this image, but really they should be using
  #  release versions
  version_tag = "latest"
}