# acm

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.16.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.glean_ssl_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to use for acm resources | `string` | `"us-east-1"` | no |
| <a name="input_subdomain_name"></a> [subdomain\_name](#input\_subdomain\_name) | The subdomain name for the glean backend | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssl_cert_arn"></a> [ssl\_cert\_arn](#output\_ssl\_cert\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
