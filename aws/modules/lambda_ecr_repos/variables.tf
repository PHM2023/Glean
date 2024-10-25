variable "region" {
  description = "The region"
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
