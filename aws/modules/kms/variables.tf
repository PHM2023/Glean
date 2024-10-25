variable "region" {
  description = "The region to use for kms operations"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}

variable "query_secrets_bucket" {
  description = "ID of the query secrets bucket"
  type        = string
}