# vpn

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.34.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_customer_gateway.customer_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) | resource |
| [aws_route.private_ip_proxy_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.proxy_nameserver_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.proxy_onprem_ip_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.proxy_remote_subnet_routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_vpn_connection.proxy_vpn_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection) | resource |
| [aws_vpn_connection_route.proxy_vpn_connection_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection_route) | resource |
| [aws_vpn_gateway.vpn_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) | resource |
| [aws_vpn_gateway_attachment.vpn_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_attachment) | resource |
| [aws_route_table.proxy_private_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table) | data source |
| [aws_vpc.proxy_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_permissions_boundary_arn"></a> [iam\_permissions\_boundary\_arn](#input\_iam\_permissions\_boundary\_arn) | Permissions boundary to apply to all IAM roles created by this module | `string` | `null` | no |
| <a name="input_proxy_nameservers"></a> [proxy\_nameservers](#input\_proxy\_nameservers) | Customer configured nameserver ips | `list(string)` | n/a | yes |
| <a name="input_proxy_onprem_ips"></a> [proxy\_onprem\_ips](#input\_proxy\_onprem\_ips) | Customer configured onprem ips | `list(string)` | n/a | yes |
| <a name="input_proxy_remote_subnets"></a> [proxy\_remote\_subnets](#input\_proxy\_remote\_subnets) | Customer configured remote subnet cidrs | `list(string)` | n/a | yes |
| <a name="input_vpn_peer_ip"></a> [vpn\_peer\_ip](#input\_vpn\_peer\_ip) | The ip of the peer for VPN connection | `string` | n/a | yes |
| <a name="input_vpn_shared_secret"></a> [vpn\_shared\_secret](#input\_vpn\_shared\_secret) | The encrypted shared secret for the VPN connection | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
