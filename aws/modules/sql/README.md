# sql

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.59.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backend_parameter_group"></a> [backend\_parameter\_group](#module\_backend\_parameter\_group) | ./parameter_group | n/a |
| <a name="module_backend_rds_instance"></a> [backend\_rds\_instance](#module\_backend\_rds\_instance) | ./rds_instance | n/a |
| <a name="module_backend_rds_instance_2"></a> [backend\_rds\_instance\_2](#module\_backend\_rds\_instance\_2) | ./rds_instance | n/a |
| <a name="module_frontend_parameter_group"></a> [frontend\_parameter\_group](#module\_frontend\_parameter\_group) | ./parameter_group | n/a |
| <a name="module_frontend_rds_instance"></a> [frontend\_rds\_instance](#module\_frontend\_rds\_instance) | ./rds_instance | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.rds_os_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_metric_filter.rds_active_memory_metric_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.rds_cpu_utilization_metric_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.rds_total_memory_metric_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_db_subnet_group.rds_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_policy.root_sql_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sql_connect_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.rds_enhanced_monitoring_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.rds_enhanced_monitoring_permissions_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID | `string` | n/a | yes |
| <a name="input_backend_backup_retention_period"></a> [backend\_backup\_retention\_period](#input\_backend\_backup\_retention\_period) | The number of days to retain the backups for the backend instance | `number` | n/a | yes |
| <a name="input_backend_instance_2_identifier"></a> [backend\_instance\_2\_identifier](#input\_backend\_instance\_2\_identifier) | The instance identifier for the second instance for multi backend instances | `string` | n/a | yes |
| <a name="input_backend_instance_class"></a> [backend\_instance\_class](#input\_backend\_instance\_class) | The instance class for the backend sql instance | `string` | n/a | yes |
| <a name="input_backend_instance_identifier"></a> [backend\_instance\_identifier](#input\_backend\_instance\_identifier) | Name of the backend sql instance | `string` | `"be-instance"` | no |
| <a name="input_backend_instance_storage"></a> [backend\_instance\_storage](#input\_backend\_instance\_storage) | Initial storage allocated for the frontend instance | `number` | n/a | yes |
| <a name="input_backend_long_query_time"></a> [backend\_long\_query\_time](#input\_backend\_long\_query\_time) | long\_query\_time db param value for backend instance | `string` | n/a | yes |
| <a name="input_backend_multi_instance_count"></a> [backend\_multi\_instance\_count](#input\_backend\_multi\_instance\_count) | The count of second multi instance (should be 0 or 1 to indicated disabled/enabled) | `number` | n/a | yes |
| <a name="input_backend_parameter_group_name"></a> [backend\_parameter\_group\_name](#input\_backend\_parameter\_group\_name) | Name of the backend instance parameter group | `string` | n/a | yes |
| <a name="input_backend_slow_query_log"></a> [backend\_slow\_query\_log](#input\_backend\_slow\_query\_log) | slow\_query\_log db param value for backend instance | `string` | n/a | yes |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Backups are created in this time window | `string` | n/a | yes |
| <a name="input_db_debug_user"></a> [db\_debug\_user](#input\_db\_debug\_user) | The MySQL user name for a user with read-only (debug) access to RDS instances | `string` | `"glean_debug"` | no |
| <a name="input_db_user"></a> [db\_user](#input\_db\_user) | The MySQL user name for the main user of RDS instances | `string` | `"glean"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_frontend_backup_retention_period"></a> [frontend\_backup\_retention\_period](#input\_frontend\_backup\_retention\_period) | The number of days to retain the backups for the frontend instance | `number` | n/a | yes |
| <a name="input_frontend_instance_class"></a> [frontend\_instance\_class](#input\_frontend\_instance\_class) | The instance class for the frontend sql instance | `string` | n/a | yes |
| <a name="input_frontend_instance_identifier"></a> [frontend\_instance\_identifier](#input\_frontend\_instance\_identifier) | Name of the frontend sql instance | `string` | `"fe-instance"` | no |
| <a name="input_frontend_instance_storage"></a> [frontend\_instance\_storage](#input\_frontend\_instance\_storage) | Initial storage allocated for the frontend instance | `number` | n/a | yes |
| <a name="input_frontend_long_query_time"></a> [frontend\_long\_query\_time](#input\_frontend\_long\_query\_time) | long\_query\_time db param value for frontend instance | `string` | n/a | yes |
| <a name="input_frontend_parameter_group_name"></a> [frontend\_parameter\_group\_name](#input\_frontend\_parameter\_group\_name) | Name of the frontend instance parameter group | `string` | n/a | yes |
| <a name="input_frontend_slow_query_log"></a> [frontend\_slow\_query\_log](#input\_frontend\_slow\_query\_log) | slow\_query\_log db param value for frontend instance | `string` | `"1"` | no |
| <a name="input_iam_permissions_boundary_arn"></a> [iam\_permissions\_boundary\_arn](#input\_iam\_permissions\_boundary\_arn) | Permissions boundary to apply to all IAM roles created by this module | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Changes to the rds instance go through in this window (downtime is expected in this window) | `string` | n/a | yes |
| <a name="input_max_storage"></a> [max\_storage](#input\_max\_storage) | Maximum storage till which aws will scale up the SQL instance | `number` | n/a | yes |
| <a name="input_mysql_version"></a> [mysql\_version](#input\_mysql\_version) | The version of the MySQL engine to use for the RDS instances | `string` | `"8.0.35"` | no |
| <a name="input_rds_security_group"></a> [rds\_security\_group](#input\_rds\_security\_group) | Security group id for rds | `string` | n/a | yes |
| <a name="input_rds_subnets"></a> [rds\_subnets](#input\_rds\_subnets) | subnets used by rds | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to create the lambda function in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_sql_instance_id"></a> [backend\_sql\_instance\_id](#output\_backend\_sql\_instance\_id) | n/a |
| <a name="output_frontend_sql_instance_id"></a> [frontend\_sql\_instance\_id](#output\_frontend\_sql\_instance\_id) | n/a |
| <a name="output_root_sql_access_policy_arn"></a> [root\_sql\_access\_policy\_arn](#output\_root\_sql\_access\_policy\_arn) | n/a |
| <a name="output_sql_connect_policy_arn"></a> [sql\_connect\_policy\_arn](#output\_sql\_connect\_policy\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
