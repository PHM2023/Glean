variable "region" {
  description = "The region"
  type        = string
}

variable "codebuild_ips" {
  type        = list(string)
  description = "List of IP blocks of codebuild projects in the required aws region"
  default     = ["34.228.4.208/28", "44.192.245.160/28", "44.192.255.128/28"]
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}
