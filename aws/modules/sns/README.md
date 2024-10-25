# sns

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.53.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.53.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.activities_publisher_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.answers_publisher_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.answers_subscriber_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.docbuilder_publisher_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.docbuilder_sqs_reader_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.docbuilder_subscriber_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.qe_cache_refreshes_publisher_subscriber_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.salient_terms_publisher_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.salient_terms_subscriber_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.tools_publisher_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.tools_subscriber_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_sns_topic.activities_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.answers_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.docbuilder_adhoc_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.docbuilder_processed_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.docbuilder_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.qe_cache_refreshes_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.salient_terms_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.tools_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.docbuilder_adhoc_sqs_sns_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.docbuilder_sqs_sns_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.docbuilder_adhoc_sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.docbuilder_sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.docbuilder_adhoc_sns_sqs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_sqs_queue_policy.docbuilder_sns_sqs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to use when creating SNS resources | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_answers_subscriber_policy_arn"></a> [answers\_subscriber\_policy\_arn](#output\_answers\_subscriber\_policy\_arn) | n/a |
| <a name="output_answers_topic_arn"></a> [answers\_topic\_arn](#output\_answers\_topic\_arn) | n/a |
| <a name="output_docbuilder_sqs_reader_policy_arn"></a> [docbuilder\_sqs\_reader\_policy\_arn](#output\_docbuilder\_sqs\_reader\_policy\_arn) | n/a |
| <a name="output_docbuilder_subscriber_policy_arn"></a> [docbuilder\_subscriber\_policy\_arn](#output\_docbuilder\_subscriber\_policy\_arn) | n/a |
| <a name="output_docbuilder_topic_arn"></a> [docbuilder\_topic\_arn](#output\_docbuilder\_topic\_arn) | n/a |
| <a name="output_docbuilder_topic_publisher_policy_arn"></a> [docbuilder\_topic\_publisher\_policy\_arn](#output\_docbuilder\_topic\_publisher\_policy\_arn) | n/a |
| <a name="output_qe_cache_refreshes_policy_arn"></a> [qe\_cache\_refreshes\_policy\_arn](#output\_qe\_cache\_refreshes\_policy\_arn) | n/a |
| <a name="output_salient_terms_publisher_policy_arn"></a> [salient\_terms\_publisher\_policy\_arn](#output\_salient\_terms\_publisher\_policy\_arn) | n/a |
| <a name="output_salient_terms_subscriber_policy_arn"></a> [salient\_terms\_subscriber\_policy\_arn](#output\_salient\_terms\_subscriber\_policy\_arn) | n/a |
| <a name="output_tools_publisher_policy_arn"></a> [tools\_publisher\_policy\_arn](#output\_tools\_publisher\_policy\_arn) | n/a |
| <a name="output_tools_subscriber_policy_arn"></a> [tools\_subscriber\_policy\_arn](#output\_tools\_subscriber\_policy\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
