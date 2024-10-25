variable "account_id" {
  description = "Glean AWS account id"
  type        = string
}
variable "region" {
  description = "The region"
  type        = string
  default     = "us-east-1"
}

variable "transit_vpc_cidr" {
  description = "CIDR for the transit network, in which the proxy will live. This should be a /26 CIDR"
  type        = string
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}

variable "proxy_image" {
  description = "ECR Image tag for the proxy container"
  type        = string
}

variable "proxy_remote_subnets" {
  description = "Customer configured remote subnet cidrs"
  type        = list(string)
  default     = []
}

variable "proxy_onprem_ips" {
  description = "Customer configured onprem ips"
  type        = list(string)
  default     = []
}

variable "proxy_nameservers" {
  description = "Customer configured nameserver ips"
  type        = list(string)
  default     = []
}

variable "onprem_host_aliases" {
  description = "Map of onprem hosts to their corresponding IPs"
  type        = map(string)
  default     = {}

}

variable "transit_gateway_peering" {
  description = "Whether to create a standalone transit gateway that the customer will handle linkage with"
  type        = bool
  default     = false
}

variable "vpn_peer_ip" {
  description = "Customer's peer ip for VPN connection"
  type        = string
  default     = ""
}

variable "vpn_shared_secret" {
  description = "The shared secret for the VPN connection"
  type        = string
  default     = null
  sensitive   = true
}

variable "iam_permissions_boundary_arn" {
  description = "Permissions boundary to apply to all IAM roles created by this module"
  type        = string
  default     = null
}

variable "tgw_peer_account_id" {
  description = "The account id of the peer gateway"
  type        = string
  default     = null
}
variable "tgw_peer_region" {
  description = "The region of the peer gateway"
  type        = string
  default     = null
}
variable "tgw_peer_gateway_id" {
  description = "The id of the peer gateway"
  type        = string
  default     = null
}

variable "tgw_peered_attachment_id" {
  description = "The id of the peered attachment"
  type        = string
  default     = null
}

variable "eks_private_subnet_id" {
  description = "ID of the eks private subnet"
  type        = string
}

variable "eks_private_subnet_az" {
  description = "Availability zone for eks private subnet"
  type        = string
}

variable "glean_vpc_id" {
  description = "ID of Glean VPC"
  type        = string
}

variable "bastion_security_group_id" {
  description = "ID of bastion security group"
  type        = string
}

variable "cluster_security_group_id" {
  description = "ID of EKS cluster security group"
  type        = string
}

variable "glean_vpc_cidr_block" {
  description = "CIDR block of Glean VPC"
  type        = string
}

variable "dse_internal_lb_hostname" {
  description = "Hostname of the internal load balancer for DSE"
  type        = string
}

variable "eks_cluster_security_group_id" {
  description = "ID of EKS cluster security group"
  type        = string
}