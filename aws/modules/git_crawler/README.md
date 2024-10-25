# git_crawler

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.49.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.disk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_iam_instance_profile.git_crawler_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.crawl_temp_bucket_reader_writer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecr_fetch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.git_crawler_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_instance.git_crawler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_volume_attachment.git_crawler_ebs_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy.amazon_ssm_managed_instance_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | aws account id | `string` | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone for git-crawler instance | `string` | n/a | yes |
| <a name="input_cloud_watch_logs_policy_arn"></a> [cloud\_watch\_logs\_policy\_arn](#input\_cloud\_watch\_logs\_policy\_arn) | ARN of the glean cloudwatch logs IAM policy | `string` | n/a | yes |
| <a name="input_config_bucket_reader_policy_arn"></a> [config\_bucket\_reader\_policy\_arn](#input\_config\_bucket\_reader\_policy\_arn) | ARN of the config bucket reader policy | `string` | n/a | yes |
| <a name="input_crawl_temp_bucket"></a> [crawl\_temp\_bucket](#input\_crawl\_temp\_bucket) | ID of the crawl temp bucket | `string` | n/a | yes |
| <a name="input_crawl_temp_bucket_arn"></a> [crawl\_temp\_bucket\_arn](#input\_crawl\_temp\_bucket\_arn) | ARN of the crawl temp bucket | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | ebs disk size | `string` | n/a | yes |
| <a name="input_git_crawler_security_group"></a> [git\_crawler\_security\_group](#input\_git\_crawler\_security\_group) | Security group id for git-crawler instance | `string` | n/a | yes |
| <a name="input_git_crawler_subnet_id"></a> [git\_crawler\_subnet\_id](#input\_git\_crawler\_subnet\_id) | ID of private subnet for git-crawler instance. | `string` | n/a | yes |
| <a name="input_iam_permissions_boundary_arn"></a> [iam\_permissions\_boundary\_arn](#input\_iam\_permissions\_boundary\_arn) | Permissions boundary to apply to all IAM roles created by this module | `string` | `null` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | git crawler image uri | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | machine type | `string` | `"t3.medium"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_git_crawler_private_ip"></a> [git\_crawler\_private\_ip](#output\_git\_crawler\_private\_ip) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
