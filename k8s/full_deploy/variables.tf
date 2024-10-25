variable "glean_instance_name" {
  description = "Glean instance name"
  type        = string
}

variable "version_tag" {
  type        = string
  description = "Version tag to use"
}

variable "bastion_port" {
  description = "The port on which to open bastion connections"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the Kubernetes cluster"
  type        = string
}

variable "cluster_ca_cert_data" {
  description = "Base-64 encoded CA cert data for the Kubernetes cluster"
  type        = string
}

variable "kubernetes_token_command" {
  description = "Command to use for generating the K8s auth token for the kubernetes provider"
  type        = string
}

variable "kubernetes_token_generation_command_args" {
  description = "Args to pass to the command used to generate the K8s auth token for the kubernetes provider"
  type        = list(string)
}

variable "deploy_jobs_nodegroup" {
  description = "Name of the nodegroup to use for deploy jobs"
  type        = string
}

variable "deploy_jobs_namespace" {
  description = "Name of the namespace to use for running deploy jobs"
  type        = string
}

variable "deploy_jobs_service_account" {
  description = "Name of the service account to use for running deploy jobs"
  type        = string
}

variable "deploy_jobs_extra_args" {
  description = "Any extra args to pass to all deploy jobs"
  type        = map(string)
  default     = {}
}

variable "service_account_iam_annotation_key" {
  description = "Key for the annotation to add to all service accounts using IAM/web-identity auth, e.g. the role arn in AWS or the service account email in GCP"
  type        = string
}

variable "service_account_iam_annotations" {
  description = "IAM annotation values for each service account"
  type = object({
    deploy_jobs        = string
    cluster_autoscaler = string
    dse                = string
    qe                 = string
    crawler            = string
    qp                 = string
    scholastic         = string
    admin_console      = string
    task_push          = string
    opensearch_1       = string
    opensearch_2       = string
    cron_job           = string
    flink_watchdog     = string
    flink_java_jobs    = string
    flink_invoker      = string
    gmp_collector      = string
  })
}

variable "nodegroup_node_selector_key" {
  description = "Key to use for selecting K8s nodes based on the nodegroup, e.g. eks.amazonaws.com/nodegroup for AWS"
  type        = string
}

variable "default_env_vars" {
  description = "Any default environment variables to attach to k8s workloads"
  type        = map(string)
  default     = {}
}

variable "app_name_env_vars" {
  description = "Any environment variables to attach to k8s workloads based on their app names"
  type        = list(string)
  default     = []
}

variable "referential_env_vars" {
  description = "A mapping of env var -> spec path for all k8s environment variables based on pod specs"
  type        = map(string)
  default     = {}
}

variable "qp_encrypted_secret_file_name" {
  description = "Name of the object used to store the qp secret"
  type        = string
}

variable "additional_kms_config_key_values" {
  description = "Any additional configs to set based on kms resources"
  type        = map(string)
  default     = {}
}

variable "validated_ssl_cert_id" {
  description = "ID of the SSL certificate to use for the external load balancer. The cert should be validated by the cloud provider before being passed in"
  type        = string
}

variable "sql_instance_ids" {
  description = "List of sql instance ids to form a dependency between the sql instance creation and the INITIALIZE_SQL job"
  type        = list(string)
}

variable "memcached_discovery_endpoints" {
  description = "Memcached discovery endpoints to set in the config"
  type        = string
}

variable "cluster_autoscaler_cloud_provider" {
  description = "Cloud provider ID to pass to the cluster autoscaler k8s deployment"
  type        = string
}

variable "cluster_autoscaler_nodegroup" {
  description = "Name of the nodegroup to use for the cluster autoscaler"
  type        = string
}

variable "flink_jobs_namespace" {
  description = "Name of flink jobs namespace"
  type        = string
}

variable "flink_operator_namespace" {
  description = "Name of flink operator namespace"
  type        = string
}

variable "git_crawler_private_ip" {
  description = "IP of the git crawler instance"
  type        = string
}

variable "proxy_ip" {
  description = "IP of proxy connection (for on-prem datasources)"
  type        = string
  default     = null
}

variable "transit_ip" {
  description = "Proxy transit IP"
  type        = string
  default     = null
}

variable "additional_proxy_config_updates" {
  description = "Additional configs to set for the proxy setup"
  type        = map(string)
  default     = {}
}

variable "rabbitmq_nodegroup" {
  description = "Name of the nodegroup to use for rabbitmq workloads"
  type        = string
}

variable "rabbitmq_k8s_configs" {
  description = "Configs needed for the rabbitmq deployment"
  type = object({
    initial_delay_seconds           = number
    readiness_check_period_seconds  = number
    readiness_check_timeout_seconds = number
    liveness_check_period_seconds   = number
    liveness_check_timeout_seconds  = number
    startup_check_period_seconds    = number
    startup_check_timeout_seconds   = number
    startup_check_failure_threshold = number
    data_disk_size_gi               = number

  })
}

