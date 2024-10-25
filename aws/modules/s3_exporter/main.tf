# lambda
resource "aws_lambda_function" "s3_exporter" {
  function_name = "s3_exporter"
  role          = aws_iam_role.s3_exporter.arn
  image_uri     = var.image_uri
  architectures = ["x86_64"]
  timeout       = 900
  package_type  = "Image"
}

# role
resource "aws_iam_role" "s3_exporter" {
  name                 = "s3-exporter"
  permissions_boundary = var.iam_permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}


resource "aws_lambda_permission" "s3_exporter_cloudwatch_invoke_access" {
  statement_id   = "CloudWatchInvokeAcccess"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.s3_exporter.function_name
  principal      = "logs.amazonaws.com"
  source_arn     = "arn:aws:logs:${var.region}:${var.account_id}:log-group:*:*"
  source_account = var.account_id
}

resource "aws_cloudwatch_log_group" "activity_log_groups" {
  for_each = toset(local.s3_exports)
  name     = each.key
}

resource "aws_cloudwatch_log_subscription_filter" "s3_exporter_activity_subscription_filters" {
  name            = "ActivitySubscriptionFilters"
  for_each        = toset(local.s3_exports)
  log_group_name  = each.key
  filter_pattern  = ""
  destination_arn = "arn:aws:lambda:${var.region}:${var.account_id}:function:s3_exporter"
  distribution    = "Random"
  depends_on      = [aws_lambda_permission.s3_exporter_cloudwatch_invoke_access, aws_cloudwatch_log_group.activity_log_groups]
}
