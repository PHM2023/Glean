# probe_initiator

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_subscription_filter.fluent_bit_application_log_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_iam_role.flink_direct_memory_oom_detection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lambda_function.flink_direct_memory_oom_detection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.flink_direct_memory_oom_cloud_watch_invoke_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_iam_policy.basic_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.lambda_vpc_access_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID | `string` | n/a | yes |
| <a name="input_config_bucket_reader_policy_arn"></a> [config\_bucket\_reader\_policy\_arn](#input\_config\_bucket\_reader\_policy\_arn) | ARN of the config bucket reader IAM policy | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_fluent_bit_application_log_group"></a> [fluent\_bit\_application\_log\_group](#input\_fluent\_bit\_application\_log\_group) | Name of the fluent bit application log group | `string` | n/a | yes |
| <a name="input_gcp_connector_project_id"></a> [gcp\_connector\_project\_id](#input\_gcp\_connector\_project\_id) | ID of the GCP connector project | `string` | n/a | yes |
| <a name="input_gcp_connector_project_number"></a> [gcp\_connector\_project\_number](#input\_gcp\_connector\_project\_number) | Number of the GCP connector project | `string` | n/a | yes |
| <a name="input_iam_permissions_boundary_arn"></a> [iam\_permissions\_boundary\_arn](#input\_iam\_permissions\_boundary\_arn) | Permissions boundary to apply to all IAM roles created by this module | `string` | `null` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | The image run by the lambda | `string` | n/a | yes |
| <a name="input_lambda_security_group_id"></a> [lambda\_security\_group\_id](#input\_lambda\_security\_group\_id) | ID of the lambda security group | `string` | n/a | yes |
| <a name="input_lambda_subnet_id"></a> [lambda\_subnet\_id](#input\_lambda\_subnet\_id) | ID of the lambda subnet | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to create the lambda function in | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
