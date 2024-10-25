variable "run_once" {
  description = "Whether or not to only run this operation once (e.g. for setup only)"
  default     = false
  type        = bool
}

variable "operation" {
  description = "The name of the operation. Should be a valid Glean DeployOperation enum"
  type        = string
}

variable "timeout_minutes" {
  description = "Timeout for job in minutes"
  type        = number
  default     = 20
}

variable "retries" {
  description = "Number of retries to allow"
  type        = number
  default     = 2
}

variable "expand_ops" {
  description = "Whether or not to expand the operation into any sub-operations"
  type        = bool
  default     = false
}

# Since there's only one resource in this module, there's no benefit to making separate variables out of all of these.
# Also, condensing all of these into one lets the caller module reuse a shared object for all the common values
variable "general_info" {
  description = "All inputs that should be (generally) shared by all deploy jobs"
  type = object({
    glean_instance_name             = string
    default_env_vars                = map(string)
    app_name_env_vars               = list(string)
    deploy_image_uri                = string
    deploy_jobs_k8s_service_account = string
    deploy_jobs_namespace           = string
    deploy_jobs_nodegroup           = string
    nodegroup_node_selector_key     = string
    referential_env_vars            = map(string)
    tag                             = string
    extra_args                      = map(string)
  })
}