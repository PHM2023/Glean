# eks_node_group_v2

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.58.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group_tag.tag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag) | resource |
| [aws_eks_node_group.node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_launch_template.node_group_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input__do_not_use_for_new_nodegroups_defined_volume_tag_specs_before_instance_tag_specs"></a> [\_do\_not\_use\_for\_new\_nodegroups\_defined\_volume\_tag\_specs\_before\_instance\_tag\_specs](#input\_\_do\_not\_use\_for\_new\_nodegroups\_defined\_volume\_tag\_specs\_before\_instance\_tag\_specs) | DO NOT SET THIS FOR NEW NODEGROUPS: If true, defines the volume tag specs before the instance specs | `bool` | `false` | no |
| <a name="input__do_not_use_for_new_nodegroups_port_from_python_created_nodegroup"></a> [\_do\_not\_use\_for\_new\_nodegroups\_port\_from\_python\_created\_nodegroup](#input\_\_do\_not\_use\_for\_new\_nodegroups\_port\_from\_python\_created\_nodegroup) | DO NOT SET THIS FOR NEW NODEGROUPS: If true, tweaks nodegroup/launch template configs to fit nodegroups that used to be created in python | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size) | Desired size of node group | `number` | n/a | yes |
| <a name="input_disk_size_gi"></a> [disk\_size\_gi](#input\_disk\_size\_gi) | Size of disk in GB | `number` | `50` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Machine type for the nodegroup | `string` | `"t3.medium"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to attach to the node group | `map(string)` | `{}` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Max size of node group | `number` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Min size of node group | `number` | n/a | yes |
| <a name="input_node_group_name"></a> [node\_group\_name](#input\_node\_group\_name) | The name of the node group | `string` | n/a | yes |
| <a name="input_node_role_arn"></a> [node\_role\_arn](#input\_node\_role\_arn) | The ARN of the role to use for the node group worker | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet ID's to use for the node group | `list(string)` | n/a | yes |
| <a name="input_taints"></a> [taints](#input\_taints) | Taints to apply to the node group | <pre>list(object({<br>    key    = string<br>    value  = string<br>    effect = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_group_name"></a> [node\_group\_name](#output\_node\_group\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
