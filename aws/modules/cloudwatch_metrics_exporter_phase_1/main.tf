# Responsible for setting up the IAM roles required within the aws account for the
# cloudwatch metrics exporter to work

resource "aws_iam_role" "cloudwatch_exporter_role" {
  name                 = "GleanCloudWatchExporter"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "accounts.google.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "accounts.google.com:aud" = var.cloud_watch_exporter_gcp_service_account_client_id
          }
        }
      }
    ]
  })
  managed_policy_arns = [aws_iam_policy.cloudwatch_exporter_policy.arn]
}

resource "aws_iam_policy" "cloudwatch_exporter_policy" {
  name = "GleanCloudWatchExporterPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "tag:GetResources",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
        ]
        Resource = "*"
      }
    ]
  })
}
