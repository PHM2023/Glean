variable "region" {
  description = "The region to use for acm resources"
  type        = string
  default     = "us-east-1"
}

variable "subdomain_name" {
  description = "The subdomain name for the glean backend"
  type        = string
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}
