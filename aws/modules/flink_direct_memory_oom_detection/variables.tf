variable "image_uri" {
  description = "The image run by the lambda"
  type        = string
}

variable "region" {
  description = "The region to create the lambda function in"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
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

variable "fluent_bit_application_log_group" {
  description = "Name of the fluent bit application log group"
  type        = string
}

variable "config_bucket_reader_policy_arn" {
  description = "ARN of the config bucket reader IAM policy"
  type        = string
}

variable "lambda_security_group_id" {
  description = "ID of the lambda security group"
  type        = string
}

variable "lambda_subnet_id" {
  description = "ID of the lambda subnet"
  type        = string
}


variable "gcp_connector_project_id" {
  description = "ID of the GCP connector project"
  type        = string
}

variable "gcp_connector_project_number" {
  description = "Number of the GCP connector project"
  type        = string
}
