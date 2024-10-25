# full_deploy

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | = 2.11.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.3 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.11.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.31.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin_deployment"></a> [admin\_deployment](#module\_admin\_deployment) | ./memory_based_k8s_deployment | n/a |
| <a name="module_clamav_scanner_deployment"></a> [clamav\_scanner\_deployment](#module\_clamav\_scanner\_deployment) | ./memory_based_k8s_deployment | n/a |
| <a name="module_crawler_deployment"></a> [crawler\_deployment](#module\_crawler\_deployment) | ./memory_based_k8s_deployment | n/a |
| <a name="module_create_opensearch_setup_only"></a> [create\_opensearch\_setup\_only](#module\_create\_opensearch\_setup\_only) | ./deploy_job | n/a |
| <a name="module_cron"></a> [cron](#module\_cron) | ./deploy_job | n/a |
| <a name="module_docbuilder"></a> [docbuilder](#module\_docbuilder) | ./deploy_job | n/a |
| <a name="module_dse_deployment"></a> [dse\_deployment](#module\_dse\_deployment) | ./memory_based_k8s_deployment | n/a |
| <a name="module_elastic_plugin"></a> [elastic\_plugin](#module\_elastic\_plugin) | ./deploy_job | n/a |
| <a name="module_entity_builder"></a> [entity\_builder](#module\_entity\_builder) | ./deploy_job | n/a |
| <a name="module_experiment_configs"></a> [experiment\_configs](#module\_experiment\_configs) | ./deploy_job | n/a |
| <a name="module_flink_invoker_image"></a> [flink\_invoker\_image](#module\_flink\_invoker\_image) | ./deploy_job | n/a |
| <a name="module_git_crawler_config_update"></a> [git\_crawler\_config\_update](#module\_git\_crawler\_config\_update) | ../config_update | n/a |
| <a name="module_gmp"></a> [gmp](#module\_gmp) | ./google_managed_prometheus | n/a |
| <a name="module_gmp_operator_and_pod_monitoring"></a> [gmp\_operator\_and\_pod\_monitoring](#module\_gmp\_operator\_and\_pod\_monitoring) | ./deploy_job | n/a |
| <a name="module_gmp_setup"></a> [gmp\_setup](#module\_gmp\_setup) | ./deploy_job | n/a |
| <a name="module_initialize_config"></a> [initialize\_config](#module\_initialize\_config) | ./deploy_job | n/a |
| <a name="module_initialize_rabbitmq"></a> [initialize\_rabbitmq](#module\_initialize\_rabbitmq) | ./deploy_job | n/a |
| <a name="module_initialize_sql"></a> [initialize\_sql](#module\_initialize\_sql) | ./deploy_job | n/a |
| <a name="module_kms_config_update"></a> [kms\_config\_update](#module\_kms\_config\_update) | ../config_update | n/a |
| <a name="module_memcached_config_update"></a> [memcached\_config\_update](#module\_memcached\_config\_update) | ../config_update | n/a |
| <a name="module_pipelines"></a> [pipelines](#module\_pipelines) | ./deploy_job | n/a |
| <a name="module_proxy_config_update"></a> [proxy\_config\_update](#module\_proxy\_config\_update) | ../config_update | n/a |
| <a name="module_put_elastic_scoring_scripts"></a> [put\_elastic\_scoring\_scripts](#module\_put\_elastic\_scoring\_scripts) | ./deploy_job | n/a |
| <a name="module_python_flink_harness_base_image"></a> [python\_flink\_harness\_base\_image](#module\_python\_flink\_harness\_base\_image) | ./deploy_job | n/a |
| <a name="module_qe_deployment"></a> [qe\_deployment](#module\_qe\_deployment) | ./memory_based_k8s_deployment | n/a |
| <a name="module_qp_deployment"></a> [qp\_deployment](#module\_qp\_deployment) | ./memory_based_k8s_deployment | n/a |
| <a name="module_qp_lb_config_update"></a> [qp\_lb\_config\_update](#module\_qp\_lb\_config\_update) | ../config_update | n/a |
| <a name="module_queues"></a> [queues](#module\_queues) | ./deploy_job | n/a |
| <a name="module_rabbitmq_config_update"></a> [rabbitmq\_config\_update](#module\_rabbitmq\_config\_update) | ../config_update | n/a |
| <a name="module_scholastic_deployment"></a> [scholastic\_deployment](#module\_scholastic\_deployment) | ./memory_based_k8s_deployment | n/a |
| <a name="module_scholastic_lb_config_update"></a> [scholastic\_lb\_config\_update](#module\_scholastic\_lb\_config\_update) | ../config_update | n/a |
| <a name="module_set_glean_azure_resource_configuration"></a> [set\_glean\_azure\_resource\_configuration](#module\_set\_glean\_azure\_resource\_configuration) | ./deploy_job | n/a |
| <a name="module_setup_qe_secrets"></a> [setup\_qe\_secrets](#module\_setup\_qe\_secrets) | ./deploy_job | n/a |
| <a name="module_setup_ugc"></a> [setup\_ugc](#module\_setup\_ugc) | ./deploy_job | n/a |
| <a name="module_sql"></a> [sql](#module\_sql) | ./deploy_job | n/a |
| <a name="module_sync_general_query_metadata"></a> [sync\_general\_query\_metadata](#module\_sync\_general\_query\_metadata) | ./deploy_job | n/a |
| <a name="module_sync_manifest"></a> [sync\_manifest](#module\_sync\_manifest) | ./deploy_job | n/a |
| <a name="module_task_push_config_update"></a> [task\_push\_config\_update](#module\_task\_push\_config\_update) | ../config_update | n/a |
| <a name="module_task_push_deployment"></a> [task\_push\_deployment](#module\_task\_push\_deployment) | ./memory_based_k8s_deployment | n/a |
| <a name="module_update_opensearch_index_schemas"></a> [update\_opensearch\_index\_schemas](#module\_update\_opensearch\_index\_schemas) | ./deploy_job | n/a |
| <a name="module_upgrade"></a> [upgrade](#module\_upgrade) | ./deploy_job | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.flink_kubernetes_operator](https://registry.terraform.io/providers/hashicorp/helm/2.11.0/docs/resources/release) | resource |
| [helm_release.k8s_event_logger_helm_install](https://registry.terraform.io/providers/hashicorp/helm/2.11.0/docs/resources/release) | resource |
| [helm_release.metrics_server_helm_release](https://registry.terraform.io/providers/hashicorp/helm/2.11.0/docs/resources/release) | resource |
| [kubernetes_annotations.flink_sa_role_annotation](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations) | resource |
| [kubernetes_cluster_role.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.flink_invoker_cluster_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.flink_watchdog_cluster_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.flink_invoker_cluster_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.flink_watchdog_cluster_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_config_map_v1.rabbitmq_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_config_map_v1.redis_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_daemon_set_v1.basic_fim](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemon_set_v1) | resource |
| [kubernetes_daemon_set_v1.clamav](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemon_set_v1) | resource |
| [kubernetes_deployment.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_ingress_v1.glean_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace.deploy_jobs_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.elasticsearch_1_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.elasticsearch_2_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.flink_invoker_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.flink_jobs_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.flink_operator_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.flink_watchdog_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_secret_v1.rabbitmq_certs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_service_account.admin_console_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.deploy_job_k8s_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.dse](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.elastic_compute_ksa_1](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.elastic_compute_ksa_2](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.flink_invoker_ksa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.flink_watchdog_ksa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.lambda_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.qe_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.query_parser_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.scholastic_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.task_handlers_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.task_push_service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_v1.dse_internal_lb_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_service_v1.ipjc](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_service_v1.rabbitmq_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_service_v1.redis](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_stateful_set_v1.rabbitmq_statefulset](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set_v1) | resource |
| [kubernetes_stateful_set_v1.redis](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set_v1) | resource |
| [external_external.ingress_rules](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.rabbitmq_secret_gen](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_kms_config_key_values"></a> [additional\_kms\_config\_key\_values](#input\_additional\_kms\_config\_key\_values) | Any additional configs to set based on kms resources | `map(string)` | `{}` | no |
| <a name="input_additional_proxy_config_updates"></a> [additional\_proxy\_config\_updates](#input\_additional\_proxy\_config\_updates) | Additional configs to set for the proxy setup | `map(string)` | `{}` | no |
| <a name="input_admin_image_uri"></a> [admin\_image\_uri](#input\_admin\_image\_uri) | URI of admin image to use | `string` | n/a | yes |
| <a name="input_admin_k8s_configs"></a> [admin\_k8s\_configs](#input\_admin\_k8s\_configs) | Configs needed for the crawler deployment | <pre>object({<br>    initial_delay_seconds           = number<br>    readiness_check_period_seconds  = number<br>    readiness_check_timeout_seconds = number<br>    liveness_check_period_seconds   = number<br>    liveness_check_timeout_seconds  = number<br>    startup_check_period_seconds    = number<br>    startup_check_timeout_seconds   = number<br>    startup_check_failure_threshold = number<br>    autoscaling_max_cpu_percent     = number<br>    cpu_limit                       = number<br>    cpu_request                     = number<br>    memory_limit_gi                 = number<br>    memory_request_gi               = number<br>    min_instances                   = number<br>    max_instances                   = number<br>  })</pre> | n/a | yes |
| <a name="input_app_name_env_vars"></a> [app\_name\_env\_vars](#input\_app\_name\_env\_vars) | Any environment variables to attach to k8s workloads based on their app names | `list(string)` | `[]` | no |
| <a name="input_basic_fim_image_uri"></a> [basic\_fim\_image\_uri](#input\_basic\_fim\_image\_uri) | URI of image to use for basic-fim daemonset | `string` | n/a | yes |
| <a name="input_bastion_port"></a> [bastion\_port](#input\_bastion\_port) | The port on which to open bastion connections | `string` | `null` | no |
| <a name="input_clamav_image_uri"></a> [clamav\_image\_uri](#input\_clamav\_image\_uri) | URI of image to use for clamav daemonset | `string` | n/a | yes |
| <a name="input_clamav_scanner_image_uri"></a> [clamav\_scanner\_image\_uri](#input\_clamav\_scanner\_image\_uri) | URI of clamav scanner image to use | `string` | n/a | yes |
| <a name="input_clamav_scanner_k8s_configs"></a> [clamav\_scanner\_k8s\_configs](#input\_clamav\_scanner\_k8s\_configs) | Configs needed for the clamav scanner deployment | <pre>object({<br>    initial_delay_seconds           = number<br>    readiness_check_period_seconds  = number<br>    readiness_check_timeout_seconds = number<br>    liveness_check_period_seconds   = number<br>    liveness_check_timeout_seconds  = number<br>    startup_check_period_seconds    = number<br>    startup_check_timeout_seconds   = number<br>    startup_check_failure_threshold = number<br>    autoscaling_max_cpu_percent     = number<br>    cpu_limit                       = number<br>    cpu_request                     = number<br>    memory_limit_gi                 = number<br>    memory_request_gi               = number<br>    min_instances                   = number<br>    max_instances                   = number<br>  })</pre> | n/a | yes |
| <a name="input_cluster_autoscaler_cloud_provider"></a> [cluster\_autoscaler\_cloud\_provider](#input\_cluster\_autoscaler\_cloud\_provider) | Cloud provider ID to pass to the cluster autoscaler k8s deployment | `string` | n/a | yes |
| <a name="input_cluster_autoscaler_nodegroup"></a> [cluster\_autoscaler\_nodegroup](#input\_cluster\_autoscaler\_nodegroup) | Name of the nodegroup to use for the cluster autoscaler | `string` | n/a | yes |
| <a name="input_cluster_ca_cert_data"></a> [cluster\_ca\_cert\_data](#input\_cluster\_ca\_cert\_data) | Base-64 encoded CA cert data for the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | The endpoint of the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_config_handler_image_uri"></a> [config\_handler\_image\_uri](#input\_config\_handler\_image\_uri) | URI of config handler to use | `string` | n/a | yes |
| <a name="input_crawler_image_uri"></a> [crawler\_image\_uri](#input\_crawler\_image\_uri) | URI of crawler image to use | `string` | n/a | yes |
| <a name="input_crawler_k8s_configs"></a> [crawler\_k8s\_configs](#input\_crawler\_k8s\_configs) | Configs needed for the crawler deployment | <pre>object({<br>    initial_delay_seconds           = number<br>    readiness_check_period_seconds  = number<br>    readiness_check_timeout_seconds = number<br>    liveness_check_period_seconds   = number<br>    liveness_check_timeout_seconds  = number<br>    startup_check_period_seconds    = number<br>    startup_check_timeout_seconds   = number<br>    startup_check_failure_threshold = number<br>    autoscaling_max_cpu_percent     = number<br>    cpu_limit                       = number<br>    cpu_request                     = number<br>    memory_limit_gi                 = number<br>    memory_request_gi               = number<br>    min_instances                   = number<br>    max_instances                   = number<br>  })</pre> | n/a | yes |
| <a name="input_crawler_nodegroup"></a> [crawler\_nodegroup](#input\_crawler\_nodegroup) | Nodegroup to use for crawler k8s deployment | `string` | n/a | yes |
| <a name="input_default_env_vars"></a> [default\_env\_vars](#input\_default\_env\_vars) | Any default environment variables to attach to k8s workloads | `map(string)` | `{}` | no |
| <a name="input_deploy_image_uri"></a> [deploy\_image\_uri](#input\_deploy\_image\_uri) | URI of deploy image to use | `string` | n/a | yes |
| <a name="input_deploy_jobs_extra_args"></a> [deploy\_jobs\_extra\_args](#input\_deploy\_jobs\_extra\_args) | Any extra args to pass to all deploy jobs | `map(string)` | `{}` | no |
| <a name="input_deploy_jobs_namespace"></a> [deploy\_jobs\_namespace](#input\_deploy\_jobs\_namespace) | Name of the namespace to use for running deploy jobs | `string` | n/a | yes |
| <a name="input_deploy_jobs_nodegroup"></a> [deploy\_jobs\_nodegroup](#input\_deploy\_jobs\_nodegroup) | Name of the nodegroup to use for deploy jobs | `string` | n/a | yes |
| <a name="input_deploy_jobs_service_account"></a> [deploy\_jobs\_service\_account](#input\_deploy\_jobs\_service\_account) | Name of the service account to use for running deploy jobs | `string` | n/a | yes |
| <a name="input_dse_image_uri"></a> [dse\_image\_uri](#input\_dse\_image\_uri) | URI of dse image to use | `string` | n/a | yes |
| <a name="input_dse_k8s_configs"></a> [dse\_k8s\_configs](#input\_dse\_k8s\_configs) | Configs needed for the crawler deployment | <pre>object({<br>    initial_delay_seconds           = number<br>    readiness_check_period_seconds  = number<br>    readiness_check_timeout_seconds = number<br>    liveness_check_period_seconds   = number<br>    liveness_check_timeout_seconds  = number<br>    startup_check_period_seconds    = number<br>    startup_check_timeout_seconds   = number<br>    startup_check_failure_threshold = number<br>    autoscaling_max_cpu_percent     = number<br>    cpu_limit                       = number<br>    cpu_request                     = number<br>    memory_limit_gi                 = number<br>    memory_request_gi               = number<br>    min_instances                   = number<br>    max_instances                   = number<br>  })</pre> | n/a | yes |
| <a name="input_flink_jobs_namespace"></a> [flink\_jobs\_namespace](#input\_flink\_jobs\_namespace) | Name of flink jobs namespace | `string` | n/a | yes |
| <a name="input_flink_operator_namespace"></a> [flink\_operator\_namespace](#input\_flink\_operator\_namespace) | Name of flink operator namespace | `string` | n/a | yes |
| <a name="input_git_crawler_private_ip"></a> [git\_crawler\_private\_ip](#input\_git\_crawler\_private\_ip) | IP of the git crawler instance | `string` | n/a | yes |
| <a name="input_glean_instance_name"></a> [glean\_instance\_name](#input\_glean\_instance\_name) | Glean instance name | `string` | n/a | yes |
| <a name="input_ingress_paths_root"></a> [ingress\_paths\_root](#input\_ingress\_paths\_root) | Path to folder container all yamls with relevant k8s ingress rules | `string` | n/a | yes |
| <a name="input_k8s_service_lb_controller_ids"></a> [k8s\_service\_lb\_controller\_ids](#input\_k8s\_service\_lb\_controller\_ids) | IDs for any cloud-platform-specific resources that are needed as dependencies of k8s-provisioned load balancers, i.e. through Service/Ingress resources. Set to an empty list if no platform-specific resources are required | `list(string)` | n/a | yes |
| <a name="input_kubernetes_token_command"></a> [kubernetes\_token\_command](#input\_kubernetes\_token\_command) | Command to use for generating the K8s auth token for the kubernetes provider | `string` | n/a | yes |
| <a name="input_kubernetes_token_generation_command_args"></a> [kubernetes\_token\_generation\_command\_args](#input\_kubernetes\_token\_generation\_command\_args) | Args to pass to the command used to generate the K8s auth token for the kubernetes provider | `list(string)` | n/a | yes |
| <a name="input_memcached_discovery_endpoints"></a> [memcached\_discovery\_endpoints](#input\_memcached\_discovery\_endpoints) | Memcached discovery endpoints to set in the config | `string` | n/a | yes |
| <a name="input_memory_based_nodegroup_node_selector_info"></a> [memory\_based\_nodegroup\_node\_selector\_info](#input\_memory\_based\_nodegroup\_node\_selector\_info) | Info for selecting nodegroups among memory-based workloads | <pre>object({<br>    common_selector_key   = string<br>    common_selector_value = string<br>    nodegroups            = list(string)<br>    tolerations = list(object({<br>      key      = string<br>      operator = string<br>      value    = string<br>      effect   = string<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_monitoring_gcp_project_id"></a> [monitoring\_gcp\_project\_id](#input\_monitoring\_gcp\_project\_id) | The gcp project id to use for monitoring and observability | `string` | n/a | yes |
| <a name="input_nodegroup_node_selector_key"></a> [nodegroup\_node\_selector\_key](#input\_nodegroup\_node\_selector\_key) | Key to use for selecting K8s nodes based on the nodegroup, e.g. eks.amazonaws.com/nodegroup for AWS | `string` | n/a | yes |
| <a name="input_opensearch_snapshot_secrets"></a> [opensearch\_snapshot\_secrets](#input\_opensearch\_snapshot\_secrets) | Secrets used for opensearch - ID only, not actually used (yet) | `list(string)` | n/a | yes |
| <a name="input_pipelines_list"></a> [pipelines\_list](#input\_pipelines\_list) | List of Glean pipelines jobs to run | `list(string)` | n/a | yes |
| <a name="input_private_load_balancer_via_k8s_service_info"></a> [private\_load\_balancer\_via\_k8s\_service\_info](#input\_private\_load\_balancer\_via\_k8s\_service\_info) | Info for setting annotations on ingress/service resources that provision load balancers | <pre>object({<br>    load_balancer_name_key   = string<br>    load_balancer_class_name = string<br>    common_annotations       = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_proxy_ip"></a> [proxy\_ip](#input\_proxy\_ip) | IP of proxy connection (for on-prem datasources) | `string` | `null` | no |
| <a name="input_public_ingress_annotations"></a> [public\_ingress\_annotations](#input\_public\_ingress\_annotations) | Annotations to attach to the public ingress resource (external load balancer) | `map(string)` | n/a | yes |
| <a name="input_qe_image_uri"></a> [qe\_image\_uri](#input\_qe\_image\_uri) | URI of qe image to use | `string` | n/a | yes |
| <a name="input_qe_k8s_configs"></a> [qe\_k8s\_configs](#input\_qe\_k8s\_configs) | Configs needed for the crawler deployment | <pre>object({<br>    initial_delay_seconds           = number<br>    readiness_check_period_seconds  = number<br>    readiness_check_timeout_seconds = number<br>    liveness_check_period_seconds   = number<br>    liveness_check_timeout_seconds  = number<br>    startup_check_period_seconds    = number<br>    startup_check_timeout_seconds   = number<br>    startup_check_failure_threshold = number<br>    autoscaling_max_cpu_percent     = number<br>    cpu_limit                       = number<br>    cpu_request                     = number<br>    memory_limit_gi                 = number<br>    memory_request_gi               = number<br>    min_instances                   = number<br>    max_instances                   = number<br>  })</pre> | n/a | yes |
| <a name="input_qp_encrypted_secret_file_name"></a> [qp\_encrypted\_secret\_file\_name](#input\_qp\_encrypted\_secret\_file\_name) | Name of the object used to store the qp secret | `string` | n/a | yes |
| <a name="input_qp_image_uri"></a> [qp\_image\_uri](#input\_qp\_image\_uri) | URI of QP image to use | `string` | n/a | yes |
| <a name="input_qp_k8s_configs"></a> [qp\_k8s\_configs](#input\_qp\_k8s\_configs) | Configs needed for the crawler deployment | <pre>object({<br>    initial_delay_seconds           = number<br>    readiness_check_period_seconds  = number<br>    readiness_check_timeout_seconds = number<br>    liveness_check_period_seconds   = number<br>    liveness_check_timeout_seconds  = number<br>    startup_check_period_seconds    = number<br>    startup_check_timeout_seconds   = number<br>    startup_check_failure_threshold = number<br>    autoscaling_max_cpu_percent     = number<br>    cpu_limit                       = number<br>    cpu_request                     = number<br>    memory_limit_gi                 = number<br>    memory_request_gi               = number<br>    min_instances                   = number<br>    max_instances                   = number<br>  })</pre> | n/a | yes |
| <a name="input_rabbitmq_k8s_configs"></a> [rabbitmq\_k8s\_configs](#input\_rabbitmq\_k8s\_configs) | Configs needed for the rabbitmq deployment | <pre>object({<br>    initial_delay_seconds           = number<br>    readiness_check_period_seconds  = number<br>    readiness_check_timeout_seconds = number<br>    liveness_check_period_seconds   = number<br>    liveness_check_timeout_seconds  = number<br>    startup_check_period_seconds    = number<br>    startup_check_timeout_seconds   = number<br>    startup_check_failure_threshold = number<br>    data_disk_size_gi               = number<br><br>  })</pre> | n/a | yes |
| <a name="input_rabbitmq_nodegroup"></a> [rabbitmq\_nodegroup](#input\_rabbitmq\_nodegroup) | Name of the nodegroup to use for rabbitmq workloads | `string` | n/a | yes |
| <a name="input_redis_image_uri"></a> [redis\_image\_uri](#input\_redis\_image\_uri) | URI of redis image to use | `string` | n/a | yes |
| <a name="input_redis_k8s_configs"></a> [redis\_k8s\_configs](#input\_redis\_k8s\_configs) | Configs needed for the crawler deployment | <pre>object({<br>    initial_delay_seconds           = number<br>    readiness_check_period_seconds  = number<br>    readiness_check_timeout_seconds = number<br>    liveness_check_period_seconds   = number<br>    liveness_check_timeout_seconds  = number<br>    startup_check_period_seconds    = number<br>    startup_check_timeout_seconds   = number<br>    startup_check_failure_threshold = number<br>    cpu_limit                       = number<br>    cpu_request                     = number<br>    memory_limit_gi                 = number<br>    memory_request_gi               = number<br>    min_instances                   = number<br>    max_instances                   = number<br>    storage_request_gi              = number<br>  })</pre> | n/a | yes |
| <a name="input_redis_nodegroup_name"></a> [redis\_nodegroup\_name](#input\_redis\_nodegroup\_name) | Nodegroup name to use for redis | `string` | n/a | yes |
| <a name="input_redis_nodegroup_selector_key"></a> [redis\_nodegroup\_selector\_key](#input\_redis\_nodegroup\_selector\_key) | Key to use for redis nodegroup selector | `string` | n/a | yes |
| <a name="input_referential_env_vars"></a> [referential\_env\_vars](#input\_referential\_env\_vars) | A mapping of env var -> spec path for all k8s environment variables based on pod specs | `map(string)` | `{}` | no |
| <a name="input_rollout_id"></a> [rollout\_id](#input\_rollout\_id) | Rollout ID to use for each restartable k8s app. If this changes, the app will be restarted | `string` | n/a | yes |
| <a name="input_scholastic_image_uri"></a> [scholastic\_image\_uri](#input\_scholastic\_image\_uri) | URI of scholastic image to use | `string` | n/a | yes |
| <a name="input_scholastic_k8s_configs"></a> [scholastic\_k8s\_configs](#input\_scholastic\_k8s\_configs) | Configs needed for the crawler deployment | <pre>object({<br>    initial_delay_seconds           = number<br>    readiness_check_period_seconds  = number<br>    readiness_check_timeout_seconds = number<br>    liveness_check_period_seconds   = number<br>    liveness_check_timeout_seconds  = number<br>    startup_check_period_seconds    = number<br>    startup_check_timeout_seconds   = number<br>    startup_check_failure_threshold = number<br>    autoscaling_max_cpu_percent     = number<br>    cpu_limit                       = number<br>    cpu_request                     = number<br>    memory_limit_gi                 = number<br>    memory_request_gi               = number<br>    min_instances                   = number<br>    max_instances                   = number<br>  })</pre> | n/a | yes |
| <a name="input_service_account_iam_annotation_key"></a> [service\_account\_iam\_annotation\_key](#input\_service\_account\_iam\_annotation\_key) | Key for the annotation to add to all service accounts using IAM/web-identity auth, e.g. the role arn in AWS or the service account email in GCP | `string` | n/a | yes |
| <a name="input_service_account_iam_annotations"></a> [service\_account\_iam\_annotations](#input\_service\_account\_iam\_annotations) | IAM annotation values for each service account | <pre>object({<br>    deploy_jobs        = string<br>    cluster_autoscaler = string<br>    dse                = string<br>    qe                 = string<br>    crawler            = string<br>    qp                 = string<br>    scholastic         = string<br>    admin_console      = string<br>    task_push          = string<br>    opensearch_1       = string<br>    opensearch_2       = string<br>    cron_job           = string<br>    flink_watchdog     = string<br>    flink_java_jobs    = string<br>    flink_invoker      = string<br>    gmp_collector      = string<br>  })</pre> | n/a | yes |
| <a name="input_set_google_credentials_file_content"></a> [set\_google\_credentials\_file\_content](#input\_set\_google\_credentials\_file\_content) | Contents of the relevant set-google-credentials-script | `string` | n/a | yes |
| <a name="input_sql_instance_ids"></a> [sql\_instance\_ids](#input\_sql\_instance\_ids) | List of sql instance ids to form a dependency between the sql instance creation and the INITIALIZE\_SQL job | `list(string)` | n/a | yes |
| <a name="input_storage_class_name"></a> [storage\_class\_name](#input\_storage\_class\_name) | Name of the storage class to use for statefulset volumes | `string` | n/a | yes |
| <a name="input_task_push_image_uri"></a> [task\_push\_image\_uri](#input\_task\_push\_image\_uri) | URI of task push image to use | `string` | n/a | yes |
| <a name="input_task_push_k8s_configs"></a> [task\_push\_k8s\_configs](#input\_task\_push\_k8s\_configs) | Configs needed for the task\_push deployment | <pre>object({<br>    initial_delay_seconds           = number<br>    readiness_check_period_seconds  = number<br>    readiness_check_timeout_seconds = number<br>    liveness_check_period_seconds   = number<br>    liveness_check_timeout_seconds  = number<br>    startup_check_period_seconds    = number<br>    startup_check_timeout_seconds   = number<br>    startup_check_failure_threshold = number<br>    autoscaling_max_cpu_percent     = number<br>    cpu_limit                       = number<br>    cpu_request                     = number<br>    memory_limit_gi                 = number<br>    memory_request_gi               = number<br>    min_instances                   = number<br>    max_instances                   = number<br>  })</pre> | n/a | yes |
| <a name="input_task_push_nodegroup"></a> [task\_push\_nodegroup](#input\_task\_push\_nodegroup) | Nodegroup to use for task-push workloads | `string` | n/a | yes |
| <a name="input_transit_ip"></a> [transit\_ip](#input\_transit\_ip) | Proxy transit IP | `string` | `null` | no |
| <a name="input_validated_ssl_cert_id"></a> [validated\_ssl\_cert\_id](#input\_validated\_ssl\_cert\_id) | ID of the SSL certificate to use for the external load balancer. The cert should be validated by the cloud provider before being passed in | `string` | n/a | yes |
| <a name="input_version_tag"></a> [version\_tag](#input\_version\_tag) | Version tag to use | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dse_internal_lb_service_hostname"></a> [dse\_internal\_lb\_service\_hostname](#output\_dse\_internal\_lb\_service\_hostname) | n/a |
| <a name="output_external_ingress_lb_host_name"></a> [external\_ingress\_lb\_host\_name](#output\_external\_ingress\_lb\_host\_name) | n/a |
| <a name="output_flink_invoker_namespace"></a> [flink\_invoker\_namespace](#output\_flink\_invoker\_namespace) | n/a |
| <a name="output_flink_watchdog_namespace"></a> [flink\_watchdog\_namespace](#output\_flink\_watchdog\_namespace) | n/a |
| <a name="output_initialize_config_job_id"></a> [initialize\_config\_job\_id](#output\_initialize\_config\_job\_id) | n/a |
| <a name="output_opensearch_1_namespace"></a> [opensearch\_1\_namespace](#output\_opensearch\_1\_namespace) | n/a |
| <a name="output_opensearch_2_namespace"></a> [opensearch\_2\_namespace](#output\_opensearch\_2\_namespace) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
