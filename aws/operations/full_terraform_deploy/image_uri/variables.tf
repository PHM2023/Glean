variable "version_tag" {
  description = "The version tag of the image to use"
  type        = string
}

variable "repo_name" {
  description = "The ECR repo name to use"
  type        = string
}


variable "region" {
  description = "ECR region to use, defaults to the central ECR images in us-east-1"
  type        = string
  default     = "us-east-1"
}

variable "registry" {
  description = "ECR registry to use, defaults to the glean central ECR registry: 518642952506"
  type        = string
  default     = "518642952506"
}
