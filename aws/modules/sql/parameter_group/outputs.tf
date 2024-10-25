output "parameter_group_name" {
  description = "The name of the parameter group"
  value       = aws_db_parameter_group.parameter_group.name
}
