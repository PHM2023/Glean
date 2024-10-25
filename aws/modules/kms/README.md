# kms

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.53.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.53.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ipjc_signing_key_get_public_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ipjc_signing_key_sign_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.query_secrets_key_cryptor_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.secret_store_key_cryptor_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.slack_bot_key_get_public_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_alias.ipjc_signing_key_alias_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.ipjc_signing_key_alias_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.secret_store_key_alias_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.secret_store_key_alias_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.secrets_key_alias_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.secrets_key_alias_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.slack_bot_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.slack_bot_key_alias_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.tools_signing_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_ciphertext.query_service_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_ciphertext) | resource |
| [aws_kms_key.ipjc_signing_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.secret_store_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.secrets_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.slack_bot_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.tools_signing_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_object.query_service_secret_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [random_password.qp_secret_str](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_query_secrets_bucket"></a> [query\_secrets\_bucket](#input\_query\_secrets\_bucket) | ID of the query secrets bucket | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to use for kms operations | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ipjc_signing_key_arn"></a> [ipjc\_signing\_key\_arn](#output\_ipjc\_signing\_key\_arn) | n/a |
| <a name="output_ipjc_signing_key_get_public_key_policy_arn"></a> [ipjc\_signing\_key\_get\_public\_key\_policy\_arn](#output\_ipjc\_signing\_key\_get\_public\_key\_policy\_arn) | n/a |
| <a name="output_ipjc_signing_key_sign_policy_arn"></a> [ipjc\_signing\_key\_sign\_policy\_arn](#output\_ipjc\_signing\_key\_sign\_policy\_arn) | n/a |
| <a name="output_query_secret_key_cryptor_policy_arn"></a> [query\_secret\_key\_cryptor\_policy\_arn](#output\_query\_secret\_key\_cryptor\_policy\_arn) | n/a |
| <a name="output_query_secret_object_key"></a> [query\_secret\_object\_key](#output\_query\_secret\_object\_key) | n/a |
| <a name="output_secret_store_cryptor_policy_arn"></a> [secret\_store\_cryptor\_policy\_arn](#output\_secret\_store\_cryptor\_policy\_arn) | n/a |
| <a name="output_secret_store_key_arn"></a> [secret\_store\_key\_arn](#output\_secret\_store\_key\_arn) | n/a |
| <a name="output_secret_store_key_id"></a> [secret\_store\_key\_id](#output\_secret\_store\_key\_id) | n/a |
| <a name="output_slackbot_key_arn"></a> [slackbot\_key\_arn](#output\_slackbot\_key\_arn) | n/a |
| <a name="output_slackbot_key_get_public_key_policy_arn"></a> [slackbot\_key\_get\_public\_key\_policy\_arn](#output\_slackbot\_key\_get\_public\_key\_policy\_arn) | n/a |
| <a name="output_storage_secrets_key_arn"></a> [storage\_secrets\_key\_arn](#output\_storage\_secrets\_key\_arn) | n/a |
| <a name="output_tools_key_arn"></a> [tools\_key\_arn](#output\_tools\_key\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
