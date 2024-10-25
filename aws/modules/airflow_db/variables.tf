variable "region" {
  description = "The region to create the lambda function in"
  type        = string
}

variable "airflow_instance_class" {
  description = "The instance class for the airflow sql instance"
  type        = string
}

variable "storage" {
  description = "Initial storage allocated for the rds instance"
  type        = number
  default     = 10
}

variable "max_storage" {
  description = "Maximum storage till which aws will scale up the SQL instance"
  type        = number
  default     = 100
}

variable "mysql_version" {
  description = "The version of the MySQL engine to use for the RDS instances"
  type        = string
  default     = "8.0.32"
}

variable "rds_security_group" {
  description = "Security group id for rds"
  type        = string
}
