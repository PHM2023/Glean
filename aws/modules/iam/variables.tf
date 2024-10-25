variable "region" {
  description = "The region"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "iam_permissions_boundary_arn" {
  description = "Permissions boundary to apply to all IAM roles created by this module"
  type        = string
  default     = null
}