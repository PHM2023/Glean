variable "node_group_name" {
  description = "The name of the node group"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "node_role_arn" {
  description = "The ARN of the role to use for the node group worker"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet ID's to use for the node group"
  type        = list(string)
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}

variable "desired_size" {
  description = "Desired size of node group"
  type        = number
}

variable "min_size" {
  description = "Min size of node group"
  type        = number
}
variable "max_size" {
  description = "Max size of node group"
  type        = number
}

variable "labels" {
  description = "Labels to attach to the node group"
  type        = map(string)
  default     = {}
}

variable "taints" {
  description = "Taints to apply to the node group"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}
