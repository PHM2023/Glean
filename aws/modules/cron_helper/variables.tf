variable "image_uri" {
  description = "The image run by the lambda"
  type        = string
}

variable "region" {
  description = "The region to create the lambda function in"
  type        = string
}

variable "account_id" {
  description = "The account id"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
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

variable "lambda_security_group_id" {
  description = "ID of the lambda security group"
  type        = string
}

variable "lambda_subnet_id" {
  description = "ID of the lambda subnet"
  type        = string
}

variable "storage_secret_key_arn" {
  description = "ARN of the storage_secrets key"
  type        = string
}

variable "ipjc_key_arn" {
  description = "ARN of the ipjc signing key"
  type        = string
}

variable "config_bucket_reader_policy_arn" {
  description = "ARN of the config bucket reader IAM policy"
  type        = string
}

variable "eks_worker_node_arn" {
  description = "ARN of the eks worker node IAM role"
  type        = string
}

variable "eks_cluster_role_arn" {
  description = "ARN of eks cluster role"
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
