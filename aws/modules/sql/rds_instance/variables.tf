variable "instance_class" {
  description = "Instance class (analogous to machine type) for the backend sql instance"
  type        = string
}

variable "instance_identifier" {
  description = "Name of the sql instance"
  type        = string
}

variable "parameter_group_name" {
  description = "Name of the sql instance"
  type        = string
}

variable "storage" {
  description = "Initial storage allocated for the rds instance"
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

variable "maintenance_window" {
  description = "Changes to the rds instance go through in this window (downtime is expected in this window)"
  type        = string
}

variable "backup_window" {
  description = "Backups are created in this time window"
  type        = string
}

variable "backup_retention_period" {
  description = "The number of days to retain backups for"
  type        = number
}

variable "db_subnet_group_name" {
  description = "db subnet group name"
  type        = string
}

variable "db_root_user" {
  description = "identifier for the user with root access"
  type        = string
  default     = "root"
}


variable "monitoring_role_arn" {
  description = "arn of the role which permits rds to send enhanced monitoring metrics to cloudwatch"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to apply to the instance"
  type        = map(string)
  default     = {}
}
