# memory_based_k8s_deployment

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
| [kubernetes_deployment_v1.deployment](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_horizontal_pod_autoscaler_v2.hpa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/horizontal_pod_autoscaler_v2) | resource |
| [kubernetes_pod_disruption_budget_v1.pdb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_service_v1.service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tolerations"></a> [additional\_tolerations](#input\_additional\_tolerations) | Additional k8s tolerations to add to the deployment pod spec | <pre>list(object({<br>    key      = string<br>    operator = string<br>    value    = string<br>    effect   = string<br>  }))</pre> | `[]` | no |
| <a name="input_app"></a> [app](#input\_app) | Name of the k8s app | `string` | n/a | yes |
| <a name="input_app_name_env_vars"></a> [app\_name\_env\_vars](#input\_app\_name\_env\_vars) | Env vars that should use the app name | `list(string)` | n/a | yes |
| <a name="input_autoscaling_max_cpu_percent"></a> [autoscaling\_max\_cpu\_percent](#input\_autoscaling\_max\_cpu\_percent) | CPU percent to trigger scale up | `number` | n/a | yes |
| <a name="input_cpu_limit"></a> [cpu\_limit](#input\_cpu\_limit) | Limit for cpu | `number` | n/a | yes |
| <a name="input_cpu_request"></a> [cpu\_request](#input\_cpu\_request) | Request for cpu | `number` | n/a | yes |
| <a name="input_default_env_vars"></a> [default\_env\_vars](#input\_default\_env\_vars) | Static value env vars | `map(string)` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_empty_dir_volumes"></a> [empty\_dir\_volumes](#input\_empty\_dir\_volumes) | Additional volumes to add | <pre>list(object({<br>    name = string<br>  }))</pre> | `[]` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | Image URI of main deployment container | `string` | n/a | yes |
| <a name="input_include_user_local_lib_volume"></a> [include\_user\_local\_lib\_volume](#input\_include\_user\_local\_lib\_volume) | If true, includes an empty volume mount at /usr/local/lib for any extra libraries to be downloaded | `bool` | `false` | no |
| <a name="input_k8s_service_account"></a> [k8s\_service\_account](#input\_k8s\_service\_account) | Name of the k8s service account to use | `string` | n/a | yes |
| <a name="input_k8s_service_lb_controller_ids"></a> [k8s\_service\_lb\_controller\_ids](#input\_k8s\_service\_lb\_controller\_ids) | IDs for any cloud-platform-specific resources that are needed as dependencies of k8s-provisioned load balancers, i.e. through Service/Ingress resources. Set to an empty list if no platform-specific resources are required | `list(string)` | n/a | yes |
| <a name="input_lifecycle_prestop_command"></a> [lifecycle\_prestop\_command](#input\_lifecycle\_prestop\_command) | Command to run at the end of the lifecycle before stopping the pod | `list(string)` | `null` | no |
| <a name="input_liveness_check_path"></a> [liveness\_check\_path](#input\_liveness\_check\_path) | HTTP path for liveness checks | `string` | `"/liveness_check"` | no |
| <a name="input_liveness_failure_threshold"></a> [liveness\_failure\_threshold](#input\_liveness\_failure\_threshold) | Failure threshold for liveness checks | `number` | `2` | no |
| <a name="input_liveness_period_seconds"></a> [liveness\_period\_seconds](#input\_liveness\_period\_seconds) | Period for liveness checks | `number` | n/a | yes |
| <a name="input_liveness_timeout_seconds"></a> [liveness\_timeout\_seconds](#input\_liveness\_timeout\_seconds) | Timeout for liveness checks | `number` | n/a | yes |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | Max number of pods to scale up to | `number` | n/a | yes |
| <a name="input_memory_limit"></a> [memory\_limit](#input\_memory\_limit) | Limit for memory in Gi | `number` | n/a | yes |
| <a name="input_memory_request"></a> [memory\_request](#input\_memory\_request) | Request for memory in Gi | `number` | n/a | yes |
| <a name="input_min_instances"></a> [min\_instances](#input\_min\_instances) | Min number of pods to scale down to | `number` | n/a | yes |
| <a name="input_preferential_node_groups"></a> [preferential\_node\_groups](#input\_preferential\_node\_groups) | List of objects describing nodegroup selector key, value, and weights for preferential nodegroup selection | <pre>list(object({<br>    node_selector_key   = string<br>    node_selector_value = string<br>    weight              = number<br>  }))</pre> | `[]` | no |
| <a name="input_private_load_balancer_via_k8s_service_info"></a> [private\_load\_balancer\_via\_k8s\_service\_info](#input\_private\_load\_balancer\_via\_k8s\_service\_info) | Info for setting annotations on ingress/service resources that provision load balancers | <pre>object({<br>    load_balancer_name_key   = string<br>    common_annotations       = map(string)<br>    load_balancer_class_name = string<br>  })</pre> | n/a | yes |
| <a name="input_progress_deadline_seconds"></a> [progress\_deadline\_seconds](#input\_progress\_deadline\_seconds) | How long to wait for progress of the deployment | `number` | `1500` | no |
| <a name="input_readiness_check_path"></a> [readiness\_check\_path](#input\_readiness\_check\_path) | HTTP path for readiness checks | `string` | `"/readiness_check"` | no |
| <a name="input_referential_env_vars"></a> [referential\_env\_vars](#input\_referential\_env\_vars) | Env vars that reference specific k8s fields, e.g. EKS\_POD\_NAME -> spec.metadata.name | `map(string)` | n/a | yes |
| <a name="input_required_nodegroup_node_selector_key"></a> [required\_nodegroup\_node\_selector\_key](#input\_required\_nodegroup\_node\_selector\_key) | Key to use for selecting K8s nodes based on the nodegroup, e.g. eks.amazonaws.com/nodegroup for AWS | `string` | n/a | yes |
| <a name="input_required_nodegroup_node_selector_value"></a> [required\_nodegroup\_node\_selector\_value](#input\_required\_nodegroup\_node\_selector\_value) | Name of the nodegroup to pass to the node selector | `string` | n/a | yes |
| <a name="input_rollout_id"></a> [rollout\_id](#input\_rollout\_id) | Rollout ID to use for each k8s app. If this changes, the app will be restarted | `string` | n/a | yes |
| <a name="input_scale_down_stabilization_window_seconds"></a> [scale\_down\_stabilization\_window\_seconds](#input\_scale\_down\_stabilization\_window\_seconds) | Stabilization for scale-down HPA behavior | `number` | `900` | no |
| <a name="input_service_name_override"></a> [service\_name\_override](#input\_service\_name\_override) | Overrides the kubernetes\_service name, which defaults to {var.app}-service | `string` | `null` | no |
| <a name="input_startup_check_path"></a> [startup\_check\_path](#input\_startup\_check\_path) | HTTP path for startup checks | `string` | `"/readiness_check"` | no |
| <a name="input_startup_failure_threshold"></a> [startup\_failure\_threshold](#input\_startup\_failure\_threshold) | Failure threshold for startup checks | `number` | n/a | yes |
| <a name="input_startup_period_seconds"></a> [startup\_period\_seconds](#input\_startup\_period\_seconds) | Period of startup checks | `number` | n/a | yes |
| <a name="input_startup_timeout_seconds"></a> [startup\_timeout\_seconds](#input\_startup\_timeout\_seconds) | Timeout of startup checks | `number` | n/a | yes |
| <a name="input_termination_grace_period_seconds"></a> [termination\_grace\_period\_seconds](#input\_termination\_grace\_period\_seconds) | The termination grace period for each pod | `number` | `60` | no |
| <a name="input_use_lb_service"></a> [use\_lb\_service](#input\_use\_lb\_service) | Whether or not to use an internal load balancer as the exposing service | `bool` | `false` | no |
| <a name="input_version_tag"></a> [version\_tag](#input\_version\_tag) | Version tag to use for the workload image | `string` | n/a | yes |
| <a name="input_volume_mounts"></a> [volume\_mounts](#input\_volume\_mounts) | Additional volume mounts to add | <pre>list(object({<br>    mount_path = string<br>    read_only  = bool<br>    name       = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_host_name"></a> [lb\_host\_name](#output\_lb\_host\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