variable "storage_class_name" {
  description = "Name of the storage class to use for statefulset volumes"
  type        = string
}

variable "opensearch_snapshot_secrets" {
  description = "Secrets used for opensearch - ID only, not actually used (yet)"
  type        = list(string)
}

variable "k8s_service_lb_controller_ids" {
  description = "IDs for any cloud-platform-specific resources that are needed as dependencies of k8s-provisioned load balancers, i.e. through Service/Ingress resources. Set to an empty list if no platform-specific resources are required"
  type        = list(string)
}

variable "private_load_balancer_via_k8s_service_info" {
  description = "Info for setting annotations on ingress/service resources that provision load balancers"
  type = object({
    load_balancer_name_key   = string
    load_balancer_class_name = string
    common_annotations       = map(string)
  })
}

# NOTE: we have separate image uri variables for each relevant workload, instead of clumping them together in one
# map/list variable. This makes it so that none of the image uri reads are dependent on each other, so that if we want
# to, for example, deploy a custom version of QUERY_PARSER, we don't also need to build the same version of SCHOLASTIC

variable "deploy_image_uri" {
  description = "URI of deploy image to use"
  type        = string
}

variable "config_handler_image_uri" {
  description = "URI of config handler to use"
  type        = string
}

variable "task_push_image_uri" {
  description = "URI of task push image to use"
  type        = string
}

variable "crawler_image_uri" {
  description = "URI of crawler image to use"
  type        = string
}

variable "qp_image_uri" {
  description = "URI of QP image to use"
  type        = string
}

variable "scholastic_image_uri" {
  description = "URI of scholastic image to use"
  type        = string
}

variable "admin_image_uri" {
  description = "URI of admin image to use"
  type        = string
}

variable "dse_image_uri" {
  description = "URI of dse image to use"
  type        = string
}

variable "clamav_scanner_image_uri" {
  description = "URI of clamav scanner image to use"
  type        = string
}

variable "qe_image_uri" {
  description = "URI of qe image to use"
  type        = string
}

variable "redis_image_uri" {
  description = "URI of redis image to use"
  type        = string
}

variable "task_push_nodegroup" {
  description = "Nodegroup to use for task-push workloads"
  type        = string
}

variable "task_push_k8s_configs" {
  description = "Configs needed for the task_push deployment"
  type = object({
    initial_delay_seconds           = number
    readiness_check_period_seconds  = number
    readiness_check_timeout_seconds = number
    liveness_check_period_seconds   = number
    liveness_check_timeout_seconds  = number
    startup_check_period_seconds    = number
    startup_check_timeout_seconds   = number
    startup_check_failure_threshold = number
    autoscaling_max_cpu_percent     = number
    cpu_limit                       = number
    cpu_request                     = number
    memory_limit_gi                 = number
    memory_request_gi               = number
    min_instances                   = number
    max_instances                   = number
  })
}

variable "crawler_nodegroup" {
  description = "Nodegroup to use for crawler k8s deployment"
  type        = string
}

variable "crawler_k8s_configs" {
  description = "Configs needed for the crawler deployment"
  type = object({
    initial_delay_seconds           = number
    readiness_check_period_seconds  = number
    readiness_check_timeout_seconds = number
    liveness_check_period_seconds   = number
    liveness_check_timeout_seconds  = number
    startup_check_period_seconds    = number
    startup_check_timeout_seconds   = number
    startup_check_failure_threshold = number
    autoscaling_max_cpu_percent     = number
    cpu_limit                       = number
    cpu_request                     = number
    memory_limit_gi                 = number
    memory_request_gi               = number
    min_instances                   = number
    max_instances                   = number
  })
}

variable "qp_k8s_configs" {
  description = "Configs needed for the crawler deployment"
  type = object({
    initial_delay_seconds           = number
    readiness_check_period_seconds  = number
    readiness_check_timeout_seconds = number
    liveness_check_period_seconds   = number
    liveness_check_timeout_seconds  = number
    startup_check_period_seconds    = number
    startup_check_timeout_seconds   = number
    startup_check_failure_threshold = number
    autoscaling_max_cpu_percent     = number
    cpu_limit                       = number
    cpu_request                     = number
    memory_limit_gi                 = number
    memory_request_gi               = number
    min_instances                   = number
    max_instances                   = number
  })
}


variable "scholastic_k8s_configs" {
  description = "Configs needed for the crawler deployment"
  type = object({
    initial_delay_seconds           = number
    readiness_check_period_seconds  = number
    readiness_check_timeout_seconds = number
    liveness_check_period_seconds   = number
    liveness_check_timeout_seconds  = number
    startup_check_period_seconds    = number
    startup_check_timeout_seconds   = number
    startup_check_failure_threshold = number
    autoscaling_max_cpu_percent     = number
    cpu_limit                       = number
    cpu_request                     = number
    memory_limit_gi                 = number
    memory_request_gi               = number
    min_instances                   = number
    max_instances                   = number
  })
}


