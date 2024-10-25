# cloudformation

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.24.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.glean-bootstrap](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudformation_bootstrap_template_uri"></a> [cloudformation\_bootstrap\_template\_uri](#input\_cloudformation\_bootstrap\_template\_uri) | Cloudformation bootstrap template uri | `string` | `"https://glean-public-marketplace-resources.s3.amazonaws.com/glean-cloudformation-template.yaml"` | no |
| <a name="input_contact_email"></a> [contact\_email](#input\_contact\_email) | Contact email to notify when Glean workspace is ready to be configured | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region in which the api calls made for management account | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
