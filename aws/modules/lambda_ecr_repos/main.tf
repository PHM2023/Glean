locals {
  lambda_repository_names = [
    "cron_helper",
    "aws_stackdriver_log_exporter",
    "expunge_deleted_opensearch_docs",
    "probe_initiator",
    "flink_direct_memory_oom_detection",
    "aws_deploy_build",
    "upgrade_opensearch_nodepool",
    "ingress_logs_processor",
    "s3_exporter",
    # Note: technically this one isn't needed by lambda but sagemaker, but we can declare the ecr repo here for simplicity
    "glean-sagemaker-training-base"
  ]
}

resource "aws_ecr_repository" "lambda_ecr_repo" {
  for_each = toset(local.lambda_repository_names)
  name     = each.key
}

data "aws_iam_policy_document" "repo_policy_doc" {
  statement {
    sid    = "AllowInternalLambdas"
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages"
    ]
    condition {
      test     = "StringLike"
      values   = ["arn:aws:lambda:${var.region}:${var.account_id}:function:*"]
      variable = "aws:sourceArn"
    }
  }
}

resource "aws_ecr_repository_policy" "lambda_ecr_repo_policy" {
  for_each   = toset(local.lambda_repository_names)
  policy     = data.aws_iam_policy_document.repo_policy_doc.json
  repository = aws_ecr_repository.lambda_ecr_repo[each.key].name
}
