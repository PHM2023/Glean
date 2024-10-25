# lambda_image

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_central_dedicated_image"></a> [central\_dedicated\_image](#module\_central\_dedicated\_image) | ../image_uri | n/a |
| <a name="module_regional_dedicated_image"></a> [regional\_dedicated\_image](#module\_regional\_dedicated\_image) | ../image_uri | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.preprocess_dedicated_image](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region to push/pull the image to/from | `string` | n/a | yes |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | ECR repository name | `string` | n/a | yes |
| <a name="input_version_tag"></a> [version\_tag](#input\_version\_tag) | Glean version tag | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_uri"></a> [image\_uri](#output\_image\_uri) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