variable "admin_k8s_configs" {
  description = "Configs needed for the crawler deployment"
  type = object({
    initial_delay_seconds           = number
    readiness_check_period_seconds  = number
    readiness_check_timeout_seconds = number
    liveness_check_period_seconds   = number
    liveness_check_timeout_seconds  = number
    startup_check_period_seconds    = number
    startup_check_timeout_seconds   = number
    startup_check_failure_threshold = number
    autoscaling_max_cpu_percent     = number
    cpu_limit                       = number
    cpu_request                     = number
    memory_limit_gi                 = number
    memory_request_gi               = number
    min_instances                   = number
    max_instances                   = number
  })
}


variable "dse_k8s_configs" {
  description = "Configs needed for the crawler deployment"
  type = object({
    initial_delay_seconds           = number
    readiness_check_period_seconds  = number
    readiness_check_timeout_seconds = number
    liveness_check_period_seconds   = number
    liveness_check_timeout_seconds  = number
    startup_check_period_seconds    = number
    startup_check_timeout_seconds   = number
    startup_check_failure_threshold = number
    autoscaling_max_cpu_percent     = number
    cpu_limit                       = number
    cpu_request                     = number
    memory_limit_gi                 = number
    memory_request_gi               = number
    min_instances                   = number
    max_instances                   = number
  })
}


variable "qe_k8s_configs" {
  description = "Configs needed for the crawler deployment"
  type = object({
    initial_delay_seconds           = number
    readiness_check_period_seconds  = number
    readiness_check_timeout_seconds = number
    liveness_check_period_seconds   = number
    liveness_check_timeout_seconds  = number
    startup_check_period_seconds    = number
    startup_check_timeout_seconds   = number
    startup_check_failure_threshold = number
    autoscaling_max_cpu_percent     = number
    cpu_limit                       = number
    cpu_request                     = number
    memory_limit_gi                 = number
    memory_request_gi               = number
    min_instances                   = number
    max_instances                   = number
  })
}

variable "redis_k8s_configs" {
  description = "Configs needed for the crawler deployment"
  type = object({
    initial_delay_seconds           = number
    readiness_check_period_seconds  = number
    readiness_check_timeout_seconds = number
    liveness_check_period_seconds   = number
    liveness_check_timeout_seconds  = number
    startup_check_period_seconds    = number
    startup_check_timeout_seconds   = number
    startup_check_failure_threshold = number
    cpu_limit                       = number
    cpu_request                     = number
    memory_limit_gi                 = number
    memory_request_gi               = number
    min_instances                   = number
    max_instances                   = number
    storage_request_gi              = number
  })
}

variable "clamav_scanner_k8s_configs" {
  description = "Configs needed for the clamav scanner deployment"
  type = object({
    initial_delay_seconds           = number
    readiness_check_period_seconds  = number
    readiness_check_timeout_seconds = number
    liveness_check_period_seconds   = number
    liveness_check_timeout_seconds  = number
    startup_check_period_seconds    = number
    startup_check_timeout_seconds   = number
    startup_check_failure_threshold = number
    autoscaling_max_cpu_percent     = number
    cpu_limit                       = number
    cpu_request                     = number
    memory_limit_gi                 = number
    memory_request_gi               = number
    min_instances                   = number
    max_instances                   = number
  })
}

variable "monitoring_gcp_project_id" {
  description = "The gcp project id to use for monitoring and observability"
  type        = string
}

variable "memory_based_nodegroup_node_selector_info" {
  description = "Info for selecting nodegroups among memory-based workloads"
  type = object({
    common_selector_key   = string
    common_selector_value = string
    nodegroups            = list(string)
    tolerations = list(object({
      key      = string
      operator = string
      value    = string
      effect   = string
    }))
  })
}

variable "rollout_id" {
  description = "Rollout ID to use for each restartable k8s app. If this changes, the app will be restarted"
  type        = string
}

variable "set_google_credentials_file_content" {
  description = "Contents of the relevant set-google-credentials-script"
  type        = string
}

variable "clamav_image_uri" {
  description = "URI of image to use for clamav daemonset"
  type        = string
}

variable "basic_fim_image_uri" {
  description = "URI of image to use for basic-fim daemonset"
  type        = string
}

variable "redis_nodegroup_selector_key" {
  description = "Key to use for redis nodegroup selector"
  type        = string
}

variable "redis_nodegroup_name" {
  description = "Nodegroup name to use for redis"
  type        = string
}

variable "pipelines_list" {
  description = "List of Glean pipelines jobs to run"
  type        = list(string)
}

variable "ingress_paths_root" {
  description = "Path to folder container all yamls with relevant k8s ingress rules"
  type        = string
}

variable "public_ingress_annotations" {
  description = "Annotations to attach to the public ingress resource (external load balancer)"
  type        = map(string)
}
