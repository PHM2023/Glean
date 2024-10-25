############### BEGIN GLEAN TGW INITIAL SETUP ###############
resource "aws_ec2_transit_gateway" "glean_tgw" {
  description                     = "Glean Proxy TGW"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "disable"
}

resource "aws_ec2_transit_gateway_route_table" "glean_tgw_rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.glean_tgw.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "proxy_private_vpc_to_glean_tgw_attachment" {
  subnet_ids         = [var.proxy_private_subnet_id]
  transit_gateway_id = aws_ec2_transit_gateway.glean_tgw.id
  vpc_id             = var.proxy_vpc_id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_glean_vpc_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.proxy_private_vpc_to_glean_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.glean_tgw_rtb.id
}

resource "aws_ec2_transit_gateway_route" "glean_tgw_rtb_default_route" {
  destination_cidr_block         = "0.0.0.0/0"
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.glean_tgw_rtb.id
}

resource "aws_ec2_transit_gateway_route" "glean_tgw_rtb_proxy_nic_route" {
  destination_cidr_block         = format("%s/32", var.proxy_nic_ip)
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.glean_tgw_rtb.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.proxy_private_vpc_to_glean_tgw_attachment.id
}
############### END GLEAN TGW INITIAL SETUP ###############

################### BEGIN PROXY PRIVATE SUBNET RTB ROUTES #####################
locals {
  private_cidrs = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "aws_route" "private_ip_proxy_routes" {
  for_each               = toset(local.private_cidrs)
  route_table_id         = var.proxy_private_route_table_id
  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway.glean_tgw.id
}

resource "aws_route" "proxy_remote_subnet_routes" {
  for_each               = toset(var.proxy_remote_subnets)
  route_table_id         = var.proxy_private_route_table_id
  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway.glean_tgw.id
}

resource "aws_route" "proxy_onprem_ip_routes" {
  for_each               = toset(var.proxy_onprem_ips)
  route_table_id         = var.proxy_private_route_table_id
  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway.glean_tgw.id
}

resource "aws_route" "proxy_nameserver_routes" {
  for_each               = toset(var.proxy_nameservers)
  route_table_id         = var.proxy_private_route_table_id
  destination_cidr_block = format("%s/32", each.value)
  transit_gateway_id     = aws_ec2_transit_gateway.glean_tgw.id
}
################### END PROXY PRIVATE SUBNET RTB ROUTES #####################

resource "aws_ec2_transit_gateway_peering_attachment" "glean_initiated_peering_attachment" {
  count                   = var.ready_for_peering ? 1 : 0
  peer_account_id         = var.tgw_peer_account_id
  peer_region             = var.tgw_peer_region
  peer_transit_gateway_id = var.tgw_peer_gateway_id
  transit_gateway_id      = aws_ec2_transit_gateway.glean_tgw.id

  tags = {
    Name = "glean-initiated-peering-attachment"
    Side = "creator"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_peering_attachment_association" {
  count                          = var.ready_for_peering && length(var.tgw_peered_attachment_id) > 0 ? 1 : 0
  transit_gateway_attachment_id  = var.tgw_peered_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.glean_tgw_rtb.id
}

resource "aws_ec2_transit_gateway_route" "tgw_private_ip_routes" {
  count                          = var.ready_for_peering && length(var.tgw_peered_attachment_id) > 0 ? length(local.private_cidrs) : 0
  destination_cidr_block         = local.private_cidrs[count.index]
  transit_gateway_attachment_id  = var.tgw_peered_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.glean_tgw_rtb.id
}

resource "aws_ec2_transit_gateway_route" "tgw_remote_subnet_routes" {
  count                          = var.ready_for_peering && length(var.tgw_peered_attachment_id) > 0 ? length(var.proxy_remote_subnets) : 0
  destination_cidr_block         = var.proxy_remote_subnets[count.index]
  transit_gateway_attachment_id  = var.tgw_peered_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.glean_tgw_rtb.id
}

resource "aws_ec2_transit_gateway_route" "tgw_onprem_ip_routes" {
  count                          = var.ready_for_peering && length(var.tgw_peered_attachment_id) > 0 ? length(var.proxy_onprem_ips) : 0
  destination_cidr_block         = var.proxy_onprem_ips[count.index]
  transit_gateway_attachment_id  = var.tgw_peered_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.glean_tgw_rtb.id
}

resource "aws_ec2_transit_gateway_route" "tgw_nameserver_routes" {
  count                          = var.ready_for_peering && length(var.tgw_peered_attachment_id) > 0 ? length(var.proxy_nameservers) : 0
  destination_cidr_block         = format("%s/32", var.proxy_nameservers[count.index])
  transit_gateway_attachment_id  = var.tgw_peered_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.glean_tgw_rtb.id
}
