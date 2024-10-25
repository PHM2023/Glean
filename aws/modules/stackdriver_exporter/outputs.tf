output "application_log_group_name" {
  value = aws_cloudwatch_log_group.application_log_group.name
}

output "operation_log_group_name" {
  value = aws_cloudwatch_log_group.structured_log_groups["operation-log"].name
}

output "fluent_bit_application_log_group_name" {
  value = aws_cloudwatch_log_group.fluent_bit_application_log_group.name
}
