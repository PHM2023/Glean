# config_update

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_job.config_update_job](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_key_values"></a> [config\_key\_values](#input\_config\_key\_values) | Map of config key values to update - should only be set if `path`==config\_update. If any config values are `null` they will be removed from the config if set | `map(string)` | `{}` | no |
| <a name="input_general_info"></a> [general\_info](#input\_general\_info) | Inputs that should (generally) be shared by all config update jobs | <pre>object({<br>    version_tag                 = string<br>    app_name_env_vars           = list(string)<br>    config_handler_image_uri    = string<br>    default_env_vars            = map(string)<br>    namespace                   = string<br>    nodegroup                   = string<br>    nodegroup_node_selector_key = string<br>    referential_env_vars        = map(string)<br>    service_account             = string<br>  })</pre> | n/a | yes |
| <a name="input_ipjc_channel_path"></a> [ipjc\_channel\_path](#input\_ipjc\_channel\_path) | Channel path to use when making an ipjc update - should only be set if `path`==ipjc\_update | `string` | `""` | no |
| <a name="input_ipjc_request_body"></a> [ipjc\_request\_body](#input\_ipjc\_request\_body) | IPJC request body when making an ipjc update - should only be set if `path`==ipjc\_update | `string` | `""` | no |
| <a name="input_path"></a> [path](#input\_path) | The path to invoke in the config handler run - should be one of: config\_update, ipjc\_update | `string` | n/a | yes |
| <a name="input_retries"></a> [retries](#input\_retries) | Number of retries to allow | `number` | `2` | no |
| <a name="input_timeout_minutes"></a> [timeout\_minutes](#input\_timeout\_minutes) | Timeout for job in minutes | `number` | `20` | no |
| <a name="input_update_name"></a> [update\_name](#input\_update\_name) | The name of the operation. Should be a valid Glean DeployOperation enum | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
