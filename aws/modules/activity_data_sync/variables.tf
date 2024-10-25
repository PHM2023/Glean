variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "region" {
  description = "The region"
  type        = string
  default     = "us-east-1"
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

variable "s3-to-gcs-activity-buckets" {
  description = "Map of s3 bucket name to corresponding gcs bucket name"
  type        = map(string)
}

variable "instance_type" {
  description = "Instance type to use for the datasync agent"
  type        = string
  default     = "m5.2xlarge"
}

variable "skip-agent-activation-key-request" {
  description = "True if we should include the agent activation. Set this to false after the agent has already been created"
  type        = bool
  default     = false
}

variable "gcs_query_metadata_bucket" {
  description = "The id of the query metadata bucket in the corresponding gcp deployment"
  type        = string
}

variable "gcs_elastic_snapshots_bucket" {
  description = "The id of the elastic snapshots bucket in the corresponding gcp deployment"
  type        = string
}