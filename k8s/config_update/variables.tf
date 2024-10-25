variable "update_name" {
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

variable "path" {
  description = "The path to invoke in the config handler run - should be one of: config_update, ipjc_update"
  type        = string
  validation {
    condition     = contains(["config_update", "ipjc_update"], var.path)
    error_message = "`path` value must be one of: `config_update`, `ipjc_update`"
  }
}

variable "config_key_values" {
  description = "Map of config key values to update - should only be set if `path`==config_update. If any config values are `null` they will be removed from the config if set"
  type        = map(string)
  default     = {}
}

variable "ipjc_channel_path" {
  description = "Channel path to use when making an ipjc update - should only be set if `path`==ipjc_update"
  type        = string
  default     = ""
}

variable "ipjc_request_body" {
  description = "IPJC request body when making an ipjc update - should only be set if `path`==ipjc_update"
  type        = string
  default     = ""
}

variable "general_info" {
  description = "Inputs that should (generally) be shared by all config update jobs"
  type = object({
    version_tag                 = string
    app_name_env_vars           = list(string)
    config_handler_image_uri    = string
    default_env_vars            = map(string)
    namespace                   = string
    nodegroup                   = string
    nodegroup_node_selector_key = string
    referential_env_vars        = map(string)
    service_account             = string
  })
}