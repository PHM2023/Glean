variable "region" {
  description = "The region in which the api calls made for management account"
  type        = string
}

variable "cloudformation_bootstrap_template_uri" {
  description = "Cloudformation bootstrap template uri"
  type        = string
  default     = "https://glean-public-marketplace-resources.s3.amazonaws.com/glean-cloudformation-template.yaml"
}

variable "contact_email" {
  description = "Contact email to notify when Glean workspace is ready to be configured"
  type        = string
}
