variable "region" {
  description = "The region"
  type        = string
  default     = "us-east-1"
}

variable "machine_type" {
  description = "machine type"
  type        = string
  default     = "t3.medium"
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}

variable "image_uri" {
  description = "git crawler image uri"
  type        = string
}

variable "git_crawler_subnet_id" {
  description = "ID of private subnet for git-crawler instance."
  type        = string
}

variable "git_crawler_security_group" {
  description = "Security group id for git-crawler instance"
  type        = string
}

variable "disk_size" {
  description = "ebs disk size"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for git-crawler instance"
  type        = string
}

variable "account_id" {
  description = "aws account id"
  type        = string
}

variable "iam_permissions_boundary_arn" {
  description = "Permissions boundary to apply to all IAM roles created by this module"
  type        = string
  default     = null
}

variable "crawl_temp_bucket" {
  description = "ID of the crawl temp bucket"
  type        = string
}

variable "crawl_temp_bucket_arn" {
  description = "ARN of the crawl temp bucket"
  type        = string
}

variable "cloud_watch_logs_policy_arn" {
  description = "ARN of the glean cloudwatch logs IAM policy"
  type        = string
}

variable "config_bucket_reader_policy_arn" {
  description = "ARN of the config bucket reader policy"
  type        = string
}