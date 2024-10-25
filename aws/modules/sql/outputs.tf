output "frontend_sql_instance_id" {
  value = module.frontend_rds_instance.rds_instance_id
}

output "backend_sql_instance_id" {
  value = module.backend_rds_instance.rds_instance_id
}

output "root_sql_access_policy_arn" {
  value = aws_iam_policy.root_sql_access_policy.arn
}

output "sql_connect_policy_arn" {
  value = aws_iam_policy.sql_connect_policy.arn
}