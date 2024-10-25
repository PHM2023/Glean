resource "aws_subnet" "private_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(tomap({
    Name = var.subnet_name
    }),
  var.tags)
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = var.route_table_id
}

## VPC Endpoints to allow AWS SSM to connect with a bastion instance:
# Read more at: https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html#sysman-setting-up-vpc-create

output "subnet_id" {
  value = aws_subnet.private_subnet.id
  # Adding this so that the subnet is only used after it can route correctly
  depends_on = [aws_route_table_association.private_subnet_association]
}

output "availability_zone" {
  value = aws_subnet.private_subnet.availability_zone
}