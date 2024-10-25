variable "region" {
  description = "The region"
  type        = string
  default     = "us-east-1"
}

variable "subnet_id" {
  description = "ID of private subnet to use for hosting the bastion instance. Should live in same vpc as cluster/rds"
  type        = string
}

variable "bastion_security_group" {
  description = "Security group id for bastion instance"
  type        = string
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}

variable "iam_permissions_boundary_arn" {
  description = "Permissions boundary to apply to all IAM roles created by this module"
  type        = string
  default     = null
}

variable "eks_cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type to use for bastion"
  type        = string
  default     = "m4.xlarge"
}