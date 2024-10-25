# rds_instance

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.30.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.rds_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to apply to the instance | `map(string)` | `{}` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | The number of days to retain backups for | `number` | n/a | yes |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Backups are created in this time window | `string` | n/a | yes |
| <a name="input_db_root_user"></a> [db\_root\_user](#input\_db\_root\_user) | identifier for the user with root access | `string` | `"root"` | no |
| <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name) | db subnet group name | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Instance class (analogous to machine type) for the backend sql instance | `string` | n/a | yes |
| <a name="input_instance_identifier"></a> [instance\_identifier](#input\_instance\_identifier) | Name of the sql instance | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Changes to the rds instance go through in this window (downtime is expected in this window) | `string` | n/a | yes |
| <a name="input_max_storage"></a> [max\_storage](#input\_max\_storage) | Maximum storage till which aws will scale up the SQL instance | `number` | n/a | yes |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | arn of the role which permits rds to send enhanced monitoring metrics to cloudwatch | `string` | n/a | yes |
| <a name="input_mysql_version"></a> [mysql\_version](#input\_mysql\_version) | The version of the MySQL engine to use for the RDS instances | `string` | `"8.0.35"` | no |
| <a name="input_parameter_group_name"></a> [parameter\_group\_name](#input\_parameter\_group\_name) | Name of the sql instance | `string` | n/a | yes |
| <a name="input_rds_security_group"></a> [rds\_security\_group](#input\_rds\_security\_group) | Security group id for rds | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Initial storage allocated for the rds instance | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds_instance_arn"></a> [rds\_instance\_arn](#output\_rds\_instance\_arn) | n/a |
| <a name="output_rds_instance_id"></a> [rds\_instance\_id](#output\_rds\_instance\_id) | The ID of the RDS instance |
| <a name="output_root_secret_arn"></a> [root\_secret\_arn](#output\_root\_secret\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
