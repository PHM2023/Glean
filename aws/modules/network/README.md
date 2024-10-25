# network

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.31.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion_subnet"></a> [bastion\_subnet](#module\_bastion\_subnet) | ./private_subnet | n/a |
| <a name="module_codebuild_subnet"></a> [codebuild\_subnet](#module\_codebuild\_subnet) | ./private_subnet | n/a |
| <a name="module_eks_subnet"></a> [eks\_subnet](#module\_eks\_subnet) | ./private_subnet | n/a |
| <a name="module_git_crawler_subnet"></a> [git\_crawler\_subnet](#module\_git\_crawler\_subnet) | ./private_subnet | n/a |
| <a name="module_lambda_subnet"></a> [lambda\_subnet](#module\_lambda\_subnet) | ./private_subnet | n/a |
| <a name="module_rds_subnet_1"></a> [rds\_subnet\_1](#module\_rds\_subnet\_1) | ./private_subnet | n/a |
| <a name="module_rds_subnet_2"></a> [rds\_subnet\_2](#module\_rds\_subnet\_2) | ./private_subnet | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat_gateway_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.private_subnet_rtb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public_subnet_rtb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public_subnet_2_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_subnet_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.bastion_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.codebuild_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.git_crawler_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.glean_ec2messages_vpc_endpoint_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.glean_ssm_vpc_endpoint_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.glean_ssmmessages_vpc_endpoint_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.lambda_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.rds_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnet_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.glean_ec2messages_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.glean_ssm_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.glean_ssmmessages_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3_gateway_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [null_resource.check](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codebuild_ips"></a> [codebuild\_ips](#input\_codebuild\_ips) | List of IP blocks of codebuild projects in the required aws region | `list(string)` | <pre>[<br>  "34.228.4.208/28",<br>  "44.192.245.160/28",<br>  "44.192.255.128/28"<br>]</pre> | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_proxy_vpc_cidr"></a> [proxy\_vpc\_cidr](#input\_proxy\_vpc\_cidr) | CIDR block for the proxy VPC | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_security_group_id"></a> [bastion\_security\_group\_id](#output\_bastion\_security\_group\_id) | n/a |
| <a name="output_bastion_subnet_id"></a> [bastion\_subnet\_id](#output\_bastion\_subnet\_id) | n/a |
| <a name="output_codebuild_security_group_id"></a> [codebuild\_security\_group\_id](#output\_codebuild\_security\_group\_id) | n/a |
| <a name="output_ec2messages_vpc_endpoint_id"></a> [ec2messages\_vpc\_endpoint\_id](#output\_ec2messages\_vpc\_endpoint\_id) | n/a |
| <a name="output_eks_private_subnet_az"></a> [eks\_private\_subnet\_az](#output\_eks\_private\_subnet\_az) | n/a |
| <a name="output_eks_private_subnet_id"></a> [eks\_private\_subnet\_id](#output\_eks\_private\_subnet\_id) | n/a |
| <a name="output_git_crawler_availability_zone"></a> [git\_crawler\_availability\_zone](#output\_git\_crawler\_availability\_zone) | n/a |
| <a name="output_git_crawler_security_group_id"></a> [git\_crawler\_security\_group\_id](#output\_git\_crawler\_security\_group\_id) | n/a |
| <a name="output_git_crawler_subnet_id"></a> [git\_crawler\_subnet\_id](#output\_git\_crawler\_subnet\_id) | n/a |
| <a name="output_lambda_security_group_id"></a> [lambda\_security\_group\_id](#output\_lambda\_security\_group\_id) | n/a |
| <a name="output_lambda_subnet_id"></a> [lambda\_subnet\_id](#output\_lambda\_subnet\_id) | n/a |
| <a name="output_nat_gateway_public_ip"></a> [nat\_gateway\_public\_ip](#output\_nat\_gateway\_public\_ip) | n/a |
| <a name="output_public_subnet_id"></a> [public\_subnet\_id](#output\_public\_subnet\_id) | n/a |
| <a name="output_rds_security_group_id"></a> [rds\_security\_group\_id](#output\_rds\_security\_group\_id) | n/a |
| <a name="output_rds_subnet_ids"></a> [rds\_subnet\_ids](#output\_rds\_subnet\_ids) | n/a |
| <a name="output_ssm_vpc_endpoint_id"></a> [ssm\_vpc\_endpoint\_id](#output\_ssm\_vpc\_endpoint\_id) | n/a |
| <a name="output_ssmmessages_vpc_endpoint_id"></a> [ssmmessages\_vpc\_endpoint\_id](#output\_ssmmessages\_vpc\_endpoint\_id) | n/a |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
