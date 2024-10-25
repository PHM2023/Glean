output "aws_waf_log_group_name" {
  description = "This is the AWS WAF CloudWatch Log Group Name"
  value       = aws_cloudwatch_log_group.aws_waf_logs_glean.name
}

output "external_web_acl_arn" {
  value = aws_wafv2_web_acl.glean_waf.arn
}