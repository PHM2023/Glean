# elasticache

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.15.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_cluster.memcached_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster) | resource |
| [aws_elasticache_subnet_group.elasticache_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_security_group.elasticache_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_eks_elasticache_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_private_subnet_id"></a> [eks\_private\_subnet\_id](#input\_eks\_private\_subnet\_id) | ID of the eks private subnet | `string` | n/a | yes |
| <a name="input_eks_security_group_id"></a> [eks\_security\_group\_id](#input\_eks\_security\_group\_id) | ID of the EKS security group | `string` | n/a | yes |
| <a name="input_elasticache_cluster_node_type"></a> [elasticache\_cluster\_node\_type](#input\_elasticache\_cluster\_node\_type) | The node type for the memcached cluster | `string` | `"cache.t4g.small"` | no |
| <a name="input_elasticache_memcached_version"></a> [elasticache\_memcached\_version](#input\_elasticache\_memcached\_version) | The version of memcached to use in the elasticache cluster | `string` | `"1.6.17"` | no |
| <a name="input_elasticache_num_nodes"></a> [elasticache\_num\_nodes](#input\_elasticache\_num\_nodes) | Number of memcached nodes to use | `number` | `1` | no |
| <a name="input_elasticache_vpc_id"></a> [elasticache\_vpc\_id](#input\_elasticache\_vpc\_id) | VPC ID to use for the elasticache subnet group | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_discovery_endpoint"></a> [discovery\_endpoint](#output\_discovery\_endpoint) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
