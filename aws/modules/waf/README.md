# waf

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.15.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.aws_waf_logs_glean](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_wafv2_ip_set.central_ip_set](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_ip_set.ip_greenlist_set](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_ip_set.ip_redlist_set](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_regex_pattern_set.ugc_write_regex_pattern_set](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_regex_pattern_set) | resource |
| [aws_wafv2_web_acl.glean_waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_logging_configuration.glean_waf_logging_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_actas_rate_limiting_count"></a> [actas\_rate\_limiting\_count](#input\_actas\_rate\_limiting\_count) | ActAs rating limiting count | `number` | n/a | yes |
| <a name="input_allow_canary_ipjc_ingress"></a> [allow\_canary\_ipjc\_ingress](#input\_allow\_canary\_ipjc\_ingress) | Whether to allow ipjc ingress traffic from the canary central project | `bool` | `false` | no |
| <a name="input_anonymous_ip_enforcement"></a> [anonymous\_ip\_enforcement](#input\_anonymous\_ip\_enforcement) | Switch to enable AWS Managed WAF modules for blocking Anonymous IP reputation rule groups for ENFORCING only. | `bool` | n/a | yes |
| <a name="input_anonymous_ip_preview"></a> [anonymous\_ip\_preview](#input\_anonymous\_ip\_preview) | Switch to enable AWS Managed WAF modules for blocking Anonymous IP reputation rule groups to be used for PREVIEW only. | `bool` | n/a | yes |
| <a name="input_ask_rate_limiting_count"></a> [ask\_rate\_limiting\_count](#input\_ask\_rate\_limiting\_count) | ask (expensive call) rate limiting count | `number` | n/a | yes |
| <a name="input_autocomplete_rate_limiting_count"></a> [autocomplete\_rate\_limiting\_count](#input\_autocomplete\_rate\_limiting\_count) | autocomplete (non-critical call) rate limiting count | `number` | n/a | yes |
| <a name="input_block-ugc-write-endpoints"></a> [block-ugc-write-endpoints](#input\_block-ugc-write-endpoints) | If true, blocks all UGC write endpoints | `bool` | `false` | no |
| <a name="input_block_user_agents"></a> [block\_user\_agents](#input\_block\_user\_agents) | User agents to block | `list(string)` | `[]` | no |
| <a name="input_country_red_list"></a> [country\_red\_list](#input\_country\_red\_list) | Country Red List | `list(string)` | n/a | yes |
| <a name="input_debug_rate_limiting_count"></a> [debug\_rate\_limiting\_count](#input\_debug\_rate\_limiting\_count) | debug (expensive call) rate limiting count | `number` | `100` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_enforce_baseline_rule_set"></a> [enforce\_baseline\_rule\_set](#input\_enforce\_baseline\_rule\_set) | If true, this will block traffic in the AWS baseline rule groups | `bool` | `false` | no |
| <a name="input_ip_green_list"></a> [ip\_green\_list](#input\_ip\_green\_list) | A list specific IPs (in CIDR format) to permit access | `list(string)` | n/a | yes |
| <a name="input_ip_red_list"></a> [ip\_red\_list](#input\_ip\_red\_list) | A list of IPs (in CIDR format) to reject | `list(string)` | n/a | yes |
| <a name="input_ip_waf_rule_lists_enforcement"></a> [ip\_waf\_rule\_lists\_enforcement](#input\_ip\_waf\_rule\_lists\_enforcement) | This is a list of AWS Managed WAF modules regarding IP reputation rule groups to be used for ENFORCEMENT only. | `list(string)` | n/a | yes |
| <a name="input_ip_waf_rule_lists_preview"></a> [ip\_waf\_rule\_lists\_preview](#input\_ip\_waf\_rule\_lists\_preview) | Switch to enable AWS Managed WAF modules regarding IP reputation rule groups to be used for PREVIEW only. | `bool` | n/a | yes |
| <a name="input_known_glean_canary_ip"></a> [known\_glean\_canary\_ip](#input\_known\_glean\_canary\_ip) | The known IP of the Glean's canary central service | `string` | `"104.198.208.205"` | no |
| <a name="input_known_glean_central_datasources_ip"></a> [known\_glean\_central\_datasources\_ip](#input\_known\_glean\_central\_datasources\_ip) | The known IP of Glean's central datasources IP | `string` | `"104.154.230.46"` | no |
| <a name="input_known_glean_ip"></a> [known\_glean\_ip](#input\_known\_glean\_ip) | The known IP of Glean's central service to interact with the deployment | `string` | `"35.239.35.180"` | no |
| <a name="input_nat_gateway_public_ip"></a> [nat\_gateway\_public\_ip](#input\_nat\_gateway\_public\_ip) | The NAT gateway public IP | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to use for WAF resources | `string` | `"us-east-1"` | no |
| <a name="input_search_rate_limiting_count"></a> [search\_rate\_limiting\_count](#input\_search\_rate\_limiting\_count) | search (expensive call) rate limiting count | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_waf_log_group_name"></a> [aws\_waf\_log\_group\_name](#output\_aws\_waf\_log\_group\_name) | This is the AWS WAF CloudWatch Log Group Name |
| <a name="output_external_web_acl_arn"></a> [external\_web\_acl\_arn](#output\_external\_web\_acl\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
