variable "region" {
  description = "The region to create the lambda function in"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "db_user" {
  description = "The MySQL user name for the main user of RDS instances"
  type        = string
  default     = "glean"
}

variable "db_debug_user" {
  description = "The MySQL user name for a user with read-only (debug) access to RDS instances"
  type        = string
  default     = "glean_debug"
}


variable "backend_parameter_group_name" {
  description = "Name of the backend instance parameter group"
  type        = string
}

variable "backend_long_query_time" {
  description = "long_query_time db param value for backend instance"
  type        = string
}

variable "backend_slow_query_log" {
  description = "slow_query_log db param value for backend instance"
  type        = string
}

variable "backend_instance_class" {
  description = "The instance class for the backend sql instance"
  type        = string
}

variable "backend_instance_identifier" {
  description = "Name of the backend sql instance"
  type        = string
  default     = "be-instance"
}

variable "backend_instance_2_identifier" {
  description = "The instance identifier for the second instance for multi backend instances"
  type        = string
}

variable "backend_multi_instance_count" {
  description = "The count of second multi instance (should be 0 or 1 to indicated disabled/enabled)"
  type        = number
}

variable "frontend_parameter_group_name" {
  description = "Name of the frontend instance parameter group"
  type        = string
}

variable "frontend_long_query_time" {
  description = "long_query_time db param value for frontend instance"
  type        = string
}

variable "frontend_slow_query_log" {
  description = "slow_query_log db param value for frontend instance"
  type        = string
  default     = "1"
}

variable "frontend_instance_class" {
  description = "The instance class for the frontend sql instance"
  type        = string
}

variable "frontend_instance_identifier" {
  description = "Name of the frontend sql instance"
  type        = string
  default     = "fe-instance"
}

variable "frontend_instance_storage" {
  description = "Initial storage allocated for the frontend instance"
  type        = number
}

variable "backend_instance_storage" {
  description = "Initial storage allocated for the frontend instance"
  type        = number
}

variable "max_storage" {
  description = "Maximum storage till which aws will scale up the SQL instance"
  type        = number
}

variable "mysql_version" {
  description = "The version of the MySQL engine to use for the RDS instances"
  type        = string
  default     = "8.0.35"
}

variable "rds_security_group" {
  description = "Security group id for rds"
  type        = string
}

variable "rds_subnets" {
  description = "subnets used by rds"
  type        = list(string)
}

variable "maintenance_window" {
  description = "Changes to the rds instance go through in this window (downtime is expected in this window)"
  type        = string
}

variable "backup_window" {
  description = "Backups are created in this time window"
  type        = string
}

variable "frontend_backup_retention_period" {
  description = "The number of days to retain the backups for the frontend instance"
  type        = number
}

variable "backend_backup_retention_period" {
  description = "The number of days to retain the backups for the backend instance"
  type        = number
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}

variable "iam_permissions_boundary_arn" {
  description = "Permissions boundary to apply to all IAM roles created by this module"
  type        = string
  default     = null
}
