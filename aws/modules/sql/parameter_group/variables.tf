variable "parameter_group_name" {
  type        = string
  description = "Name of the parameter group"
}

variable "character_set_server" {
  type        = string
  description = "character_set_server"
  default     = "utf8mb4"
}

variable "event_scheduler" {
  type        = string
  description = "event_scheduler"
  default     = "on"
}

variable "innodb_online_alter_log_max_size" {
  type        = string
  description = "innodb_online_alter_log_max_size"
  default     = "536870912"
}

variable "log_bin_trust_function_creators" {
  type        = string
  description = "log_bin_trust_function_creators"
  default     = "1"
}

variable "log_output" {
  type        = string
  description = "log_output"
  default     = "FILE"
}

variable "long_query_time" {
  type        = string
  description = "long_query_time"
}

variable "max_allowed_packet" {
  type        = string
  description = "max_allowed_packet"
  default     = "1073741824"
}

variable "slow_query_log" {
  type        = string
  description = "slow_query_log"
}

variable "max_connections" {
  type        = string
  description = "max_connections"
  # NOTE: The following value is a reasonable default for our workloads (typically need only O(100) connections)
  # But each of these instance classes have limits on the number of max connections
  # So in case of making this field a configurable quantity in the future,
  # consider the limit for the instance class as well
  default = "1000"
}

variable "instance_specific_flags" {
  description = "Additional instance-specific parameters"
  type        = map(string)
  default     = {}
}
variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}
