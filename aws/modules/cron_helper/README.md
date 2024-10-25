# cron_helper

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.19.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.cron_helper_additional_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cron_helper_amazon_eks_nodegroup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cron_helper_invoker_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cron_helper_storage_secret_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cron_helper](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.glean_cron_helper_invoker_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cron_helper_invoker_deploy_build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.cron_helper](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_iam_role.deploy_build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The account id | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster | `string` | n/a | yes |
| <a name="input_config_bucket_reader_policy_arn"></a> [config\_bucket\_reader\_policy\_arn](#input\_config\_bucket\_reader\_policy\_arn) | ARN of the config bucket reader IAM policy | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_eks_cluster_role_arn"></a> [eks\_cluster\_role\_arn](#input\_eks\_cluster\_role\_arn) | ARN of eks cluster role | `string` | n/a | yes |
| <a name="input_eks_worker_node_arn"></a> [eks\_worker\_node\_arn](#input\_eks\_worker\_node\_arn) | ARN of the eks worker node IAM role | `string` | n/a | yes |
| <a name="input_gcp_connector_project_id"></a> [gcp\_connector\_project\_id](#input\_gcp\_connector\_project\_id) | ID of the GCP connector project | `string` | n/a | yes |
| <a name="input_gcp_connector_project_number"></a> [gcp\_connector\_project\_number](#input\_gcp\_connector\_project\_number) | Number of the GCP connector project | `string` | n/a | yes |
| <a name="input_iam_permissions_boundary_arn"></a> [iam\_permissions\_boundary\_arn](#input\_iam\_permissions\_boundary\_arn) | Permissions boundary to apply to all IAM roles created by this module | `string` | `null` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | The image run by the lambda | `string` | n/a | yes |
| <a name="input_ipjc_key_arn"></a> [ipjc\_key\_arn](#input\_ipjc\_key\_arn) | ARN of the ipjc signing key | `string` | n/a | yes |
| <a name="input_lambda_security_group_id"></a> [lambda\_security\_group\_id](#input\_lambda\_security\_group\_id) | ID of the lambda security group | `string` | n/a | yes |
| <a name="input_lambda_subnet_id"></a> [lambda\_subnet\_id](#input\_lambda\_subnet\_id) | ID of the lambda subnet | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to create the lambda function in | `string` | n/a | yes |
| <a name="input_storage_secret_key_arn"></a> [storage\_secret\_key\_arn](#input\_storage\_secret\_key\_arn) | ARN of the storage\_secrets key | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cron_helper_role_arn"></a> [cron\_helper\_role\_arn](#output\_cron\_helper\_role\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
