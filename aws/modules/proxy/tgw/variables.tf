variable "proxy_remote_subnets" {
  description = "Customer configured remote subnet cidrs"
  type        = list(string)
}

variable "proxy_onprem_ips" {
  description = "Customer configured onprem ips"
  type        = list(string)
}

variable "proxy_nameservers" {
  description = "Customer configured nameserver ips"
  type        = list(string)
}

variable "iam_permissions_boundary_arn" {
  description = "Permissions boundary to apply to all IAM roles created by this module"
  type        = string
  default     = null
}

variable "region" {
  description = "The region in which the resources will be created"
  type        = string
}

variable "account_id" {
  description = "The glean aws account id"
  type        = string
}

variable "proxy_nic_ip" {
  description = "Nic ip for the glean proxy vm instance"
  type        = string
}

variable "proxy_private_subnet_id" {
  description = "Private subnet id for the glean proxy vm instance"
  type        = string
}

variable "proxy_vpc_id" {
  description = "VPC id for the glean proxy vm instance"
  type        = string
}

variable "proxy_private_route_table_id" {
  description = "Private route table id for the glean proxy vm instance"
  type        = string
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

variable "ready_for_peering" {
  description = "Boolean to indicate if the peer gateway is ready for peering"
  type        = bool
  default     = false
}

variable "tgw_peered_attachment_id" {
  description = "The id of the peered attachment"
  type        = string
  default     = null
}
