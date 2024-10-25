# s3_exporter

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.30.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.airflow_rds_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_secretsmanager_secret.airflow_rds_instance_root_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.airflow_rds_instance_root_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.airflow_rds_instance_root_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_db_subnet_group.rds_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_subnet_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_airflow_instance_class"></a> [airflow\_instance\_class](#input\_airflow\_instance\_class) | The instance class for the airflow sql instance | `string` | n/a | yes |
| <a name="input_max_storage"></a> [max\_storage](#input\_max\_storage) | Maximum storage till which aws will scale up the SQL instance | `number` | `100` | no |
| <a name="input_mysql_version"></a> [mysql\_version](#input\_mysql\_version) | The version of the MySQL engine to use for the RDS instances | `string` | `"8.0.32"` | no |
| <a name="input_rds_security_group"></a> [rds\_security\_group](#input\_rds\_security\_group) | Security group id for rds | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to create the lambda function in | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Initial storage allocated for the rds instance | `number` | `10` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
