variable "image_uri" {
  description = "The image run by the deploy_build lambda"
  type        = string
}

variable "region" {
  description = "The region to create the deploy_build function in"
  type        = string
}


variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}

variable "allow_untrusted_images" {
  description = "Whether or not to allow untrusted images - should only be set for test projects"
  type        = bool
  default     = false
}