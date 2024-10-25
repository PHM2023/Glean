variable "elasticache_cluster_node_type" {
  description = "The node type for the memcached cluster"
  type        = string
  default     = "cache.t4g.small"
}

variable "elasticache_memcached_version" {
  description = "The version of memcached to use in the elasticache cluster"
  type        = string
  default     = "1.6.17"
}

variable "elasticache_vpc_id" {
  description = "VPC ID to use for the elasticache subnet group"
  type        = string
}

variable "elasticache_num_nodes" {
  description = "Number of memcached nodes to use"
  type        = number
  default     = 1
}

variable "eks_security_group_id" {
  description = "ID of the EKS security group"
  type        = string
}

variable "eks_private_subnet_id" {
  description = "ID of the eks private subnet"
  type        = string
}