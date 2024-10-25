
resource "aws_lambda_function" "probe_initiator" {
  function_name = "probe_initiator"
  role          = aws_iam_role.probe_initiator.arn
  image_uri     = var.image_uri
  architectures = ["x86_64"]
  timeout       = 300
  package_type  = "Image"
  memory_size   = 1024
  vpc_config {
    security_group_ids = [var.lambda_security_group_id]
    subnet_ids         = [var.lambda_subnet_id]
  }
}

resource "aws_iam_role" "probe_initiator" {
  name                 = "probe-initiator"
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
    aws_iam_policy.read_probe_initiator_credentials_secrets_policy.arn,
    data.aws_iam_policy.basic_lambda_role.arn,
    data.aws_iam_policy.vpc_access_lambda_role.arn,
    var.config_bucket_reader_policy_arn,
  ]
}

resource "aws_iam_policy" "read_probe_initiator_credentials_secrets_policy" {
  name        = "ReadProbeInitiatorCredentialsSecrets"
  description = "Allows reading probe initiator credentials secrets."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:PROBE_INITIATOR_CREDENTIALS_*"
      }
    ]
  })
}

resource "aws_iam_policy" "probe_initiator_invoker_policy" {
  name        = "InvokeProbeInitiator"
  description = "Allows invoking probe initiator."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
        ]
        # intentionally not using aws_lambda_function.probe_initiator.arn so that this resource (which is exported in
        # outputs.tf) is not actually dependent on the lambda function (and therefore it's not dependent on the
        # long-running preprocess_lambda_image.py script).
        Resource = "arn:aws:lambda:${var.region}:${var.account_id}:function:probe_initiator"
      }
    ]
  })
}
