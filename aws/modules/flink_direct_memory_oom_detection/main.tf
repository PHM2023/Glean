# lambda
resource "aws_lambda_function" "flink_direct_memory_oom_detection" {
  function_name = "flink_direct_memory_oom_detection"
  role          = aws_iam_role.flink_direct_memory_oom_detection.arn
  image_uri     = var.image_uri
  architectures = ["x86_64"]
  timeout       = 900
  memory_size   = 1024
  package_type  = "Image"
  vpc_config {
    security_group_ids = [var.lambda_security_group_id]
    subnet_ids         = [var.lambda_subnet_id]
  }
  environment {
    variables = {
      # Set these so we can start exporting logs to gcp right away (we don't need to wait for the
      # aws.gcpConnectorProject* configs to be updated first)
      "GOOGLE_CLOUD_PROJECT" : var.gcp_connector_project_id,
      "GOOGLE_PROJECT_NUMBER" : var.gcp_connector_project_number
    }
  }
}

# role
resource "aws_iam_role" "flink_direct_memory_oom_detection" {
  name                 = "flink-direct-memory-oom-detection"
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
    data.aws_iam_policy.basic_lambda_role.arn,
    data.aws_iam_policy.lambda_vpc_access_execution_role.arn,
    var.config_bucket_reader_policy_arn
  ]
}

resource "aws_lambda_permission" "flink_direct_memory_oom_cloud_watch_invoke_access" {
  statement_id   = "CloudWatchInvokeAcccess"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.flink_direct_memory_oom_detection.function_name
  principal      = "logs.amazonaws.com"
  source_arn     = "arn:aws:logs:${var.region}:${var.account_id}:log-group:*:*"
  source_account = var.account_id
}

resource "aws_cloudwatch_log_subscription_filter" "fluent_bit_application_log_filter" {
  destination_arn = aws_lambda_function.flink_direct_memory_oom_detection.arn
  # Only captures data from flink-taskmanager containers
  filter_pattern = "{ $.kubernetes.container_name = flink-taskmanager }"
  log_group_name = var.fluent_bit_application_log_group
  name           = "Flink Direct Memory OOM Log Filter"
}
