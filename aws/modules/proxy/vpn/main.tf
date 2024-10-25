########################## data  ##################################
data "aws_vpc" "proxy_vpc" {
  filter {
    name   = "tag:Name"
    values = ["proxy-vpc"]
  }
}

data "aws_route_table" "proxy_private_route_table" {
  vpc_id = data.aws_vpc.proxy_vpc.id
  filter {
    name   = "tag:Name"
    values = ["proxy-private-route-table"]
  }
}

resource "aws_customer_gateway" "customer_gateway" {
  # TODO(Steve): Add BGP support
  bgp_asn    = 65000
  ip_address = var.vpn_peer_ip
  type       = "ipsec.1"

  tags = {
    Name = "customer-gateway-1"
  }
}

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = data.aws_vpc.proxy_vpc.id

  tags = {
    Name = "vpn-gateway-1"
  }
}

resource "aws_vpn_gateway_attachment" "vpn_attachment" {
  vpc_id         = data.aws_vpc.proxy_vpc.id
  vpn_gateway_id = aws_vpn_gateway.vpn_gateway.id
}


resource "aws_vpn_connection" "proxy_vpn_connection" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.customer_gateway.id
  type                = "ipsec.1"
  # TODO(Steve): Add BGP support
  static_routes_only    = true
  tunnel1_preshared_key = var.vpn_shared_secret
}

resource "aws_vpn_connection_route" "proxy_vpn_connection_route" {
  destination_cidr_block = "0.0.0.0/0"
  vpn_connection_id      = aws_vpn_connection.proxy_vpn_connection.id
}

locals {
  private_cidrs = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}
resource "aws_route" "private_ip_proxy_routes" {
  for_each               = toset(local.private_cidrs)
  route_table_id         = data.aws_route_table.proxy_private_route_table.id
  destination_cidr_block = each.value
  gateway_id             = aws_vpn_gateway.vpn_gateway.id
}

resource "aws_route" "proxy_remote_subnet_routes" {
  for_each               = toset(var.proxy_remote_subnets)
  route_table_id         = data.aws_route_table.proxy_private_route_table.id
  destination_cidr_block = each.value
  gateway_id             = aws_vpn_gateway.vpn_gateway.id
}

resource "aws_route" "proxy_onprem_ip_routes" {
  for_each               = toset(var.proxy_onprem_ips)
  route_table_id         = data.aws_route_table.proxy_private_route_table.id
  destination_cidr_block = each.value
  gateway_id             = aws_vpn_gateway.vpn_gateway.id
}

resource "aws_route" "proxy_nameserver_routes" {
  for_each               = toset(var.proxy_nameservers)
  route_table_id         = data.aws_route_table.proxy_private_route_table.id
  destination_cidr_block = format("%s/32", each.value)
  gateway_id             = aws_vpn_gateway.vpn_gateway.id
}

# Add routes to glean cidrs
# TODO(Steve): Figure out if this is necessary with AWS privatelink
