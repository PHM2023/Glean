# probe_initiator

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
| [aws_iam_policy.probe_initiator_invoker_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.read_probe_initiator_credentials_secrets_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.probe_initiator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lambda_function.probe_initiator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_iam_policy.basic_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.vpc_access_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The account id to create the function in | `string` | n/a | yes |
| <a name="input_config_bucket_reader_policy_arn"></a> [config\_bucket\_reader\_policy\_arn](#input\_config\_bucket\_reader\_policy\_arn) | ARN of the config bucket reader IAM policy | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_iam_permissions_boundary_arn"></a> [iam\_permissions\_boundary\_arn](#input\_iam\_permissions\_boundary\_arn) | Permissions boundary to apply to all IAM roles created by this module | `string` | `null` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | The image run by the lambda | `string` | n/a | yes |
| <a name="input_lambda_security_group_id"></a> [lambda\_security\_group\_id](#input\_lambda\_security\_group\_id) | ID of the lambda security group | `string` | n/a | yes |
| <a name="input_lambda_subnet_id"></a> [lambda\_subnet\_id](#input\_lambda\_subnet\_id) | ID of the lambda private subnet | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to create the function in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_probe_initiator_invoker_policy_arn"></a> [probe\_initiator\_invoker\_policy\_arn](#output\_probe\_initiator\_invoker\_policy\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
