variable "region" {
  description = "The region to create the lambda function in"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "use_bastion" {
  description = "Whether to use a bastion host to access the EKS cluster"
  type        = bool
}

variable "eks_private_subnet_id" {
  description = "EKS Private Subnet Id"
  type        = string
}
