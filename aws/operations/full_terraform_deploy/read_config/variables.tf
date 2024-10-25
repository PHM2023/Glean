variable "region" {
  description = "The AWS region in which to deploy Glean"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID to use"
  type        = string
}

variable "keys" {
  description = "List of config keys to read"
  type        = list(string)
}

variable "default_config_path" {
  description = "Path to default.ini file"
  type        = string
}

variable "custom_config_path" {
  type        = string
  description = "Path to custom.ini config file (if set)"
  default     = null
}
