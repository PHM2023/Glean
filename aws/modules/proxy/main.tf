########################## Proxy Subnet  ##################################
# The proxy will live in its own VPC. This is the equivalent of our transit subnet in GCP
resource "aws_vpc" "proxy_vpc" {
  # Require a /26 cidr for the VPC, such that we can split this into 2 /27 subnets. We require a /27
  # subnet because a nat requires at least 8 addresses, and we want to leave room for future expansion
  cidr_block = var.transit_vpc_cidr
  tags = {
    Name = "proxy-vpc"
  }
}

resource "aws_subnet" "proxy_private_subnet" {
  vpc_id            = aws_vpc.proxy_vpc.id
  cidr_block        = cidrsubnet(var.transit_vpc_cidr, 1, 0)
  availability_zone = var.eks_private_subnet_az
  tags = {
    Name = "proxy-private-subnet"
  }
}

resource "aws_route_table" "proxy_private_subnet_rtb" {
  vpc_id = aws_vpc.proxy_vpc.id

  tags = {
    Name = "proxy-private-route-table"
  }

  # NOTE(Steve): Do not use route blocks here as they will conflict with individual route resources
  # Instead, declare a separate resource for each route
  # Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
}

resource "aws_route_table_association" "proxy_private_subnet_rtb_association" {
  subnet_id      = aws_subnet.proxy_private_subnet.id
  route_table_id = aws_route_table.proxy_private_subnet_rtb.id
}

######################### Internet Egress Connectivity for Proxy Private Subnet ##################
resource "aws_internet_gateway" "proxy_vpc_internet_gateway" {
  vpc_id = aws_vpc.proxy_vpc.id

  tags = {
    Name = "proxy-vpc-internet-gateway"
  }
}

# NOTE(Steve): Nothing should be in this subnet except for the NAT and IGW. We should never create glean services in
# this subnet
# TODO: Block this out via permission boundaries
resource "aws_subnet" "proxy_public_subnet_no_allocate" {
  vpc_id            = aws_vpc.proxy_vpc.id
  cidr_block        = cidrsubnet(var.transit_vpc_cidr, 1, 1)
  availability_zone = var.eks_private_subnet_az
  tags = {
    Name = "proxy-public-subnet-NO-ALLOCATE"
  }
}

resource "aws_route_table" "proxy_public_subnet_rtb" {
  vpc_id = aws_vpc.proxy_vpc.id

  tags = {
    Name = "proxy-public-subnet-rtb-NO-ALLOCATE"
  }
}

resource "aws_route" "proxy_public_subnet_rtb_internet_route" {
  route_table_id         = aws_route_table.proxy_public_subnet_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.proxy_vpc_internet_gateway.id
}

resource "aws_route_table_association" "proxy_public_subnet_rtb_association" {
  subnet_id      = aws_subnet.proxy_public_subnet_no_allocate.id
  route_table_id = aws_route_table.proxy_public_subnet_rtb.id
}

resource "aws_eip" "proxy_nat_ip" {
  domain = "vpc"
  tags = {
    Name = "Proxy public subnet NAT IP"
  }
}

