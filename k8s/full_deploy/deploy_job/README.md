# deploy_job

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_job.deploy_job](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_expand_ops"></a> [expand\_ops](#input\_expand\_ops) | Whether or not to expand the operation into any sub-operations | `bool` | `false` | no |
| <a name="input_general_info"></a> [general\_info](#input\_general\_info) | All inputs that should be (generally) shared by all deploy jobs | <pre>object({<br>    glean_instance_name             = string<br>    default_env_vars                = map(string)<br>    app_name_env_vars               = list(string)<br>    deploy_image_uri                = string<br>    deploy_jobs_k8s_service_account = string<br>    deploy_jobs_namespace           = string<br>    deploy_jobs_nodegroup           = string<br>    nodegroup_node_selector_key     = string<br>    referential_env_vars            = map(string)<br>    tag                             = string<br>    extra_args                      = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_operation"></a> [operation](#input\_operation) | The name of the operation. Should be a valid Glean DeployOperation enum | `string` | n/a | yes |
| <a name="input_retries"></a> [retries](#input\_retries) | Number of retries to allow | `number` | `2` | no |
| <a name="input_run_once"></a> [run\_once](#input\_run\_once) | Whether or not to only run this operation once (e.g. for setup only) | `bool` | `false` | no |
| <a name="input_timeout_minutes"></a> [timeout\_minutes](#input\_timeout\_minutes) | Timeout for job in minutes | `number` | `20` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_job_id"></a> [job\_id](#output\_job\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
