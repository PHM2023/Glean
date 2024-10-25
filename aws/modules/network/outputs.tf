output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "eks_private_subnet_id" {
  value = module.eks_subnet.subnet_id
}

output "eks_private_subnet_az" {
  value = module.eks_subnet.availability_zone
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion_security_group.id
}

output "bastion_subnet_id" {
  value = module.bastion_subnet.subnet_id
}

output "codebuild_security_group_id" {
  value = aws_security_group.codebuild_security_group.id
}

output "lambda_security_group_id" {
  value = aws_security_group.lambda_security_group.id
}

output "lambda_subnet_id" {
  value = module.lambda_subnet.subnet_id
}

# Exporting these next three only so the bastion module knows when to start (only after
# the vpc endpoints are created)

output "ssm_vpc_endpoint_id" {
  value = aws_vpc_endpoint.glean_ssm_vpc_endpoint.id
}

output "ec2messages_vpc_endpoint_id" {
  value = aws_vpc_endpoint.glean_ec2messages_vpc_endpoint.id
}

output "ssmmessages_vpc_endpoint_id" {
  value = aws_vpc_endpoint.glean_ssmmessages_vpc_endpoint.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds_security_group.id
}

output "rds_subnet_ids" {
  value = [
    module.rds_subnet_1.subnet_id,
    module.rds_subnet_2.subnet_id
  ]
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "git_crawler_subnet_id" {
  value = module.git_crawler_subnet.subnet_id
}

output "git_crawler_security_group_id" {
  value = aws_security_group.git_crawler_security_group.id
}

output "git_crawler_availability_zone" {
  value = module.git_crawler_subnet.availability_zone
}
