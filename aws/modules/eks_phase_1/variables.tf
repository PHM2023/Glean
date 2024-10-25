variable "region" {
  description = "AWS Region to use for EKS resources"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "cluster_name" {
  type        = string
  description = "Name of cluster"
  default     = "glean-cluster"
}

variable "public_subnet_id" {
  type        = string
  description = "Public Subnet Id"
}

variable "eks_private_subnet_id" {
  type        = string
  description = "EKS Private Subnet Id"
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

variable "bastion_security_group_id" {
  description = "ID of the bastion security group"
  type        = string
}

variable "lambda_security_group_id" {
  description = "ID of the lambda security group"
  type        = string
}

variable "codebuild_security_group_id" {
  description = "ID of the codebuild security group"
  type        = string
}

variable "secrets_encryption_kms_key_arn" {
  description = "ARN of the KMS key to use for encrypting k8s secrets at rest"
  type        = string
}