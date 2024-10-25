variable "repo_name" {
  description = "ECR repository name"
  type        = string
}

variable "version_tag" {
  description = "Glean version tag"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "region" {
  description = "AWS region to push/pull the image to/from"
  type        = string
}