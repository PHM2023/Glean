# ingress_logs_processor

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.additional_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ingress_logs_reader_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ingress_access_logs_exporter_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lambda_function.ingress_logs_processor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_event_invoke_config.ingress_logs_processor_lambda_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config) | resource |
| [aws_lambda_permission.allow_ingress_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.ingress_access_logs_bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_iam_policy.basic_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID | `string` | n/a | yes |
| <a name="input_config_bucket_reader_policy_arn"></a> [config\_bucket\_reader\_policy\_arn](#input\_config\_bucket\_reader\_policy\_arn) | ARN of the config bucket reader IAM policy | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_gcp_connector_project_id"></a> [gcp\_connector\_project\_id](#input\_gcp\_connector\_project\_id) | ID of the GCP connector project | `string` | n/a | yes |
| <a name="input_gcp_connector_project_number"></a> [gcp\_connector\_project\_number](#input\_gcp\_connector\_project\_number) | Number of the GCP connector project | `string` | n/a | yes |
| <a name="input_iam_permissions_boundary_arn"></a> [iam\_permissions\_boundary\_arn](#input\_iam\_permissions\_boundary\_arn) | Permissions boundary to apply to all IAM roles created by this module | `string` | `null` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | The image run by the lambda | `string` | n/a | yes |
| <a name="input_ingress_logs_bucket"></a> [ingress\_logs\_bucket](#input\_ingress\_logs\_bucket) | Ingress logs bucket ID | `string` | n/a | yes |
| <a name="input_ingress_logs_bucket_arn"></a> [ingress\_logs\_bucket\_arn](#input\_ingress\_logs\_bucket\_arn) | ARN of the ingress logs bucket | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to use when creating the buckets | `string` | `"us-east-1"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
