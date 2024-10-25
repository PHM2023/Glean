variable "app" {
  description = "Name of the k8s app"
  type        = string
}


variable "k8s_service_account" {
  description = "Name of the k8s service account to use"
  type        = string
}

variable "version_tag" {
  description = "Version tag to use for the workload image"
  type        = string
}

variable "progress_deadline_seconds" {
  description = "How long to wait for progress of the deployment"
  type        = number
  default     = 1500
}

variable "liveness_timeout_seconds" {
  description = "Timeout for liveness checks"
  type        = number
}

variable "liveness_period_seconds" {
  description = "Period for liveness checks"
  type        = number
}

variable "liveness_failure_threshold" {
  description = "Failure threshold for liveness checks"
  type        = number
  default     = 2
}

variable "startup_timeout_seconds" {
  description = "Timeout of startup checks"
  type        = number
}

variable "startup_period_seconds" {
  description = "Period of startup checks"
  type        = number
}

variable "startup_failure_threshold" {
  description = "Failure threshold for startup checks"
  type        = number
}

variable "startup_check_path" {
  description = "HTTP path for startup checks"
  type        = string
  default     = "/readiness_check"
}


variable "readiness_check_path" {
  description = "HTTP path for readiness checks"
  type        = string
  default     = "/readiness_check"
}

variable "liveness_check_path" {
  description = "HTTP path for liveness checks"
  type        = string
  default     = "/liveness_check"
}

variable "cpu_limit" {
  description = "Limit for cpu"
  type        = number
}

variable "cpu_request" {
  description = "Request for cpu"
  type        = number
}

variable "memory_limit" {
  description = "Limit for memory in Gi"
  type        = number
}

variable "memory_request" {
  description = "Request for memory in Gi"
  type        = number
}

variable "min_instances" {
  description = "Min number of pods to scale down to"
  type        = number
}

variable "max_instances" {
  description = "Max number of pods to scale up to"
  type        = number
}

variable "autoscaling_max_cpu_percent" {
  description = "CPU percent to trigger scale up"
  type        = number
}

variable "default_env_vars" {
  description = "Static value env vars"
  type        = map(string)
}

variable "referential_env_vars" {
  description = "Env vars that reference specific k8s fields, e.g. EKS_POD_NAME -> spec.metadata.name"
  type        = map(string)
}

variable "app_name_env_vars" {
  description = "Env vars that should use the app name"
  type        = list(string)
}

variable "use_lb_service" {
  description = "Whether or not to use an internal load balancer as the exposing service"
  type        = bool
  default     = false
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}

variable "include_user_local_lib_volume" {
  description = "If true, includes an empty volume mount at /usr/local/lib for any extra libraries to be downloaded"
  type        = bool
  default     = false
}

variable "image_uri" {
  description = "Image URI of main deployment container"
  type        = string
}


variable "required_nodegroup_node_selector_key" {
  description = "Key to use for selecting K8s nodes based on the nodegroup, e.g. eks.amazonaws.com/nodegroup for AWS"
  type        = string
}

variable "termination_grace_period_seconds" {
  description = "The termination grace period for each pod"
  type        = number
  default     = 60
}

variable "required_nodegroup_node_selector_value" {
  description = "Name of the nodegroup to pass to the node selector"
  type        = string
}

variable "k8s_service_lb_controller_ids" {
  description = "IDs for any cloud-platform-specific resources that are needed as dependencies of k8s-provisioned load balancers, i.e. through Service/Ingress resources. Set to an empty list if no platform-specific resources are required"
  type        = list(string)
}

variable "private_load_balancer_via_k8s_service_info" {
  description = "Info for setting annotations on ingress/service resources that provision load balancers"
  type = object({
    load_balancer_name_key   = string
    common_annotations       = map(string)
    load_balancer_class_name = string
  })
}

variable "additional_tolerations" {
  description = "Additional k8s tolerations to add to the deployment pod spec"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "service_name_override" {
  description = "Overrides the kubernetes_service name, which defaults to {var.app}-service"
  type        = string
  default     = null
}

variable "scale_down_stabilization_window_seconds" {
  description = "Stabilization for scale-down HPA behavior"
  type        = number
  default     = 900
}

variable "preferential_node_groups" {
  description = "List of objects describing nodegroup selector key, value, and weights for preferential nodegroup selection"
  type = list(object({
    node_selector_key   = string
    node_selector_value = string
    weight              = number
  }))
  default = []
}

variable "empty_dir_volumes" {
  description = "Additional volumes to add"
  type = list(object({
    name = string
  }))
  default = []
}

variable "volume_mounts" {
  description = "Additional volume mounts to add"
  type = list(object({
    mount_path = string
    read_only  = bool
    name       = string
  }))
  default = []
}

variable "lifecycle_prestop_command" {
  description = "Command to run at the end of the lifecycle before stopping the pod"
  type        = list(string)
  default     = null
}

variable "rollout_id" {
  description = "Rollout ID to use for each k8s app. If this changes, the app will be restarted"
  type        = string
}
