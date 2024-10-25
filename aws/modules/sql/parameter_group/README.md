# parameter_group

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_parameter_group.parameter_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_character_set_server"></a> [character\_set\_server](#input\_character\_set\_server) | character\_set\_server | `string` | `"utf8mb4"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_event_scheduler"></a> [event\_scheduler](#input\_event\_scheduler) | event\_scheduler | `string` | `"on"` | no |
| <a name="input_innodb_online_alter_log_max_size"></a> [innodb\_online\_alter\_log\_max\_size](#input\_innodb\_online\_alter\_log\_max\_size) | innodb\_online\_alter\_log\_max\_size | `string` | `"536870912"` | no |
| <a name="input_instance_specific_flags"></a> [instance\_specific\_flags](#input\_instance\_specific\_flags) | Additional instance-specific parameters | `map(string)` | `{}` | no |
| <a name="input_log_bin_trust_function_creators"></a> [log\_bin\_trust\_function\_creators](#input\_log\_bin\_trust\_function\_creators) | log\_bin\_trust\_function\_creators | `string` | `"1"` | no |
| <a name="input_log_output"></a> [log\_output](#input\_log\_output) | log\_output | `string` | `"FILE"` | no |
| <a name="input_long_query_time"></a> [long\_query\_time](#input\_long\_query\_time) | long\_query\_time | `string` | n/a | yes |
| <a name="input_max_allowed_packet"></a> [max\_allowed\_packet](#input\_max\_allowed\_packet) | max\_allowed\_packet | `string` | `"1073741824"` | no |
| <a name="input_max_connections"></a> [max\_connections](#input\_max\_connections) | max\_connections | `string` | `"1000"` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Name of the parameter group | `string` | n/a | yes |
| <a name="input_slow_query_log"></a> [slow\_query\_log](#input\_slow\_query\_log) | slow\_query\_log | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_parameter_group_name"></a> [parameter\_group\_name](#output\_parameter\_group\_name) | The name of the parameter group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
