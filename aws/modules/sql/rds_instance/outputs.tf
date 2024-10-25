output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.rds_instance.id
}

output "rds_instance_arn" {
  value = aws_db_instance.rds_instance.arn
}

output "root_secret_arn" {
  value = aws_db_instance.rds_instance.master_user_secret[0].secret_arn
}