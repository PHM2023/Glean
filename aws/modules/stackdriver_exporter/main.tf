

# lambda
resource "aws_lambda_function" "stackdriver_log_exporter" {
  function_name = "stackdriver_log_exporter"
  role          = aws_iam_role.stackdriver_exporter.arn
  image_uri     = var.image_uri
  architectures = ["x86_64"]
  timeout       = 900
  package_type  = "Image"
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
resource "aws_iam_role" "stackdriver_exporter" {
  name                 = "stackdriver-exporter"
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
    var.config_bucket_reader_policy_arn
  ]
}

data "aws_iam_policy" "basic_lambda_role" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "stackdriver_exporter_cloudwatch_invoke_access" {
  statement_id   = "CloudWatchInvokeAcccess"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.stackdriver_log_exporter.function_name
  principal      = "logs.amazonaws.com"
  source_arn     = "arn:aws:logs:${var.region}:${var.account_id}:log-group:*:*"
  source_account = var.account_id
}

# NOTE: These groups are typically imported before terraform plan but ideally should be created before the relevant workloads that write to them,
# since the workloads can create these log groups on-demand.
resource "aws_cloudwatch_log_group" "application_log_group" {
  name = "glean_application_logs"
}

resource "aws_cloudwatch_log_group" "request_log_group" {
  name = "request-logs"
}

resource "aws_cloudwatch_log_group" "sagemaker_training_job_log_group" {
  name = "/aws/sagemaker/TrainingJobs"
}

# aws-waf-logs-glean is managed in WAF. This is created before the webacl gets created so it
# doesn't need to be imported.  If it does need to be imported, then it would need to be imported
# as: 'module.waf.aws_cloudwatch_log_group.aws_waf_logs_glean': 'aws-waf-logs-glean'
# in full_terraform_imports.py

resource "aws_cloudwatch_log_group" "structured_log_groups" {
  for_each = toset(local.externally_exported_log_names)
  name     = each.key
}

resource "aws_cloudwatch_log_group" "lambda_log_groups" {
  for_each = toset(local.lambda_logs_to_export)
  name     = each.key
}

resource "aws_cloudwatch_log_subscription_filter" "application_log_filter" {
  destination_arn = aws_lambda_function.stackdriver_log_exporter.arn
  # captures logs from all eks workloads and lambdas that use our logging libraries
  filter_pattern = local.export_filter_pattern
  log_group_name = aws_cloudwatch_log_group.application_log_group.name
  name           = "Glean Application Log Filter"
  lifecycle {
    # If we delete this we may lose logs briefly
    prevent_destroy = true
  }
}

resource "aws_cloudwatch_log_subscription_filter" "request_log_filter" {
  destination_arn = aws_lambda_function.stackdriver_log_exporter.arn
  # same as above
  filter_pattern = local.export_filter_pattern
  log_group_name = aws_cloudwatch_log_group.request_log_group.name
  name           = "Glean Request Log Filter"
  lifecycle {
    # Same as above
    prevent_destroy = true
  }
}


resource "aws_cloudwatch_log_subscription_filter" "structured_log_filters" {
  for_each        = toset(local.externally_exported_log_names)
  destination_arn = aws_lambda_function.stackdriver_log_exporter.arn
  filter_pattern  = local.export_filter_pattern
  log_group_name  = aws_cloudwatch_log_group.structured_log_groups[each.key].name
  name            = "Glean Structured Log Filter"
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_log_filter" {
  for_each        = toset(local.lambda_logs_to_export)
  destination_arn = aws_lambda_function.stackdriver_log_exporter.arn
  filter_pattern  = local.export_filter_pattern
  log_group_name  = aws_cloudwatch_log_group.lambda_log_groups[each.key].name
  name            = "Glean Structured Log Filter"
}

# special case for container insights application logs (from fluent bit)

resource "aws_cloudwatch_log_group" "fluent_bit_application_log_group" {
  name = "/aws/containerinsights/glean-cluster/application"
}

resource "aws_cloudwatch_log_subscription_filter" "fluent_bit_application_log_filter" {
  destination_arn = aws_lambda_function.stackdriver_log_exporter.arn
  # captures logs from all eks workloads and lambdas that use our logging libraries
  filter_pattern = local.fluent_bit_exporter_filter_pattern
  log_group_name = aws_cloudwatch_log_group.fluent_bit_application_log_group.name
  name           = "Glean Fluent Bit Application Log Filter"
}

# Would add this once stackdriver_exporter.py change is merged in
# resource "aws_cloudwatch_log_subscription_filter" "glean_cluster_audit_log_filter" {
#   destination_arn = aws_lambda_function.stackdriver_log_exporter.arn
#   # captures logs from all eks workloads and lambdas that use our logging libraries
#   filter_pattern = ""
#   log_group_name = module.eks_phase_1.cluster_audit_log_name
#   name           = "Glean Cluster Audit Logs"
#   lifecycle {
#     # If we delete this we may lose logs briefly
#     prevent_destroy = true
#   }
# }

resource "aws_cloudwatch_log_subscription_filter" "sagemaker_training_log_filter" {
  destination_arn = aws_lambda_function.stackdriver_log_exporter.arn
  # captures all logs
  filter_pattern = ""
  log_group_name = aws_cloudwatch_log_group.sagemaker_training_job_log_group.name
  name           = "Glean Sagemaker Training Job Log Filter"
}

resource "aws_cloudwatch_log_subscription_filter" "aws_waf_log_filter" {
  destination_arn = aws_lambda_function.stackdriver_log_exporter.arn
  # captures all logs
  filter_pattern = ""
  log_group_name = var.aws_waf_log_group_name
  name           = "Glean AWS WAF log filter"
}
