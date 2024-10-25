# tgw

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.38.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.glean_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_peering_attachment.glean_initiated_peering_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_peering_attachment) | resource |
| [aws_ec2_transit_gateway_route.glean_tgw_rtb_default_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.glean_tgw_rtb_proxy_nic_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.tgw_nameserver_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.tgw_onprem_ip_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.tgw_private_ip_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.tgw_remote_subnet_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table.glean_tgw_rtb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.tgw_glean_vpc_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.tgw_peering_attachment_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.proxy_private_vpc_to_glean_tgw_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_route.private_ip_proxy_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.proxy_nameserver_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.proxy_onprem_ip_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.proxy_remote_subnet_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The glean aws account id | `string` | n/a | yes |
| <a name="input_iam_permissions_boundary_arn"></a> [iam\_permissions\_boundary\_arn](#input\_iam\_permissions\_boundary\_arn) | Permissions boundary to apply to all IAM roles created by this module | `string` | `null` | no |
| <a name="input_proxy_nameservers"></a> [proxy\_nameservers](#input\_proxy\_nameservers) | Customer configured nameserver ips | `list(string)` | n/a | yes |
| <a name="input_proxy_nic_ip"></a> [proxy\_nic\_ip](#input\_proxy\_nic\_ip) | Nic ip for the glean proxy vm instance | `string` | n/a | yes |
| <a name="input_proxy_onprem_ips"></a> [proxy\_onprem\_ips](#input\_proxy\_onprem\_ips) | Customer configured onprem ips | `list(string)` | n/a | yes |
| <a name="input_proxy_private_route_table_id"></a> [proxy\_private\_route\_table\_id](#input\_proxy\_private\_route\_table\_id) | Private route table id for the glean proxy vm instance | `string` | n/a | yes |
| <a name="input_proxy_private_subnet_id"></a> [proxy\_private\_subnet\_id](#input\_proxy\_private\_subnet\_id) | Private subnet id for the glean proxy vm instance | `string` | n/a | yes |
| <a name="input_proxy_remote_subnets"></a> [proxy\_remote\_subnets](#input\_proxy\_remote\_subnets) | Customer configured remote subnet cidrs | `list(string)` | n/a | yes |
| <a name="input_proxy_vpc_id"></a> [proxy\_vpc\_id](#input\_proxy\_vpc\_id) | VPC id for the glean proxy vm instance | `string` | n/a | yes |
| <a name="input_ready_for_peering"></a> [ready\_for\_peering](#input\_ready\_for\_peering) | Boolean to indicate if the peer gateway is ready for peering | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which the resources will be created | `string` | n/a | yes |
| <a name="input_tgw_peer_account_id"></a> [tgw\_peer\_account\_id](#input\_tgw\_peer\_account\_id) | The account id of the peer gateway | `string` | `null` | no |
| <a name="input_tgw_peer_gateway_id"></a> [tgw\_peer\_gateway\_id](#input\_tgw\_peer\_gateway\_id) | The id of the peer gateway | `string` | `null` | no |
| <a name="input_tgw_peer_region"></a> [tgw\_peer\_region](#input\_tgw\_peer\_region) | The region of the peer gateway | `string` | `null` | no |
| <a name="input_tgw_peered_attachment_id"></a> [tgw\_peered\_attachment\_id](#input\_tgw\_peered\_attachment\_id) | The id of the peered attachment | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tgw_id"></a> [tgw\_id](#output\_tgw\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
