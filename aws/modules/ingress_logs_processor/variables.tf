variable "image_uri" {
  description = "The image run by the lambda"
  type        = string
}

variable "region" {
  description = "The AWS region to use when creating the buckets"
  type        = string
  default     = "us-east-1"
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

variable "config_bucket_reader_policy_arn" {
  description = "ARN of the config bucket reader IAM policy"
  type        = string
}

variable "ingress_logs_bucket" {
  description = "Ingress logs bucket ID"
  type        = string
}

variable "ingress_logs_bucket_arn" {
  description = "ARN of the ingress logs bucket"
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
