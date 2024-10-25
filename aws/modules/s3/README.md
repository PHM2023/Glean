# s3

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.53.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.53.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_common_logging"></a> [common\_logging](#module\_common\_logging) | ../../../common/logging_sinks | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.config_bucket_reader_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.config_bucket_writer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dataflow_bucket_reader_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dataflow_bucket_writer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.docs_dump_bucket_reader_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.docs_dump_bucket_writer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.elastic_plugin_bucket_reader_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.elastic_plugin_bucket_writer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.elastic_snapshot_bucket_reader_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.elastic_snapshot_bucket_writer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.flink_artifacts_bucket_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.flink_buckets_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.flink_python_additional_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.query_metadata_buckets_reader_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.query_metadata_buckets_writer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.query_secrets_bucket_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.scio_activity_bucket_reader_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_s3_account_public_access_block.account_pab](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |
| [aws_s3_bucket.activity_export](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.async_operations_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.config_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.crawl_temp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.csv_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.dataflow_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.docs_dump_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.elastic_plugin_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.elastic_snapshots_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.entity_data_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.feedback_data_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.flink_artifacts_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.flink_checkpoints_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.flink_completed_jobs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.general_query_metadata_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.gitlab_identity_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.image_data_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.ingress_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.people_distance_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.persistent_query_metadata_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.query_greenlist_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.query_metadata_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.query_secrets_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.self_hosted_airflow_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.static_workflows_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.upgrade_operations_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.crawl_temp_expiration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.flink_artifacts_expiration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.flink_checkpoints_expiration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_object.initial_query_greenlist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) | resource |
| [aws_s3_bucket_policy.ingress_access_logs_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_versioning.async_operations_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.config_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.upgrade_op_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.synonyms_txt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_iam_policy_document.ingress_access_logs_bucket_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_disable_account_bpa"></a> [disable\_account\_bpa](#input\_disable\_account\_bpa) | This is for very special customers that want to manage their own AWS account-level S3 BPA settings. This should be FALSE by default. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to use for s3 bucket operations | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_activity_bucket_reader_policy_arn"></a> [activity\_bucket\_reader\_policy\_arn](#output\_activity\_bucket\_reader\_policy\_arn) | n/a |
| <a name="output_config_bucket_reader_policy_arn"></a> [config\_bucket\_reader\_policy\_arn](#output\_config\_bucket\_reader\_policy\_arn) | n/a |
| <a name="output_config_bucket_writer_policy_arn"></a> [config\_bucket\_writer\_policy\_arn](#output\_config\_bucket\_writer\_policy\_arn) | n/a |
| <a name="output_crawl_temp_bucket"></a> [crawl\_temp\_bucket](#output\_crawl\_temp\_bucket) | n/a |
| <a name="output_crawl_temp_bucket_arn"></a> [crawl\_temp\_bucket\_arn](#output\_crawl\_temp\_bucket\_arn) | n/a |
| <a name="output_csv_storage_bucket"></a> [csv\_storage\_bucket](#output\_csv\_storage\_bucket) | n/a |
| <a name="output_csv_storage_bucket_arn"></a> [csv\_storage\_bucket\_arn](#output\_csv\_storage\_bucket\_arn) | n/a |
| <a name="output_dataflow_bucket"></a> [dataflow\_bucket](#output\_dataflow\_bucket) | n/a |
| <a name="output_docs_dump_bucket"></a> [docs\_dump\_bucket](#output\_docs\_dump\_bucket) | n/a |
| <a name="output_docs_dump_bucket_arn"></a> [docs\_dump\_bucket\_arn](#output\_docs\_dump\_bucket\_arn) | n/a |
| <a name="output_docs_dump_bucket_reader_policy_arn"></a> [docs\_dump\_bucket\_reader\_policy\_arn](#output\_docs\_dump\_bucket\_reader\_policy\_arn) | n/a |
| <a name="output_elastic_plugin_bucket"></a> [elastic\_plugin\_bucket](#output\_elastic\_plugin\_bucket) | n/a |
| <a name="output_elastic_plugin_bucket_reader_policy_arn"></a> [elastic\_plugin\_bucket\_reader\_policy\_arn](#output\_elastic\_plugin\_bucket\_reader\_policy\_arn) | n/a |
| <a name="output_elastic_snapshot_bucket_reader_policy_arn"></a> [elastic\_snapshot\_bucket\_reader\_policy\_arn](#output\_elastic\_snapshot\_bucket\_reader\_policy\_arn) | n/a |
| <a name="output_elastic_snapshot_bucket_writer_policy_arn"></a> [elastic\_snapshot\_bucket\_writer\_policy\_arn](#output\_elastic\_snapshot\_bucket\_writer\_policy\_arn) | n/a |
| <a name="output_entity_data_bucket"></a> [entity\_data\_bucket](#output\_entity\_data\_bucket) | n/a |
| <a name="output_entity_data_bucket_arn"></a> [entity\_data\_bucket\_arn](#output\_entity\_data\_bucket\_arn) | n/a |
| <a name="output_feedback_data_bucket"></a> [feedback\_data\_bucket](#output\_feedback\_data\_bucket) | n/a |
| <a name="output_feedback_data_bucket_arn"></a> [feedback\_data\_bucket\_arn](#output\_feedback\_data\_bucket\_arn) | n/a |
| <a name="output_flink_artifacts_bucket"></a> [flink\_artifacts\_bucket](#output\_flink\_artifacts\_bucket) | n/a |
| <a name="output_flink_bucket_access_policy_arn"></a> [flink\_bucket\_access\_policy\_arn](#output\_flink\_bucket\_access\_policy\_arn) | n/a |
| <a name="output_flink_python_additional_permissions_policy_arn"></a> [flink\_python\_additional\_permissions\_policy\_arn](#output\_flink\_python\_additional\_permissions\_policy\_arn) | n/a |
| <a name="output_general_query_metadata_bucket"></a> [general\_query\_metadata\_bucket](#output\_general\_query\_metadata\_bucket) | n/a |
| <a name="output_gitlab_identity_bucket"></a> [gitlab\_identity\_bucket](#output\_gitlab\_identity\_bucket) | n/a |
| <a name="output_gitlab_identity_bucket_arn"></a> [gitlab\_identity\_bucket\_arn](#output\_gitlab\_identity\_bucket\_arn) | n/a |
| <a name="output_image_data_bucket"></a> [image\_data\_bucket](#output\_image\_data\_bucket) | n/a |
| <a name="output_image_data_bucket_arn"></a> [image\_data\_bucket\_arn](#output\_image\_data\_bucket\_arn) | n/a |
| <a name="output_ingress_logs_bucket"></a> [ingress\_logs\_bucket](#output\_ingress\_logs\_bucket) | n/a |
| <a name="output_ingress_logs_bucket_arn"></a> [ingress\_logs\_bucket\_arn](#output\_ingress\_logs\_bucket\_arn) | n/a |
| <a name="output_query_greenlist_bucket"></a> [query\_greenlist\_bucket](#output\_query\_greenlist\_bucket) | n/a |
| <a name="output_query_greenlist_bucket_arn"></a> [query\_greenlist\_bucket\_arn](#output\_query\_greenlist\_bucket\_arn) | n/a |
| <a name="output_query_metadata_bucket"></a> [query\_metadata\_bucket](#output\_query\_metadata\_bucket) | n/a |
| <a name="output_query_metadata_bucket_arn"></a> [query\_metadata\_bucket\_arn](#output\_query\_metadata\_bucket\_arn) | n/a |
| <a name="output_query_metadata_bucket_reader_policy_arn"></a> [query\_metadata\_bucket\_reader\_policy\_arn](#output\_query\_metadata\_bucket\_reader\_policy\_arn) | n/a |
| <a name="output_query_secrets_bucket"></a> [query\_secrets\_bucket](#output\_query\_secrets\_bucket) | n/a |
| <a name="output_query_secrets_bucket_arn"></a> [query\_secrets\_bucket\_arn](#output\_query\_secrets\_bucket\_arn) | n/a |
| <a name="output_query_secrets_bucket_reader_policy_arn"></a> [query\_secrets\_bucket\_reader\_policy\_arn](#output\_query\_secrets\_bucket\_reader\_policy\_arn) | n/a |
| <a name="output_self_hosted_airflow_logs_bucket_arn"></a> [self\_hosted\_airflow\_logs\_bucket\_arn](#output\_self\_hosted\_airflow\_logs\_bucket\_arn) | n/a |
| <a name="output_upgrade_operations_bucket"></a> [upgrade\_operations\_bucket](#output\_upgrade\_operations\_bucket) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