resource "aws_nat_gateway" "proxy_public_subnet_nat_gateway" {
  subnet_id     = aws_subnet.proxy_public_subnet_no_allocate.id
  allocation_id = aws_eip.proxy_nat_ip.id

  tags = {
    Name = "Proxy NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.proxy_vpc_internet_gateway]
}

resource "aws_route" "proxy_private_subnet_to_proxy_public_subnet_nat_route" {
  route_table_id         = aws_route_table.proxy_private_subnet_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.proxy_public_subnet_nat_gateway.id
}

########################## Glean VPC -> Proxy VPC Instrumentation  ##################################
resource "aws_security_group" "glean_vpc_endpoint_outbound_to_proxy_sg" {
  name        = "glean-vpc-endpoint-outbound-to-proxy-sg"
  description = "Security group attached to the vpc endpoint outbound to the proxy vpc"
  vpc_id      = var.glean_vpc_id

  ingress {
    description     = "Ingress from bastion"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  ingress {
    description     = "Ingress from EKS cluster"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.cluster_security_group_id]
  }

  egress {
    cidr_blocks = [aws_vpc.proxy_vpc.cidr_block]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_security_group" "proxy_vpc_endpoint_service_nlb_inbound_from_glean_sg" {
  name        = "proxy nlb inbound from glean"
  description = "Security group attached to the proxy vpc endpoint service nlb for requests inbound from glean"
  vpc_id      = aws_vpc.proxy_vpc.id
  ingress {
    description = "TCP from glean subnet"
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = [var.glean_vpc_cidr_block]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_lb" "proxy_vpc_endpoint_service_inbound_from_glean_nlb" {
  name               = "proxy-inbound-from-glean-nlb"
  internal           = true
  load_balancer_type = "network"

  security_groups            = [aws_security_group.proxy_vpc_endpoint_service_nlb_inbound_from_glean_sg.id]
  subnets                    = [aws_subnet.proxy_private_subnet.id]
  enable_deletion_protection = false
}

data "aws_network_interface" "proxy_vpc_endpoint_service_inbound_from_glean_nlb_nic" {
  filter {
    name   = "description"
    values = [format("ELB net/%s", element(split("net/", aws_lb.proxy_vpc_endpoint_service_inbound_from_glean_nlb.arn), 1))]
  }
  depends_on = [aws_lb.proxy_vpc_endpoint_service_inbound_from_glean_nlb]
}

resource "aws_lb_target_group" "proxy_vpc_endpoint_service_inbound_from_glean_nlb_target_group" {
  name        = "proxy-inbound-from-glean"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.proxy_vpc.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "proxy_vpc_endpoint_inbound_from_glean_nlb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.proxy_vpc_endpoint_service_inbound_from_glean_nlb_target_group.arn
  target_id        = aws_instance.proxy.id
  port             = 80
}

resource "aws_lb_listener" "proxy_vpc_endpoint_inbound_from_glean_nlb_listener" {
  load_balancer_arn = aws_lb.proxy_vpc_endpoint_service_inbound_from_glean_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proxy_vpc_endpoint_service_inbound_from_glean_nlb_target_group.arn
  }
}

resource "aws_vpc_endpoint_service" "proxy_vpc_endpoint_service_inbound_from_glean" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.proxy_vpc_endpoint_service_inbound_from_glean_nlb.arn]
  tags = {
    Name = "proxy-vpc-endpoint-service-inbound-from-glean"
  }
}

resource "aws_vpc_endpoint" "glean_vpc_endpoint_outbound_to_proxy" {
  # This is the VPC endpoint that lives on the glean VPC, and is used to communicate with the proxy VPC endpoint service
  # to send crawler traffic from glean vpc through the proxy
  vpc_id            = var.glean_vpc_id
  service_name      = aws_vpc_endpoint_service.proxy_vpc_endpoint_service_inbound_from_glean.service_name
  vpc_endpoint_type = "Interface"

  subnet_ids         = [var.eks_private_subnet_id]
  security_group_ids = [aws_security_group.glean_vpc_endpoint_outbound_to_proxy_sg.id]
  tags = {
    Name = "glean-vpc-endpoint-outbound-to-proxy"
  }
}

########################## Proxy VPC -> Glean VPC Instrumentation ##################################
resource "aws_security_group" "proxy_vpc_endpoint_outbound_to_glean_sg" {
  name        = "proxy-vpc-endpoint-outbound-to-glean-sg"
  description = "Security group attached to the vpc endpoint outbound to glean vpc"
  vpc_id      = aws_vpc.proxy_vpc.id
}

resource "aws_security_group_rule" "proxy_vpc_endpoint_outbound_to_glean_sg_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.proxy_nic_sg.id
  security_group_id        = aws_security_group.proxy_vpc_endpoint_outbound_to_glean_sg.id
}

