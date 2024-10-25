output "docbuilder_topic_publisher_policy_arn" {
  value = aws_iam_policy.docbuilder_publisher_policy.arn
}

output "answers_topic_arn" {
  value = aws_sns_topic.answers_sns_topic.arn
}

output "docbuilder_topic_arn" {
  value = aws_sns_topic.docbuilder_sns_topic.arn
}

output "qe_cache_refreshes_policy_arn" {
  value = aws_iam_policy.qe_cache_refreshes_publisher_subscriber_policy.arn
}

output "answers_subscriber_policy_arn" {
  value = aws_iam_policy.answers_subscriber_policy.arn
}

output "docbuilder_subscriber_policy_arn" {
  value = aws_iam_policy.docbuilder_subscriber_policy.arn
}

output "salient_terms_subscriber_policy_arn" {
  value = aws_iam_policy.salient_terms_subscriber_policy.arn
}

output "tools_subscriber_policy_arn" {
  value = aws_iam_policy.tools_subscriber_policy.arn
}

output "tools_publisher_policy_arn" {
  value = aws_iam_policy.tools_publisher_policy.arn
}

output "salient_terms_publisher_policy_arn" {
  value = aws_iam_policy.salient_terms_publisher_policy.arn
}

output "docbuilder_sqs_reader_policy_arn" {
  value = aws_iam_policy.docbuilder_sqs_reader_policy.arn
}