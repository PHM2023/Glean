variable "region" {
  description = "The region to create the deploy_build function in"
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

variable "cloud_watch_exporter_gcp_service_account_client_id" {
  description = "Unique client ID of GCP service account used to export cloudwatch metrics"
  type        = string
}