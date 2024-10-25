
# Create expunge_deleted_opensearch_docs lambda
resource "aws_lambda_function" "expunge_deleted_opensearch_docs" {
  function_name = "expunge_deleted_opensearch_docs"
  role          = aws_iam_role.expunge_deleted_opensearch_docs.arn
  image_uri     = var.image_uri
  architectures = ["x86_64"]
  timeout       = 900
  package_type  = "Image"
  # we've seen expunge-deleted-opensearch-docs run out of memory at 512MB: https://github.com/askscio/scio/pull/91263
  memory_size = 1024
  vpc_config {
    security_group_ids = [var.lambda_security_group_id]
    subnet_ids         = [var.lambda_subnet_id]
  }
}


# Create expunge_deleted_opensearch_docs role
resource "aws_iam_role" "expunge_deleted_opensearch_docs" {
  name                 = "ExpungeDeletedOpensearchDocsRole"
  permissions_boundary = var.iam_permissions_boundary_arn

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    var.config_bucket_reader_policy_arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]
}
