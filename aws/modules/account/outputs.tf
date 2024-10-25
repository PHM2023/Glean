output "account_id" {
  value       = aws_organizations_account.account.id
  description = "The account ID of the created AWS account"
}
