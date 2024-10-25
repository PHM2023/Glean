# Add logging IAM policy
# This IAM policy will be added to all the service IAM roles
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "GleanCloudWatchLogsPolicy"
  path        = "/"
  description = "Allows a role to perform actions on CloudWatch logs"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

output "cloudwatch_logs_policy_arn" {
  value = aws_iam_policy.cloudwatch_logs_policy.arn
}