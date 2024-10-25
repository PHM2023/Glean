########################## data  ##################################
data "aws_availability_zones" "available" {}
########################## VPC  ##################################
# All glean components will be part of this VPC
resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "glean-vpc"
  }
}

########################## Common Public Subnet  ##################################
# This section defines a common public subnet that provides access to internet
# Multiple private subnets can choose to access internet via the nat gateway present in the public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "public-subnet"
    # This is so the ALB load balancer plugin can select this subnet for use
    "kubernetes.io/role/elb" = "1"
  }
}

# ALB requires at least 2 subnets across availability zones
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.public_subnet_2_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "public-subnet-2"
    # This is so the ALB load balancer plugin can select this subnet for use
    "kubernetes.io/role/elb" = "1"
  }
}

#------> Define Gateways
# IP gw needed for public subnet to be able to connect to internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

## allocate elastic ip and assign (will be used by NAT gw)
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"
}

## NAT gw is used by private subnets to access internet
## nat gateway needs to be present in the public subnet
## so that it has access to internet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet_2.id
  # NAT gateway will only work after the public subnet has a route table to the IGW
  depends_on = [
    aws_route_table_association.public_subnet_2_association
  ]
  tags = {
    Name = "glean-nat-gateway"
  }
}

output "nat_gateway_public_ip" {
  value = aws_nat_gateway.nat_gateway.public_ip
}

#----> Configure Route Table
resource "aws_route_table" "public_subnet_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
## associate route table with public_subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet_rtb.id
}

## associate route table with the second public_subnet
resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_subnet_rtb.id
}


# Common route table For Private Subnets
# Note: create new route tables in case of additional customization for any private subnet
# All external traffic is routed to NAT gateway in the public subnet
resource "aws_route_table" "private_subnet_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

# The following check ensures that there is more than 1 az
# EKS as well as RDS require, there are at-least 2 subnets in different az's, for the cluster setup
resource "null_resource" "check" {
  count = length(data.aws_availability_zones.available.names) > 1 ? 0 : 1
  provisioner "local-exec" {
    command = "echo 'Error: Only one availability zone available in the region' && exit 1"
  }
}

########################## EKS Subnet  ##################################
# Node groups are supposed to be deployed only to the private subnet
# Public subnet would host ingress and load balancers (this is the recommended model to host prod workloads)

module "eks_subnet" {
  source            = "./private_subnet"
  vpc_id            = aws_vpc.vpc.id
  subnet_cidr       = local.eks_private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  subnet_name       = "eks-private-subnet"
  route_table_id    = aws_route_table.private_subnet_rtb.id
  region            = var.region
  tags = {
    # This is so the ALB load balancer plugin can select this subnet for use in an internal load balancer
    "kubernetes.io/role/internal-elb" = "1"
  }
}

########################## Codebuild Subnet and Security Group ############################

# To run codebuild projects within our vpc, we need to create a subnet and allow it to access the internet. The ids
# of the following resources will be added to the config and used by deploy_build to configure the codebuild projects
# suitably
module "codebuild_subnet" {
  source            = "./private_subnet"
  vpc_id            = aws_vpc.vpc.id
  subnet_cidr       = local.codebuild_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  subnet_name       = "codebuild-subnet"
  route_table_id    = aws_route_table.private_subnet_rtb.id
  region            = var.region
}

resource "aws_security_group" "codebuild_security_group" {
  # Ref: https://tinyurl.com/2uss7rhz
  # We are creating this security group to let codebuild access our rds instances
  # TODO(jayesh): Add inbound rule from this security group to our rds instances' security group when we add them
  name   = "codebuild-security-group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = "Ingress from codebuild"
    protocol    = "tcp"
    from_port   = "3306"
    to_port     = "3306"
    cidr_blocks = var.codebuild_ips
  }
  # This permits all kinds of outbound traffic from the security group. Revisit if this is needed
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

########################## RDS Subnet and Security Group ############################
# RDS requires us to create the instances in at least 2 subnets with different az's
module "rds_subnet_1" {
  source            = "./private_subnet"
  vpc_id            = aws_vpc.vpc.id
  subnet_cidr       = local.rds_subnet_1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  subnet_name       = "rds-subnet-1"
  route_table_id    = aws_route_table.private_subnet_rtb.id
  region            = var.region
}

module "rds_subnet_2" {
  source            = "./private_subnet"
  vpc_id            = aws_vpc.vpc.id
  subnet_cidr       = local.rds_subnet_2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  subnet_name       = "rds-subnet-2"
  route_table_id    = aws_route_table.private_subnet_rtb.id
  region            = var.region
}

