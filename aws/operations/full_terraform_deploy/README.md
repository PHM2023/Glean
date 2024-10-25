# full_terraform_deploy

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.53.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.53.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.3 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.3 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | ../../modules/acm | n/a |
| <a name="module_admin_image"></a> [admin\_image](#module\_admin\_image) | ./image_uri | n/a |
| <a name="module_alb_node_group"></a> [alb\_node\_group](#module\_alb\_node\_group) | ../../modules/eks_node_group_v2 | n/a |
| <a name="module_autoscaler_node_group"></a> [autoscaler\_node\_group](#module\_autoscaler\_node\_group) | ../../modules/eks_node_group_v2 | n/a |
| <a name="module_aws_k8s"></a> [aws\_k8s](#module\_aws\_k8s) | ./aws_k8s | n/a |
| <a name="module_basic_fim_image"></a> [basic\_fim\_image](#module\_basic\_fim\_image) | ./image_uri | n/a |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../modules/bastion | n/a |
| <a name="module_clamav_image"></a> [clamav\_image](#module\_clamav\_image) | ./image_uri | n/a |
| <a name="module_clamav_scanner_image"></a> [clamav\_scanner\_image](#module\_clamav\_scanner\_image) | ./image_uri | n/a |
| <a name="module_cloudwatch_metrics_exporter_phase_1"></a> [cloudwatch\_metrics\_exporter\_phase\_1](#module\_cloudwatch\_metrics\_exporter\_phase\_1) | ../../modules/cloudwatch_metrics_exporter_phase_1 | n/a |
| <a name="module_config_handler_image"></a> [config\_handler\_image](#module\_config\_handler\_image) | ./image_uri | n/a |
| <a name="module_crawler_image"></a> [crawler\_image](#module\_crawler\_image) | ./image_uri | n/a |
| <a name="module_crawler_nodegroup"></a> [crawler\_nodegroup](#module\_crawler\_nodegroup) | ../../modules/eks_node_group_v2 | n/a |
| <a name="module_cron_helper"></a> [cron\_helper](#module\_cron\_helper) | ../../modules/cron_helper | n/a |
| <a name="module_cron_helper_image"></a> [cron\_helper\_image](#module\_cron\_helper\_image) | ./dedicated_image | n/a |
| <a name="module_cron_job_node_group"></a> [cron\_job\_node\_group](#module\_cron\_job\_node\_group) | ../../modules/eks_node_group_v2 | n/a |
| <a name="module_deploy_build"></a> [deploy\_build](#module\_deploy\_build) | ../../modules/deploy_build | n/a |
| <a name="module_deploy_build_image"></a> [deploy\_build\_image](#module\_deploy\_build\_image) | ./dedicated_image | n/a |
| <a name="module_deploy_image"></a> [deploy\_image](#module\_deploy\_image) | ./image_uri | n/a |
| <a name="module_deploy_job_nodegroup"></a> [deploy\_job\_nodegroup](#module\_deploy\_job\_nodegroup) | ../../modules/eks_node_group_v2 | n/a |
| <a name="module_dse_image"></a> [dse\_image](#module\_dse\_image) | ./image_uri | n/a |
| <a name="module_eks_phase_1"></a> [eks\_phase\_1](#module\_eks\_phase\_1) | ../../modules/eks_phase_1 | n/a |
| <a name="module_elasticache"></a> [elasticache](#module\_elasticache) | ../../modules/elasticache | n/a |
| <a name="module_expunge_deleted_opensearch_docs"></a> [expunge\_deleted\_opensearch\_docs](#module\_expunge\_deleted\_opensearch\_docs) | ../../modules/expunge_deleted_opensearch_docs | n/a |
| <a name="module_expunge_deleted_opensearch_docs_image"></a> [expunge\_deleted\_opensearch\_docs\_image](#module\_expunge\_deleted\_opensearch\_docs\_image) | ./dedicated_image | n/a |
| <a name="module_flink_direct_memory_oom_detection"></a> [flink\_direct\_memory\_oom\_detection](#module\_flink\_direct\_memory\_oom\_detection) | ../../modules/flink_direct_memory_oom_detection | n/a |
| <a name="module_flink_direct_memory_oom_detection_image"></a> [flink\_direct\_memory\_oom\_detection\_image](#module\_flink\_direct\_memory\_oom\_detection\_image) | ./dedicated_image | n/a |
| <a name="module_flink_namespace_config_reads"></a> [flink\_namespace\_config\_reads](#module\_flink\_namespace\_config\_reads) | ./read_config | n/a |
| <a name="module_git_crawler"></a> [git\_crawler](#module\_git\_crawler) | ../../modules/git_crawler | n/a |
| <a name="module_git_crawler_configs"></a> [git\_crawler\_configs](#module\_git\_crawler\_configs) | ./read_config | n/a |
| <a name="module_git_crawler_image"></a> [git\_crawler\_image](#module\_git\_crawler\_image) | ./image_uri | n/a |
| <a name="module_iam"></a> [iam](#module\_iam) | ../../modules/iam | n/a |
| <a name="module_ingress_logs_processor"></a> [ingress\_logs\_processor](#module\_ingress\_logs\_processor) | ../../modules/ingress_logs_processor | n/a |
| <a name="module_ingress_logs_processor_image"></a> [ingress\_logs\_processor\_image](#module\_ingress\_logs\_processor\_image) | ./dedicated_image | n/a |
| <a name="module_k8s"></a> [k8s](#module\_k8s) | ../../../k8s/full_deploy | n/a |
| <a name="module_k8s_deployment_configs"></a> [k8s\_deployment\_configs](#module\_k8s\_deployment\_configs) | ./read_config | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | ../../modules/kms | n/a |
| <a name="module_lambda_ecr_repos"></a> [lambda\_ecr\_repos](#module\_lambda\_ecr\_repos) | ../../modules/lambda_ecr_repos | n/a |
| <a name="module_memory_based_large_nodegroup"></a> [memory\_based\_large\_nodegroup](#module\_memory\_based\_large\_nodegroup) | ../../modules/eks_node_group_v2 | n/a |
| <a name="module_memory_based_medium_nodegroup"></a> [memory\_based\_medium\_nodegroup](#module\_memory\_based\_medium\_nodegroup) | ../../modules/eks_node_group_v2 | n/a |
| <a name="module_memory_based_small_nodegroup"></a> [memory\_based\_small\_nodegroup](#module\_memory\_based\_small\_nodegroup) | ../../modules/eks_node_group_v2 | n/a |
| <a name="module_memory_based_xlarge_nodegroup"></a> [memory\_based\_xlarge\_nodegroup](#module\_memory\_based\_xlarge\_nodegroup) | ../../modules/eks_node_group_v2 | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/network | n/a |
| <a name="module_nodegroup_configs"></a> [nodegroup\_configs](#module\_nodegroup\_configs) | ./read_config | n/a |
| <a name="module_preprocess_sagemaker_training_base_image"></a> [preprocess\_sagemaker\_training\_base\_image](#module\_preprocess\_sagemaker\_training\_base\_image) | ./dedicated_image | n/a |
| <a name="module_probe_initiator"></a> [probe\_initiator](#module\_probe\_initiator) | ../../modules/probe_initiator | n/a |
| <a name="module_probe_initiator_image"></a> [probe\_initiator\_image](#module\_probe\_initiator\_image) | ./dedicated_image | n/a |
| <a name="module_proxy"></a> [proxy](#module\_proxy) | ../../modules/proxy | n/a |
| <a name="module_proxy_image"></a> [proxy\_image](#module\_proxy\_image) | ./image_uri | n/a |
| <a name="module_qe_image"></a> [qe\_image](#module\_qe\_image) | ./image_uri | n/a |
| <a name="module_qp_image"></a> [qp\_image](#module\_qp\_image) | ./image_uri | n/a |
| <a name="module_rabbitmq_config_read"></a> [rabbitmq\_config\_read](#module\_rabbitmq\_config\_read) | ./read_config | n/a |
| <a name="module_rabbitmq_nodegroup"></a> [rabbitmq\_nodegroup](#module\_rabbitmq\_nodegroup) | ../../modules/eks_node_group_v2 | n/a |
| <a name="module_redis_image"></a> [redis\_image](#module\_redis\_image) | ./image_uri | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | ../../modules/s3 | n/a |
| <a name="module_s3_configs_read"></a> [s3\_configs\_read](#module\_s3\_configs\_read) | ./read_config | n/a |
| <a name="module_s3_exporter"></a> [s3\_exporter](#module\_s3\_exporter) | ../../modules/s3_exporter | n/a |
| <a name="module_s3_exporter_image"></a> [s3\_exporter\_image](#module\_s3\_exporter\_image) | ./dedicated_image | n/a |
| <a name="module_scholastic_image"></a> [scholastic\_image](#module\_scholastic\_image) | ./image_uri | n/a |
| <a name="module_sns"></a> [sns](#module\_sns) | ../../modules/sns | n/a |
| <a name="module_sql"></a> [sql](#module\_sql) | ../../modules/sql | n/a |
| <a name="module_sql_configs"></a> [sql\_configs](#module\_sql\_configs) | ./read_config | n/a |
| <a name="module_stackdriver_exporter"></a> [stackdriver\_exporter](#module\_stackdriver\_exporter) | ../../modules/stackdriver_exporter | n/a |
| <a name="module_stackdriver_exporter_image"></a> [stackdriver\_exporter\_image](#module\_stackdriver\_exporter\_image) | ./dedicated_image | n/a |
| <a name="module_task_push_image"></a> [task\_push\_image](#module\_task\_push\_image) | ./image_uri | n/a |
| <a name="module_task_push_nodegroup"></a> [task\_push\_nodegroup](#module\_task\_push\_nodegroup) | ../../modules/eks_node_group_v2 | n/a |
| <a name="module_upgrade_opensearch_nodepool"></a> [upgrade\_opensearch\_nodepool](#module\_upgrade\_opensearch\_nodepool) | ../../modules/upgrade_opensearch_nodepool | n/a |
| <a name="module_upgrade_opensearch_nodepool_image"></a> [upgrade\_opensearch\_nodepool\_image](#module\_upgrade\_opensearch\_nodepool\_image) | ./dedicated_image | n/a |
| <a name="module_waf"></a> [waf](#module\_waf) | ../../modules/waf | n/a |
| <a name="module_waf_configs_read"></a> [waf\_configs\_read](#module\_waf\_configs\_read) | ./read_config | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.additional_flink_java_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.admin_console_additional_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.alb_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cluster_autoscaler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.deploy_job_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dse_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.flink_invoker_additional_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_invoker_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.qe_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.self_hosted_airflow_logs_bucket_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.self_hosted_airflow_read_central_dags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.self_hosted_airflow_read_test_dags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.task_handlers_additional_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.admin_console_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.alb_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cluster_autoscaler_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.deploy_job_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.dse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.elastic_compute_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.flink_invoker_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.flink_java_jobs_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.flink_python_jobs_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.flink_watchdog_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.gmp_collector_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_invoker_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.qe_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.query_parser_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.scholastic_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.self_hosted_airflow_nodes_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_handlers_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_push_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_servicequotas_service_quota.eks_nodegroups_per_cluster_service_quota](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicequotas_service_quota) | resource |
| [null_resource.delete_old_proxy_tgw](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.version_check](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_iam_policy.cloudwatch_agent_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_role.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_iam_role.glean_viewer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_secretsmanager_secret.ipjc_auth_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_servicequotas_service.eks_servicequota_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/servicequotas_service) | data source |
| [aws_servicequotas_service_quota.eks_nodegroups_per_cluster_service_quota](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/servicequotas_service_quota) | data source |
| [external_external.backend_sql_configs](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.proxy_configs](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.ssh_tunnel](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [http_http.alb_policy_contents](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [local_file.set_google_credentials_in_aws_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input__do_not_set_manually_pipelines_list"></a> [\_do\_not\_set\_manually\_pipelines\_list](#input\_\_do\_not\_set\_manually\_pipelines\_list) | List of Glean pipeline jobs to enable | `list(string)` | n/a | yes |
| <a name="input__launch_templates_with_volume_tags_defined_first"></a> [\_launch\_templates\_with\_volume\_tags\_defined\_first](#input\_\_launch\_templates\_with\_volume\_tags\_defined\_first) | List of launch template names where the volume tags should be defined first | `list(string)` | `[]` | no |
| <a name="input__pre_existing_redis_nodegroup_name"></a> [\_pre\_existing\_redis\_nodegroup\_name](#input\_\_pre\_existing\_redis\_nodegroup\_name) | Pre-existing redis nodegroup name - only set if not using the memory based nodegroups | `string` | `null` | no |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID to use | `string` | n/a | yes |
| <a name="input_additional_k8s_admin_role_arns"></a> [additional\_k8s\_admin\_role\_arns](#input\_additional\_k8s\_admin\_role\_arns) | Additional role arns to grant k8s admin access | `list(string)` | `[]` | no |
| <a name="input_allow_canary_ipjc_ingress"></a> [allow\_canary\_ipjc\_ingress](#input\_allow\_canary\_ipjc\_ingress) | Whether to allow ipjc ingress traffic from the canary central project | `bool` | `false` | no |
| <a name="input_allow_untrusted_images"></a> [allow\_untrusted\_images](#input\_allow\_untrusted\_images) | Whether or not to allow untrusted images - should only be set for test projects | `bool` | `false` | no |
| <a name="input_bastion_instance_type"></a> [bastion\_instance\_type](#input\_bastion\_instance\_type) | Instance type to use for bastion proxy instance. Override this to increase bastion throughput | `string` | `"m4.xlarge"` | no |
| <a name="input_bastion_port"></a> [bastion\_port](#input\_bastion\_port) | The port on which to open bastion connections | `number` | `7999` | no |
| <a name="input_custom_config_path"></a> [custom\_config\_path](#input\_custom\_config\_path) | Path to custom.ini config file (if set) | `string` | `null` | no |
| <a name="input_default_config_path"></a> [default\_config\_path](#input\_default\_config\_path) | Path to default.ini config file | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_disable_account_bpa"></a> [disable\_account\_bpa](#input\_disable\_account\_bpa) | This is for very special customers that want to manage their own AWS account-level S3 BPA settings. This should be FALSE by default. | `bool` | `false` | no |
| <a name="input_gcp_collector_service_account_client_id"></a> [gcp\_collector\_service\_account\_client\_id](#input\_gcp\_collector\_service\_account\_client\_id) | OAuth2 client ID used to collect native metrics from CloudWatch periodically | `string` | n/a | yes |
| <a name="input_gcp_connector_project_id"></a> [gcp\_connector\_project\_id](#input\_gcp\_connector\_project\_id) | Project ID of the Glean-owned GCP project used for monitoring and observability of the Glean instance | `string` | n/a | yes |
| <a name="input_gcp_connector_project_number"></a> [gcp\_connector\_project\_number](#input\_gcp\_connector\_project\_number) | Project number of the Glean-owned GCP project used for monitoring and observability | `string` | n/a | yes |
| <a name="input_glean_instance_name"></a> [glean\_instance\_name](#input\_glean\_instance\_name) | The dedicated Glean instance name to use | `string` | n/a | yes |
| <a name="input_iam_permissions_boundary_arn"></a> [iam\_permissions\_boundary\_arn](#input\_iam\_permissions\_boundary\_arn) | Permissions boundary to apply to all IAM roles created by this module | `string` | `null` | no |
| <a name="input_ingress_paths_root"></a> [ingress\_paths\_root](#input\_ingress\_paths\_root) | Path to folder container all yamls with relevant k8s ingress rules | `string` | n/a | yes |
| <a name="input_initial_deployment_tier"></a> [initial\_deployment\_tier](#input\_initial\_deployment\_tier) | The deployment tier for the Glean instance, must be one of: small, medium, large, xlarge. Must also be set on initial setup | `string` | `""` | no |
| <a name="input_rabbitmq_disk_size_override"></a> [rabbitmq\_disk\_size\_override](#input\_rabbitmq\_disk\_size\_override) | An override for the rabbitmq disk size to handle the case where we didn't update the config for old nodegroups using a different scheme to seed the storage size | `number` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region in which to deploy Glean | `string` | n/a | yes |
| <a name="input_rollout_id"></a> [rollout\_id](#input\_rollout\_id) | Rollout ID to use for each restartable k8s app. If this changes, the app will be restarted | `string` | n/a | yes |
| <a name="input_use_bastion"></a> [use\_bastion](#input\_use\_bastion) | Whether or not to use a bastion connection for k8s resources. Should only be set to true if not running in the glean-vpc (i.e. on the initial setup or from a standalone process) | `bool` | `true` | no |
| <a name="input_version_tag"></a> [version\_tag](#input\_version\_tag) | The Glean version tag to use | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_last_version_used"></a> [last\_version\_used](#output\_last\_version\_used) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
