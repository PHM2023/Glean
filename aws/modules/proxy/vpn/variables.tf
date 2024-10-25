variable "vpn_peer_ip" {
  description = "The ip of the peer for VPN connection"
  type        = string
}

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

variable "vpn_shared_secret" {
  description = "The encrypted shared secret for the VPN connection"
  type        = string
  sensitive   = true
}

variable "iam_permissions_boundary_arn" {
  description = "Permissions boundary to apply to all IAM roles created by this module"
  type        = string
  default     = null
}