

# Create upgrade_opensearch_nodepool lambda
resource "aws_lambda_function" "upgrade_opensearch_nodepool" {
  function_name = "upgrade_opensearch_nodepool"
  role          = aws_iam_role.upgrade_opensearch_nodepool.arn
  image_uri     = var.image_uri
  architectures = ["x86_64"]
  timeout       = 900
  package_type  = "Image"
  memory_size   = 512
  vpc_config {
    security_group_ids = [var.lambda_security_group_id]
    subnet_ids         = [var.lambda_subnet_id]
  }
}


# Create upgrade_opensearch_nodepool role
resource "aws_iam_role" "upgrade_opensearch_nodepool" {
  name                 = "UpgradeOpensearchRole"
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
    aws_iam_policy.upgrade_opensearch_nodepool_amazon_eks_cluster_policy.arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    aws_iam_policy.upgrade_opensearch_nodepool_storage_secret_permissions_policy.arn,
    var.config_bucket_reader_policy_arn
  ]
}

resource "aws_iam_policy" "upgrade_opensearch_nodepool_amazon_eks_cluster_policy" {
  name        = "upgrade-opensearch-nodepool_AmazonEKSClusterPolicy"
  description = "Allows upgrade-opensearch-nodepool to describe clusters in EKS and log groups"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
        ]
        Resource = "arn:aws:eks:${var.region}:${var.account_id}:cluster/${var.cluster_name}"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
        ]
        Resource = "arn:aws:logs:${var.region}:${var.account_id}:log-group:*"
      }
    ]
  })
}


resource "aws_iam_policy" "upgrade_opensearch_nodepool_storage_secret_permissions_policy" {
  name = "UpgradeOpensearchNodepoolStorageSecretPermissions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt"
        ],
        Resource = var.storage_secrets_key_arn
      }
    ]
  })
}