resource "aws_security_group" "rds_security_group" {
  # allow incoming traffic from EKS and rds
  # allow all outgoing traffic
  name   = "rds-security-group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description     = "Ingress from codebuild"
    protocol        = "tcp"
    from_port       = "3306"
    to_port         = "3306"
    security_groups = [aws_security_group.codebuild_security_group.id]
  }

  ingress {
    description = "Ingress from EKS"
    protocol    = "tcp"
    from_port   = "3306"
    to_port     = "3306"
    # Only allow traffic from the private subnet because all the eks nodes are supposed to be hosted on it
    # TODO(Venkat): create custom security groups for EKS and use that here instead of CIDR block
    cidr_blocks = [local.eks_private_subnet_cidr]
  }

  ingress {
    from_port       = "3306"
    protocol        = "tcp"
    to_port         = "3306"
    description     = "Allow ingress from lambda security group"
    security_groups = [aws_security_group.lambda_security_group.id]
  }

  ingress {
    from_port       = "3306"
    protocol        = "tcp"
    to_port         = "3306"
    description     = "For allowing bastion instance connections"
    security_groups = [aws_security_group.bastion_security_group.id]
  }

  # This permits all kinds of outbound traffic from the security group. Revisit if this is needed
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}
###########################################################################################

### Bastion subnet and Security Group ###
module "bastion_subnet" {
  source            = "./private_subnet"
  vpc_id            = aws_vpc.vpc.id
  subnet_cidr       = local.bastion_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  subnet_name       = "bastion-private-subnet"
  route_table_id    = aws_route_table.private_subnet_rtb.id
  region            = var.region
}

resource "aws_security_group" "bastion_security_group" {
  # Ref: https://tinyurl.com/2uss7rhz
  # We are creating this security group to let bastion access rds + eks
  name   = "bastion-security-group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    self      = true
  }
  # This permits all kinds of outbound traffic from the security group. Revisit if this is needed
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

### Git crawler subnet and security group ###

module "git_crawler_subnet" {
  source            = "./private_subnet"
  vpc_id            = aws_vpc.vpc.id
  subnet_cidr       = local.git_crawler_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  subnet_name       = "git-crawler-private-subnet"
  route_table_id    = aws_route_table.private_subnet_rtb.id
  region            = var.region
}

resource "aws_security_group" "git_crawler_security_group" {
  name   = "git-crawler-security-group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [local.vpc_cidr]
  }
  # This permits all kinds of outbound traffic from the security group.
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

# VPC endpoints to allow SSM to work with bastion

resource "aws_security_group" "glean_ssm_vpc_endpoint_security_group" {
  # This is the security group tied to the SSM VPC endpoint:
  name   = "ssm-vpc-endpoint"
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol    = "TCP"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
  }
}

resource "aws_vpc_endpoint" "glean_ssm_vpc_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.glean_ssm_vpc_endpoint_security_group.id]

  subnet_ids = [module.bastion_subnet.subnet_id]

  tags = {
    Name = "ssm-vpc-endpoint"
  }

  private_dns_enabled = true
}


resource "aws_security_group" "glean_ssmmessages_vpc_endpoint_security_group" {
  # This is the security group tied to the SSM Messages VPC endpoint:
  name   = "ssmmessages-vpc-endpoint"
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol    = "TCP"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
  }
}

resource "aws_vpc_endpoint" "glean_ssmmessages_vpc_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.glean_ssmmessages_vpc_endpoint_security_group.id]

  subnet_ids = [module.bastion_subnet.subnet_id]

  tags = {
    Name = "ssmmessages-vpc-endpoint"
  }

  private_dns_enabled = true
}


resource "aws_security_group" "glean_ec2messages_vpc_endpoint_security_group" {
  # This is the security group tied to the EC2 Messages VPC endpoint:
  name   = "ec2messages-vpc-endpoint"
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol    = "TCP"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
  }
}

resource "aws_vpc_endpoint" "glean_ec2messages_vpc_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.glean_ec2messages_vpc_endpoint_security_group.id]

  subnet_ids = [module.bastion_subnet.subnet_id]

  tags = {
    Name = "ec2messages-vpc-endpoint"
  }

  private_dns_enabled = true
}

# The following vpc endpoint is used to route all s3 api requests within the vpc and not via the nat. Since
# our data pipelines tend to hammer s3, routing all traffic via the nat is very costly.
resource "aws_vpc_endpoint" "s3_gateway_vpc_endpoint" {
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private_subnet_rtb.id
  ]
  tags = {
    Name = "s3-gateway-endpoint"
  }
}


### Private lambda subnet and security group

module "lambda_subnet" {
  source            = "./private_subnet"
  vpc_id            = aws_vpc.vpc.id
  subnet_cidr       = local.lambda_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  subnet_name       = "lambda-private-subnet"
  route_table_id    = aws_route_table.private_subnet_rtb.id
  region            = var.region
}

resource "aws_security_group" "lambda_security_group" {
  # Ref: https://tinyurl.com/2uss7rhz
  # We are creating this security group to let lambda's access rds + eks
  name   = "lambda-security-group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    self      = true
  }
  # This permits all kinds of outbound traffic from the security group. Revisit if this is needed
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}
