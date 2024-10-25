# bastion

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tgw"></a> [tgw](#module\_tgw) | ./tgw | n/a |
| <a name="module_vpn"></a> [vpn](#module\_vpn) | ./vpn | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eip.proxy_nat_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.proxy_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_instance.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.proxy_vpc_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_lb.proxy_vpc_endpoint_service_inbound_from_glean_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.proxy_vpc_endpoint_inbound_from_glean_nlb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.proxy_vpc_endpoint_service_inbound_from_glean_nlb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.proxy_vpc_endpoint_inbound_from_glean_nlb_target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_nat_gateway.proxy_public_subnet_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_interface.proxy_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_route.proxy_private_subnet_to_proxy_public_subnet_nat_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.proxy_public_subnet_rtb_internet_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.proxy_private_subnet_rtb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.proxy_public_subnet_rtb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.proxy_private_subnet_rtb_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.proxy_public_subnet_rtb_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.glean_vpc_endpoint_outbound_to_proxy_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.glean_vpc_endpoint_service_nlb_inbound_from_proxy_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.proxy_nic_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.proxy_vpc_endpoint_outbound_to_glean_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.proxy_vpc_endpoint_service_nlb_inbound_from_glean_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.proxy_vpc_endpoint_outbound_to_glean_sg_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.proxy_vpc_endpoint_outbound_to_glean_sg_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.proxy_private_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.proxy_public_subnet_no_allocate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.proxy_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.glean_vpc_endpoint_outbound_to_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.proxy_ec2messages_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.proxy_ssm_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.proxy_ssmmessages_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.proxy_vpc_endpoint_outbound_to_glean](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_service.glean_vpc_endpoint_service_inbound_from_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) | resource |
| [aws_vpc_endpoint_service.proxy_vpc_endpoint_service_inbound_from_glean](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) | resource |
| [aws_vpc_security_group_ingress_rule.eks_proxy_ingress_allow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy.AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_lb.dse_internal_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_lb.glean_external_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_network_interface.glean_vpc_endpoint_outbound_to_proxy_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_interface) | data source |
| [aws_network_interface.proxy_vpc_endpoint_outbound_to_glean_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_interface) | data source |
| [aws_network_interface.proxy_vpc_endpoint_service_inbound_from_glean_nlb_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_interface) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Glean AWS account id | `string` | n/a | yes |
| <a name="input_bastion_security_group_id"></a> [bastion\_security\_group\_id](#input\_bastion\_security\_group\_id) | ID of bastion security group | `string` | n/a | yes |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | ID of EKS cluster security group | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_dse_internal_lb_hostname"></a> [dse\_internal\_lb\_hostname](#input\_dse\_internal\_lb\_hostname) | Hostname of the internal load balancer for DSE | `string` | n/a | yes |
| <a name="input_eks_cluster_security_group_id"></a> [eks\_cluster\_security\_group\_id](#input\_eks\_cluster\_security\_group\_id) | ID of EKS cluster security group | `string` | n/a | yes |
| <a name="input_eks_private_subnet_az"></a> [eks\_private\_subnet\_az](#input\_eks\_private\_subnet\_az) | Availability zone for eks private subnet | `string` | n/a | yes |
| <a name="input_eks_private_subnet_id"></a> [eks\_private\_subnet\_id](#input\_eks\_private\_subnet\_id) | ID of the eks private subnet | `string` | n/a | yes |
| <a name="input_glean_vpc_cidr_block"></a> [glean\_vpc\_cidr\_block](#input\_glean\_vpc\_cidr\_block) | CIDR block of Glean VPC | `string` | n/a | yes |
| <a name="input_glean_vpc_id"></a> [glean\_vpc\_id](#input\_glean\_vpc\_id) | ID of Glean VPC | `string` | n/a | yes |
| <a name="input_iam_permissions_boundary_arn"></a> [iam\_permissions\_boundary\_arn](#input\_iam\_permissions\_boundary\_arn) | Permissions boundary to apply to all IAM roles created by this module | `string` | `null` | no |
| <a name="input_onprem_host_aliases"></a> [onprem\_host\_aliases](#input\_onprem\_host\_aliases) | Map of onprem hosts to their corresponding IPs | `map(string)` | `{}` | no |
| <a name="input_proxy_image"></a> [proxy\_image](#input\_proxy\_image) | ECR Image tag for the proxy container | `string` | n/a | yes |
| <a name="input_proxy_nameservers"></a> [proxy\_nameservers](#input\_proxy\_nameservers) | Customer configured nameserver ips | `list(string)` | `[]` | no |
| <a name="input_proxy_onprem_ips"></a> [proxy\_onprem\_ips](#input\_proxy\_onprem\_ips) | Customer configured onprem ips | `list(string)` | `[]` | no |
| <a name="input_proxy_remote_subnets"></a> [proxy\_remote\_subnets](#input\_proxy\_remote\_subnets) | Customer configured remote subnet cidrs | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region | `string` | `"us-east-1"` | no |
| <a name="input_tgw_peer_account_id"></a> [tgw\_peer\_account\_id](#input\_tgw\_peer\_account\_id) | The account id of the peer gateway | `string` | `null` | no |
| <a name="input_tgw_peer_gateway_id"></a> [tgw\_peer\_gateway\_id](#input\_tgw\_peer\_gateway\_id) | The id of the peer gateway | `string` | `null` | no |
| <a name="input_tgw_peer_region"></a> [tgw\_peer\_region](#input\_tgw\_peer\_region) | The region of the peer gateway | `string` | `null` | no |
| <a name="input_tgw_peered_attachment_id"></a> [tgw\_peered\_attachment\_id](#input\_tgw\_peered\_attachment\_id) | The id of the peered attachment | `string` | `null` | no |
| <a name="input_transit_gateway_peering"></a> [transit\_gateway\_peering](#input\_transit\_gateway\_peering) | Whether to create a standalone transit gateway that the customer will handle linkage with | `bool` | `false` | no |
| <a name="input_transit_vpc_cidr"></a> [transit\_vpc\_cidr](#input\_transit\_vpc\_cidr) | CIDR for the transit network, in which the proxy will live. This should be a /26 CIDR | `string` | n/a | yes |
| <a name="input_vpn_peer_ip"></a> [vpn\_peer\_ip](#input\_vpn\_peer\_ip) | Customer's peer ip for VPN connection | `string` | `""` | no |
| <a name="input_vpn_shared_secret"></a> [vpn\_shared\_secret](#input\_vpn\_shared\_secret) | The shared secret for the VPN connection | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_glean_tgw_id"></a> [glean\_tgw\_id](#output\_glean\_tgw\_id) | n/a |
| <a name="output_proxy_ip"></a> [proxy\_ip](#output\_proxy\_ip) | n/a |
| <a name="output_transit_ip"></a> [transit\_ip](#output\_transit\_ip) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