resource "aws_security_group_rule" "proxy_vpc_endpoint_outbound_to_glean_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.glean_vpc_cidr_block]
  security_group_id = aws_security_group.proxy_vpc_endpoint_outbound_to_glean_sg.id
}

resource "aws_security_group" "glean_vpc_endpoint_service_nlb_inbound_from_proxy_sg" {
  name        = "glean_vpc_endpoint_service_nlb_inbound_from_proxy_sg"
  description = "Security group attached to the glean vpc endpoint service nlb for requests inbound from proxy"
  vpc_id      = var.glean_vpc_id
  ingress {
    description = "TCP from proxy subnet"
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = [aws_vpc.proxy_vpc.cidr_block]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_proxy_ingress_allow" {
  security_group_id = var.eks_cluster_security_group_id
  description       = "For allowing traffic from proxy to dse"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  cidr_ipv4         = var.transit_vpc_cidr
}

resource "aws_vpc_endpoint_service" "glean_vpc_endpoint_service_inbound_from_proxy" {
  acceptance_required        = false
  network_load_balancer_arns = [data.aws_lb.dse_internal_lb.arn]
  tags = {
    Name = "glean-vpc-endpoint-service-inbound-from-proxy"
  }
}

resource "aws_vpc_endpoint" "proxy_vpc_endpoint_outbound_to_glean" {
  # This is the VPC endpoint that lives on the proxy VPC, and is used to communicate with the glean VPC endpoint service
  # to forward webhook traffic from proxy vpc back to glean vpc
  vpc_id            = aws_vpc.proxy_vpc.id
  service_name      = aws_vpc_endpoint_service.glean_vpc_endpoint_service_inbound_from_proxy.service_name
  vpc_endpoint_type = "Interface"

  subnet_ids         = [aws_subnet.proxy_private_subnet.id]
  security_group_ids = [aws_security_group.proxy_vpc_endpoint_outbound_to_glean_sg.id]
  tags = {
    Name = "proxy-vpc-endpoint-outbound-to-glean"
  }
}

data "aws_network_interface" "glean_vpc_endpoint_outbound_to_proxy_nic" {
  filter {
    name   = "description"
    values = [format("VPC Endpoint Interface %s", aws_vpc_endpoint.glean_vpc_endpoint_outbound_to_proxy.id)]
  }
  depends_on = [aws_vpc_endpoint.glean_vpc_endpoint_outbound_to_proxy]
}

########################## Proxy EC2 Instance  ##################################
resource "aws_security_group" "proxy_nic_sg" {
  name        = "proxy-nic-sg"
  description = "Security group attached to the proxy nic"
  vpc_id      = aws_vpc.proxy_vpc.id

  ingress {
    description = "TCP from proxy NLB security group"
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    # TODO(Steve): Narrow this down to proxy vm instance
    security_groups = [aws_security_group.proxy_vpc_endpoint_service_nlb_inbound_from_glean_sg.id]
  }

  # Add generic local ip cidrs in case customers want to send webhooks while using their own custom dns
  # (s.t. they don't have to set onprem.ip, as otherwise we only add ingress rules for onprem.ip values)
  ingress {
    description = "TCP from local 10.0.0.0/8 cidr"
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "TCP from local 172.16.0.0/12 cidr"
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["172.16.0.0/12"]
  }

  ingress {
    description = "TCP from local 192.168.0.0/16 cidr"
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["192.168.0.0/16"]
  }

  dynamic "ingress" {
    for_each = var.proxy_onprem_ips
    content {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }


  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_iam_role" "proxy" {
  name                 = "proxy"
  permissions_boundary = var.iam_permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn,
    data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
  ]
}

resource "aws_iam_instance_profile" "proxy_instance_profile" {
  name = "proxy-instance-profile"
  role = aws_iam_role.proxy.name
}

resource "aws_network_interface" "proxy_nic" {
  subnet_id       = aws_subnet.proxy_private_subnet.id
  security_groups = [aws_security_group.proxy_nic_sg.id]
  tags = {
    Name = "proxy-nic"
  }
}

data "aws_network_interface" "proxy_vpc_endpoint_outbound_to_glean_nic" {
  filter {
    name   = "description"
    values = [format("VPC Endpoint Interface %s", aws_vpc_endpoint.proxy_vpc_endpoint_outbound_to_glean.id)]
  }
  depends_on = [aws_vpc_endpoint.proxy_vpc_endpoint_outbound_to_glean]
}

resource "aws_instance" "proxy" {
  ami = data.aws_ami.ubuntu.id

  instance_type = "t2.micro"

  tags = {
    Name = "proxy"
  }

  root_block_device {
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }

  network_interface {
    network_interface_id = aws_network_interface.proxy_nic.id
    device_index         = 0
  }

  iam_instance_profile        = aws_iam_instance_profile.proxy_instance_profile.name
  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/proxy_entrypoint.sh",
    {
      webhook_target : format("http://%s", data.aws_network_interface.proxy_vpc_endpoint_outbound_to_glean_nic.private_ip),
      allowed_proxy_address : data.aws_network_interface.proxy_vpc_endpoint_service_inbound_from_glean_nlb_nic.private_ip,
      proxy_image : var.proxy_image,
      region : var.region,
      nameservers : jsonencode(var.proxy_nameservers),
      onprem_host_aliases : jsonencode(var.onprem_host_aliases)
  })
  lifecycle {
    # We don't want updates to the latest ubuntu ami to trigger an update
    ignore_changes = [ami]
  }
}

