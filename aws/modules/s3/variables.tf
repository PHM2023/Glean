variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "region" {
  description = "The region to use for s3 bucket operations"
  type        = string
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}

variable "disable_account_bpa" {
  description = "This is for very special customers that want to manage their own AWS account-level S3 BPA settings. This should be FALSE by default."
  type        = bool
  default     = false
}
