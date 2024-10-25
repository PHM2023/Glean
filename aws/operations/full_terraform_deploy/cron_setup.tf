#### Lambda invoker role (for invoking cron helper and other lambdas during k8s cron jobs)

resource "aws_iam_policy" "lambda_invoker_policy" {
  name = "LambdaInvokerPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowLambdaInvocation",
        "Effect" : "Allow",
        "Action" : "lambda:InvokeFunction",
        "Resource" : [
          # intentionally not using data links to these since they may not have been created by the time this setup runs
          "arn:aws:lambda:${var.region}:${var.account_id}:function:cron_helper",
          "arn:aws:lambda:${var.region}:${var.account_id}:function:upgrade_opensearch_nodepool",
          "arn:aws:lambda:${var.region}:${var.account_id}:function:expunge_deleted_opensearch_docs",
        ]
      }
    ]
  })
}


# Role definition
resource "aws_iam_role" "lambda_invoker_iam_role" {
  name                 = "LambdaInvoker"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.account_id}:oidc-provider/${module.eks_phase_1.oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:default:lambda-invoker",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns  = [aws_iam_policy.lambda_invoker_policy.arn]
}
