# aws_k8s

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.53.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | = 2.11.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.53.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.11.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.31.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_external_lb_dns_ipjc_update"></a> [external\_lb\_dns\_ipjc\_update](#module\_external\_lb\_dns\_ipjc\_update) | ../../../../k8s/config_update | n/a |
| <a name="module_ssl_cert_mapping_ipjc_update"></a> [ssl\_cert\_mapping\_ipjc\_update](#module\_ssl\_cert\_mapping\_ipjc\_update) | ../../../../k8s/config_update | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate_validation.acm_cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [helm_release.alb_helm_release](https://registry.terraform.io/providers/hashicorp/helm/2.11.0/docs/resources/release) | resource |
| [kubernetes_cluster_role.cloudwatch_agent_role_cluster_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.fluent_bit_cluster_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.cloudwatch_agent_cluster_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.fluent_bit_cluster_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding_v1.connector_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_cluster_role_binding_v1.glean_node_viewer_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_cluster_role_v1.node_viewer_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_v1) | resource |
| [kubernetes_config_map.cwagentconfig](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.fluent_bit_cluster_info_config_map](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.fluent_bit_config_map](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map_v1_data.aws_auth_config_map](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data) | resource |
| [kubernetes_daemonset.cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemonset) | resource |
| [kubernetes_daemonset.fluent_bit_daemonset](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemonset) | resource |
| [kubernetes_namespace.cloudwatch_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.opensearch_snapshot_web_identity_token_file_secret_1](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.opensearch_snapshot_web_identity_token_file_secret_2](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account.alb_controller_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.fluent_bit_serviceaccount](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_storage_class.ebs_csi_storage_class](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID to use | `string` | n/a | yes |
| <a name="input_additional_k8s_admin_role_arns"></a> [additional\_k8s\_admin\_role\_arns](#input\_additional\_k8s\_admin\_role\_arns) | List of role arns to grant master privileges on the cluster | `list(string)` | `[]` | no |
| <a name="input_alb_nodegroup"></a> [alb\_nodegroup](#input\_alb\_nodegroup) | Name of the nodegroup to use for the ALB controller | `string` | n/a | yes |
| <a name="input_alb_role_arn"></a> [alb\_role\_arn](#input\_alb\_role\_arn) | ARN of the IAM role to attach to ALB controller service account | `string` | n/a | yes |
| <a name="input_app_name_env_vars"></a> [app\_name\_env\_vars](#input\_app\_name\_env\_vars) | Any environment variables to attach to k8s workloads based on their app names | `list(string)` | `[]` | no |
| <a name="input_bastion_port"></a> [bastion\_port](#input\_bastion\_port) | The port on which to open bastion connections | `string` | `null` | no |
| <a name="input_cluster_ca_cert_data"></a> [cluster\_ca\_cert\_data](#input\_cluster\_ca\_cert\_data) | Base-64 encoded CA cert data for the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | The endpoint of the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_codebuild_role_arn"></a> [codebuild\_role\_arn](#input\_codebuild\_role\_arn) | ARN of the codebuild IAM role | `string` | n/a | yes |
| <a name="input_config_handler_image_uri"></a> [config\_handler\_image\_uri](#input\_config\_handler\_image\_uri) | Image URI to use for the the config\_handler runs (for making config/ipjc updates) | `string` | n/a | yes |
| <a name="input_cron_helper_role_arn"></a> [cron\_helper\_role\_arn](#input\_cron\_helper\_role\_arn) | ARN of the cron\_helper IAM role | `string` | n/a | yes |
| <a name="input_default_env_vars"></a> [default\_env\_vars](#input\_default\_env\_vars) | Any default environment variables to attach to k8s workloads | `map(string)` | `{}` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to attach k8s-created AWS resources via annotations | `map(string)` | n/a | yes |
| <a name="input_deploy_job_role_arn"></a> [deploy\_job\_role\_arn](#input\_deploy\_job\_role\_arn) | ARN of the deploy job IAM role | `string` | n/a | yes |
| <a name="input_deploy_jobs_namespace"></a> [deploy\_jobs\_namespace](#input\_deploy\_jobs\_namespace) | Name of the namespace to use for running deploy jobs | `string` | n/a | yes |
| <a name="input_deploy_jobs_nodegroup"></a> [deploy\_jobs\_nodegroup](#input\_deploy\_jobs\_nodegroup) | Name of the nodegroup to use for deploy jobs | `string` | n/a | yes |
| <a name="input_deploy_jobs_service_account"></a> [deploy\_jobs\_service\_account](#input\_deploy\_jobs\_service\_account) | Name of the service account to use for running deploy jobs | `string` | n/a | yes |
| <a name="input_eks_worker_node_arn"></a> [eks\_worker\_node\_arn](#input\_eks\_worker\_node\_arn) | ARN of the EKS worker node IAM role | `string` | n/a | yes |
| <a name="input_elastic_compute_role_arn"></a> [elastic\_compute\_role\_arn](#input\_elastic\_compute\_role\_arn) | ARN of the elastic (opensearch) compute IAM role | `string` | n/a | yes |
| <a name="input_external_ingress_lb_host_name"></a> [external\_ingress\_lb\_host\_name](#input\_external\_ingress\_lb\_host\_name) | Host name of the k8s ingress that supports the external ALB | `string` | n/a | yes |
| <a name="input_flink_invoker_role_arn"></a> [flink\_invoker\_role\_arn](#input\_flink\_invoker\_role\_arn) | ARN of the flink invoker IAM role | `string` | n/a | yes |
| <a name="input_glean_instance_name"></a> [glean\_instance\_name](#input\_glean\_instance\_name) | Glean instance name | `string` | n/a | yes |
| <a name="input_glean_viewer_role_arn"></a> [glean\_viewer\_role\_arn](#input\_glean\_viewer\_role\_arn) | ARN of the glean-viewer IAM role | `string` | n/a | yes |
| <a name="input_gmp_collector_role_arn"></a> [gmp\_collector\_role\_arn](#input\_gmp\_collector\_role\_arn) | ARN of the gmp collector role arn | `string` | n/a | yes |
| <a name="input_initialize_config_job_id"></a> [initialize\_config\_job\_id](#input\_initialize\_config\_job\_id) | Job ID of the INITIALIZE\_CONFIG job, used to link a dependency between that job in the core k8s module and all config/ipjc updates in this module | `string` | n/a | yes |
| <a name="input_kubernetes_token_command"></a> [kubernetes\_token\_command](#input\_kubernetes\_token\_command) | Command to use for generating the K8s auth token for the kubernetes provider | `string` | n/a | yes |
| <a name="input_kubernetes_token_generation_command_args"></a> [kubernetes\_token\_generation\_command\_args](#input\_kubernetes\_token\_generation\_command\_args) | Args to pass to the command used to generate the K8s auth token for the kubernetes provider | `list(string)` | n/a | yes |
| <a name="input_nodegroup_node_selector_key"></a> [nodegroup\_node\_selector\_key](#input\_nodegroup\_node\_selector\_key) | Key to use for selecting K8s nodes based on the nodegroup, e.g. eks.amazonaws.com/nodegroup for AWS | `string` | n/a | yes |
| <a name="input_opensearch_1_namespace"></a> [opensearch\_1\_namespace](#input\_opensearch\_1\_namespace) | Name of first Opensearch namespace | `string` | n/a | yes |
| <a name="input_opensearch_2_namespace"></a> [opensearch\_2\_namespace](#input\_opensearch\_2\_namespace) | Name of second Opensearch namespace | `string` | n/a | yes |
| <a name="input_referential_env_vars"></a> [referential\_env\_vars](#input\_referential\_env\_vars) | A mapping of env var -> spec path for all k8s environment variables based on pod specs | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to use | `string` | n/a | yes |
| <a name="input_self_hosted_airflow_nodes_iam_role_arn"></a> [self\_hosted\_airflow\_nodes\_iam\_role\_arn](#input\_self\_hosted\_airflow\_nodes\_iam\_role\_arn) | ARN of the self hosted airflow IAM role | `string` | n/a | yes |
| <a name="input_unvalidated_ssl_cert_arn"></a> [unvalidated\_ssl\_cert\_arn](#input\_unvalidated\_ssl\_cert\_arn) | ARN of the ACM SSL cert, should not be validated yet | `string` | n/a | yes |
| <a name="input_version_tag"></a> [version\_tag](#input\_version\_tag) | Version tag to use | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_controller_id"></a> [alb\_controller\_id](#output\_alb\_controller\_id) | n/a |
| <a name="output_ebs_storage_class_name"></a> [ebs\_storage\_class\_name](#output\_ebs\_storage\_class\_name) | n/a |
| <a name="output_opensearch_snapshot_secrets"></a> [opensearch\_snapshot\_secrets](#output\_opensearch\_snapshot\_secrets) | n/a |
| <a name="output_validated_ssl_cert_arn"></a> [validated\_ssl\_cert\_arn](#output\_validated\_ssl\_cert\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
