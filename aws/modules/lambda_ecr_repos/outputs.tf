output "repo_names" {
  # Map of local repo name to existent ECR repo name. Callers can use this to ensure they're referencing valid repos
  value = { for repo_name in local.lambda_repository_names : repo_name => aws_ecr_repository.lambda_ecr_repo[repo_name].name }
}