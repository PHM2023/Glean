output "glean_tgw_id" {
  value = var.transit_gateway_peering ? module.tgw[0].tgw_id : null
}

output "proxy_ip" {
  value = data.aws_network_interface.glean_vpc_endpoint_outbound_to_proxy_nic.private_ip
}

output "transit_ip" {
  value = data.aws_network_interface.proxy_vpc_endpoint_outbound_to_glean_nic.private_ip
}