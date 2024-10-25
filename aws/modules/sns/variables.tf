variable "region" {
  description = "The region to use when creating SNS resources"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}
