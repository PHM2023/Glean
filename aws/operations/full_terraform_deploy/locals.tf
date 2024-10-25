locals {
  k8s_default_env_vars = {
    "ENVIRONMENT" : "PRODUCTION",
    "GLEAN_SERVICE_PLATFORM" : "EKS",
    "CLOUD_PLATFORM" : "AWS",
    "AWS_ACCOUNT_ID" : var.account_id,
    "AWS_REGION" : var.region,
    "AWS_DEFAULT_REGION" : var.region,
    "GOOGLE_CLOUD_PROJECT" : var.gcp_connector_project_id,
    "GOOGLE_PROJECT_NUMBER" : var.gcp_connector_project_number
  }
  k8s_referential_env_vars = {
    "EKS_NODE_NAME" : "spec.nodeName",
    "EKS_POD_NAMESPACE" : "metadata.namespace",
    "EKS_POD_NAME" : "metadata.name",
    "INSTANCE_ID" : "metadata.name"
  }
  k8s_app_name_env_vars = [
    "GAE_SERVICE__GKE_COMPATIBILITY",
    "PROFILER_SERVICE_NAME",
    "EKS_CONTAINER_NAME"
  ]
  core_permission_policies = [
    module.eks_phase_1.cloudwatch_logs_policy_arn,
    module.s3.config_bucket_reader_policy_arn,
    module.kms.secret_store_cryptor_policy_arn,
    module.kms.ipjc_signing_key_sign_policy_arn,
    module.sql.sql_connect_policy_arn
  ]
  rate_limited_endpoints = [
    "actas",
    "autocomplete",
    "ask",
    "search",
  ]
  s3_configs  = module.s3_configs_read.values
  waf_configs = module.waf_configs_read.values
  # Unfortunately terraform doesn't let you configure the window for each throttling rule - it must be 5 minutes.
  # So, we have to take the normal count/interval values and project them over 5 minutes.
  throttle_counts = {
    for endpoint in local.rate_limited_endpoints : endpoint => max(100, tonumber(local.waf_configs["waf.rateLimiting.${endpoint}.count"]) * (300 / tonumber(local.waf_configs["waf.rateLimiting.${endpoint}.intervalSec"])))
  }
  proxy_configs            = data.external.proxy_configs.result
  should_create_proxy      = local.proxy_configs["should_create_proxy"] == "true"
  proxy_old_tgw_to_delete  = lookup(local.proxy_configs, "old_tgw_to_delete", null)
  resource_tags_annotation = join(",", [for k, v in var.default_tags : "${k}=${v}"])

  # TODO: unify this with the other k8s deployables
  rabbitmq_config_keys_to_read = [
    "machineType",
    "dataDiskSizeGi",
    "initialDelaySeconds",
    "livenessCheckPeriodSecs",
    "livenessCheckTimeoutSecs",
    "readinessCheckPeriodSecs",
    "readinessCheckTimeoutSecs",
    "startupCheckPeriodSecs",
    "startupCheckTimeoutSecs",
    "startupCheckFailureThreshold"
  ]
  rabbitmq_config_values = {
    for key, value in module.rabbitmq_config_read.values : replace(key, "rabbitmq.", "") => value
  }
  _rabbitmq_disk_size_from_config = tonumber(local.rabbitmq_config_values["dataDiskSizeGi"])
  _rabbitmq_tier_to_disk_size = {
    "small" : 100,
    "medium" : 200,
    "large" : 400,
    "xlarge" : 800
  }
  # If the variable override is set, use that. Otherwise, use the config override and fall back to the tier mapping
  _rabbitmq_disk_size_gi             = local._rabbitmq_disk_size_from_config != 0 ? local._rabbitmq_disk_size_from_config : local._rabbitmq_tier_to_disk_size[var.initial_deployment_tier]
  rabbitmq_disk_size_gi              = var.rabbitmq_disk_size_override != null ? var.rabbitmq_disk_size_override : local._rabbitmq_disk_size_gi
  _rabbitmq_machine_type_from_config = local.rabbitmq_config_values["machineType"]
  _rabbitmq_tier_to_machine_type = {
    "small" : "c5.large",
    "medium" : "c5.xlarge",
    "large" : "c5.2xlarge",
    "xlarge" : "c5.2xlarge"
  }
  rabbitmq_machine_type = local._rabbitmq_machine_type_from_config != "" ? local._rabbitmq_machine_type_from_config : local._rabbitmq_tier_to_machine_type[var.initial_deployment_tier]
  full_standalone_nodegroup_config_keys = [
    "eks.crawler.machineType",
    "eks.task_push.machineType",
    "eks.redis.machineType",
    "eks.services.diskSizeGi",
    "eks.nodeGroups.memoryBasedSmall.instanceType",
    "eks.nodeGroups.memoryBasedMedium.instanceType",
    "eks.nodeGroups.memoryBasedLarge.instanceType",
    "eks.nodeGroups.memoryBasedXLarge.instanceType",
  ]
  nodegroup_configs = {
    crawler_machine_type   = module.nodegroup_configs.values["eks.crawler.machineType"]
    task_push_machine_type = module.nodegroup_configs.values["eks.task_push.machineType"]
    disk_size_gi           = module.nodegroup_configs.values["eks.services.diskSizeGi"]
    memory_based_instance_types = {
      for type in ["Small", "Medium", "Large", "XLarge"] : lower(type) => module.nodegroup_configs.values["eks.nodeGroups.memoryBased${type}.instanceType"]
    }
  }

  memory_based_nodegroup_taints = [{
    key    = "glean-app"
    value  = "True"
    effect = "NO_SCHEDULE"
    }, {
    key    = "memory-based-workload"
    value  = "True"
    effect = "NO_SCHEDULE"
  }]

  memory_based_nodegroup_tolerations = [
    {
      key      = "memory-based-workload"
      operator = "Equal"
      value    = "True"
      effect   = "NoSchedule"
    }
  ]

  memory_based_nodegroup_selector_key   = "use"
  memory_based_nodegroup_selector_value = "memory-based-workload"

  common_k8s_deployment_config_keys = [
    "PodmCpuRequest",
    "PodmCpuLimit",
    "PodMemoryGiRequest",
    "PodMemoryGiLimit",
    "min_instances",
    "max_instances",
    "AutoscalingMCpuPercent",
    "initialDelaySeconds",
    "readinessCheckTimeoutSecs",
    "readinessCheckPeriodSecs",
    "livenessCheckTimeoutSecs",
    "livenessCheckPeriodSecs",
    "startupCheckPeriodSecs",
    "startupCheckTimeoutSecs",
    "startupFailureThreshold",
  ]

  k8s_deployments_by_config = [
    "task_push",
    "crawler",
    "qp",
    "admin",
    "scholastic",
    "dse",
    "qe",
    "clamav_scanner"
  ]
  redis_configs = [
    "PodmCpuRequest",
    "PodmCpuLimit",
    "PodMemoryGiRequest",
    "PodMemoryGiLimit",
    "min_instances",
    "max_instances",
    "initialDelaySeconds",
    "readinessCheckTimeoutSecs",
    "readinessCheckPeriodSecs",
    "livenessCheckTimeoutSecs",
    "livenessCheckPeriodSecs",
    "startupCheckPeriodSecs",
    "startupCheckTimeoutSecs",
    "startupFailureThreshold",
    "volumeStorageGiRequest"
  ]

  all_k8s_deployment_config_keys = concat([for i, v in setproduct(local.k8s_deployments_by_config, local.common_k8s_deployment_config_keys) : "eks.${v[0]}.${v[1]}"], [for key in local.redis_configs : "eks.redis.${key}"])
  k8s_deployment_to_config = {
    for app in local.k8s_deployments_by_config : app => {
      initial_delay_seconds           = tonumber(module.k8s_deployment_configs.values["eks.${app}.initialDelaySeconds"])
      readiness_check_period_seconds  = tonumber(module.k8s_deployment_configs.values["eks.${app}.readinessCheckPeriodSecs"])
      readiness_check_timeout_seconds = tonumber(module.k8s_deployment_configs.values["eks.${app}.readinessCheckTimeoutSecs"])
      liveness_check_period_seconds   = tonumber(module.k8s_deployment_configs.values["eks.${app}.livenessCheckPeriodSecs"])
      liveness_check_timeout_seconds  = tonumber(module.k8s_deployment_configs.values["eks.${app}.livenessCheckTimeoutSecs"])
      startup_check_period_seconds    = tonumber(module.k8s_deployment_configs.values["eks.${app}.startupCheckPeriodSecs"])
      startup_check_timeout_seconds   = tonumber(module.k8s_deployment_configs.values["eks.${app}.startupCheckTimeoutSecs"])
      startup_check_failure_threshold = tonumber(module.k8s_deployment_configs.values["eks.${app}.startupFailureThreshold"])
      autoscaling_max_cpu_percent     = tonumber(module.k8s_deployment_configs.values["eks.${app}.AutoscalingMCpuPercent"])
      cpu_limit                       = tonumber(module.k8s_deployment_configs.values["eks.${app}.PodmCpuLimit"])
      cpu_request                     = tonumber(module.k8s_deployment_configs.values["eks.${app}.PodmCpuRequest"])
      memory_limit_gi                 = tonumber(module.k8s_deployment_configs.values["eks.${app}.PodMemoryGiLimit"])
      memory_request_gi               = tonumber(module.k8s_deployment_configs.values["eks.${app}.PodMemoryGiRequest"])
      min_instances                   = tonumber(module.k8s_deployment_configs.values["eks.${app}.min_instances"])
      max_instances                   = tonumber(module.k8s_deployment_configs.values["eks.${app}.max_instances"])
    }
  }
  redis_k8s_configs = {
    initial_delay_seconds           = tonumber(module.k8s_deployment_configs.values["eks.redis.initialDelaySeconds"])
    readiness_check_period_seconds  = tonumber(module.k8s_deployment_configs.values["eks.redis.readinessCheckPeriodSecs"])
    readiness_check_timeout_seconds = tonumber(module.k8s_deployment_configs.values["eks.redis.readinessCheckTimeoutSecs"])
    liveness_check_period_seconds   = tonumber(module.k8s_deployment_configs.values["eks.redis.livenessCheckPeriodSecs"])
    liveness_check_timeout_seconds  = tonumber(module.k8s_deployment_configs.values["eks.redis.livenessCheckTimeoutSecs"])
    startup_check_period_seconds    = tonumber(module.k8s_deployment_configs.values["eks.redis.startupCheckPeriodSecs"])
    startup_check_timeout_seconds   = tonumber(module.k8s_deployment_configs.values["eks.redis.startupCheckTimeoutSecs"])
    startup_check_failure_threshold = tonumber(module.k8s_deployment_configs.values["eks.redis.startupFailureThreshold"])
    cpu_limit                       = tonumber(module.k8s_deployment_configs.values["eks.redis.PodmCpuLimit"])
    cpu_request                     = tonumber(module.k8s_deployment_configs.values["eks.redis.PodmCpuRequest"])
    memory_limit_gi                 = tonumber(module.k8s_deployment_configs.values["eks.redis.PodMemoryGiLimit"])
    memory_request_gi               = tonumber(module.k8s_deployment_configs.values["eks.redis.PodMemoryGiRequest"])
    min_instances                   = tonumber(module.k8s_deployment_configs.values["eks.redis.min_instances"])
    max_instances                   = tonumber(module.k8s_deployment_configs.values["eks.redis.max_instances"])
    storage_request_gi              = tonumber(module.k8s_deployment_configs.values["eks.redis.volumeStorageGiRequest"])
  }
  # Store a mapping of instance_type -> nodegroup for memory-based workloads so redis can infer what nodegroup to use
  _memory_based_instance_types_to_nodegroup_name = {
    (local.nodegroup_configs.memory_based_instance_types["small"]) : module.memory_based_small_nodegroup.node_group_name,
    (local.nodegroup_configs.memory_based_instance_types["medium"]) : module.memory_based_small_nodegroup.node_group_name,
    (local.nodegroup_configs.memory_based_instance_types["large"]) : module.memory_based_small_nodegroup.node_group_name,
    (local.nodegroup_configs.memory_based_instance_types["xlarge"]) : module.memory_based_small_nodegroup.node_group_name,
  }
  # Redis can choose among all of the memory-based nodegroups based on it's machineType config. If the machineType
  # is set to an instance type that is not offered among the memory-based nodegroups, this will fail
  # TODO: We should probably be using a dedicated nodegroup for redis, but this was effectively how we were doing it before
  redis_nodegroup_name = var._pre_existing_redis_nodegroup_name != null ? var._pre_existing_redis_nodegroup_name : local._memory_based_instance_types_to_nodegroup_name[module.nodegroup_configs.values["eks.redis.machineType"]]
  # If we're using an old nodegroup, then we should use the glean.com node pool selector. Otherwise, use the default eks one
  redis_nodegroup_selector_key = var._pre_existing_redis_nodegroup_name != null ? "glean.com/node-pool-selector" : "eks.amazonaws.com/nodegroup"

  ingress_resource_tags_annotation = join(",", [for k, v in var.default_tags : "${k}=${v}"])
}