###################### Proxy VPC endpoints to allow SSM connection for shelling into proxy ###########################

resource "aws_vpc_endpoint" "proxy_ssm_vpc_endpoint" {
  vpc_id            = aws_vpc.proxy_vpc.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [aws_subnet.proxy_private_subnet.id]
}

resource "aws_vpc_endpoint" "proxy_ssmmessages_vpc_endpoint" {
  vpc_id            = aws_vpc.proxy_vpc.id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [aws_subnet.proxy_private_subnet.id]
}

resource "aws_vpc_endpoint" "proxy_ec2messages_vpc_endpoint" {
  vpc_id            = aws_vpc.proxy_vpc.id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [aws_subnet.proxy_private_subnet.id]
}

###################### VPN ###########################
module "vpn" {
  depends_on           = [aws_vpc.proxy_vpc, aws_route_table.proxy_private_subnet_rtb]
  source               = "./vpn"
  count                = var.vpn_peer_ip != "" ? 1 : 0
  vpn_peer_ip          = var.vpn_peer_ip
  proxy_remote_subnets = var.proxy_remote_subnets
  proxy_nameservers    = var.proxy_nameservers
  proxy_onprem_ips     = var.proxy_onprem_ips
  vpn_shared_secret    = var.vpn_shared_secret
}

###################### TGW ###########################
module "tgw" {
  source                       = "./tgw"
  count                        = var.transit_gateway_peering ? 1 : 0
  proxy_remote_subnets         = var.proxy_remote_subnets
  proxy_nameservers            = var.proxy_nameservers
  proxy_onprem_ips             = var.proxy_onprem_ips
  proxy_nic_ip                 = aws_network_interface.proxy_nic.private_ip
  proxy_private_subnet_id      = aws_subnet.proxy_private_subnet.id
  proxy_vpc_id                 = aws_vpc.proxy_vpc.id
  proxy_private_route_table_id = aws_route_table.proxy_private_subnet_rtb.id
  tgw_peer_account_id          = var.tgw_peer_account_id
  tgw_peer_region              = var.tgw_peer_region
  tgw_peer_gateway_id          = var.tgw_peer_gateway_id
  ready_for_peering            = var.tgw_peer_account_id != "" && var.tgw_peer_region != "" && var.tgw_peer_gateway_id != ""
  region                       = var.region
  account_id                   = var.account_id
  tgw_peered_attachment_id     = var.tgw_peered_attachment_id
  iam_permissions_boundary_arn = var.iam_permissions_boundary_arn
}
