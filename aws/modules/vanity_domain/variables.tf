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

variable "vanity_url_domain" {
  description = "The domain for the vanity url, e.g. foo.glean.com"
  type        = string
}

variable "vanity_url_ssl_cert_arn" {
  description = "ARN of the SSL cert to be used for the vanity url CFD"
  type        = string
}