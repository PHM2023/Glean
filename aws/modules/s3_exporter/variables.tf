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