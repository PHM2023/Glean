
resource "aws_iam_policy" "additional_logs_policy" {
  name        = "AdditionalLogsPolicy"
  description = "Allow ingress logs processor lambda to perform logging operations"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogStreams"
        ],
        "Resource" : [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:glean_application_logs:*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ingress_logs_reader_policy" {
  name        = "IngressLogsReaderPolicy"
  description = "Allows ingress logs processor lambda to read access logs for glean ingress from s3 bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
        ],
        "Resource" : [
          "arn:aws:s3:::${var.ingress_logs_bucket}/*"
        ]
      }
    ]
  })
}

data "aws_iam_policy" "basic_lambda_role" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "ingress_access_logs_exporter_role" {
  name                 = "GleanIngressAccessLogsExporterRole"
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
    aws_iam_policy.additional_logs_policy.arn,
    aws_iam_policy.ingress_logs_reader_policy.arn,
    data.aws_iam_policy.basic_lambda_role.arn,
    var.config_bucket_reader_policy_arn
  ]
}

resource "aws_lambda_permission" "allow_ingress_logs_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingress_logs_processor.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.ingress_logs_bucket_arn
}

resource "aws_lambda_function_event_invoke_config" "ingress_logs_processor_lambda_config" {
  function_name          = aws_lambda_function.ingress_logs_processor.function_name
  maximum_retry_attempts = 0
}

resource "aws_lambda_function" "ingress_logs_processor" {
  function_name = "ingress_logs_processor"
  role          = aws_iam_role.ingress_access_logs_exporter_role.arn
  image_uri     = var.image_uri
  architectures = ["x86_64"]
  timeout       = 900
  package_type  = "Image"
  memory_size   = 2048
  environment {
    variables = {
      # Set these so we can start exporting logs to gcp right away (we don't need to wait for the
      # aws.gcpConnectorProject* configs to be updated first)
      "GOOGLE_CLOUD_PROJECT" : var.gcp_connector_project_id,
      "GOOGLE_PROJECT_NUMBER" : var.gcp_connector_project_number
    }
  }
}

resource "aws_s3_bucket_notification" "ingress_access_logs_bucket_notification" {
  bucket = var.ingress_logs_bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.ingress_logs_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".log.gz"
  }

  depends_on = [aws_lambda_permission.allow_ingress_logs_bucket]
}
