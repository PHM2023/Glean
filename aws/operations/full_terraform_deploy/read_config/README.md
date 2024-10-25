# read_config

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [external_external.config_read](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID to use | `string` | n/a | yes |
| <a name="input_custom_config_path"></a> [custom\_config\_path](#input\_custom\_config\_path) | Path to custom.ini config file (if set) | `string` | `null` | no |
| <a name="input_default_config_path"></a> [default\_config\_path](#input\_default\_config\_path) | Path to default.ini file | `string` | n/a | yes |
| <a name="input_keys"></a> [keys](#input\_keys) | List of config keys to read | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region in which to deploy Glean | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_values"></a> [values](#output\_values) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
