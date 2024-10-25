
# lambda
resource "aws_lambda_function" "cron_helper" {
  function_name = "cron_helper"
  role          = aws_iam_role.cron_helper.arn
  image_uri     = var.image_uri
  architectures = ["x86_64"]
  timeout       = 900
  package_type  = "Image"
  memory_size   = 2048
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
resource "aws_iam_role" "cron_helper" {
  name                 = "cron-helper"
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
    aws_iam_policy.cron_helper_amazon_eks_nodegroup_policy.arn,
    aws_iam_policy.cron_helper_additional_permissions_policy.arn,
    aws_iam_policy.cron_helper_storage_secret_permissions_policy.arn,
    var.config_bucket_reader_policy_arn,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    # TODO: scope these way down
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess",
  ]
}

resource "aws_iam_role" "glean_cron_helper_invoker_iam_role" {
  name                 = "cron-helper-invoker"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "accounts.google.com"
        }
        Condition = {
          StringEquals = {
            # This is known service account id for the Glean account that will be running chomp operations
            # airflow-chomp-sa@scio-engineering.iam.gserviceaccount.com
            "accounts.google.com:aud" = "108067902309312661827"
          }
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.cron_helper_invoker_policy.arn]
}

resource "aws_iam_policy" "cron_helper_amazon_eks_nodegroup_policy" {
  name        = "cron-helper_AmazonEKSNodeGroupPolicy"
  description = "Allows cron-helper to create, list and describe nodegroups in EKS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:ListNodegroups",
          "eks:CreateNodegroup"
        ]
        Resource = "arn:aws:eks:${var.region}:${var.account_id}:cluster/${var.cluster_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "eks:List*",
          "eks:Describe*",
          "eks:Create*",
          "eks:Delete*"

        ]
        Resource = "*"
      },
  ] })
}

resource "aws_iam_policy" "cron_helper_invoker_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = aws_lambda_function.cron_helper.arn
      }
    ]
  })
}


resource "aws_iam_policy" "cron_helper_storage_secret_permissions_policy" {
  name = "CronHelperStorageSecretPermissions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt"
        ],
        Resource = var.storage_secret_key_arn
      }
    ]
  })
}


resource "aws_iam_policy" "cron_helper_additional_permissions_policy" {
  name = "CronHelperAdditionalPermissions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # TODO: cron_helper currently creates nodegroups to run flink jobs, so it some more aggressive permissions. We
      #  need to move tf-based nodegroups to mitigate this
      {
        Effect   = "Allow"
        Action   = ["kms:Sign"]
        Resource = var.ipjc_key_arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "rds-db:connect"
        ],
        "Resource" : [
          "arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:*/glean",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:CreateOrUpdateTags"
        ],
        "Resource" : "*"
      },
      {
        "Action" : [
          "ec2:Create*",
          "ec2:Describe*",
          "ec2:RunInstances",
          "eks:UpdateNodegroupVersion",
          "eks:CreateNodegroup",
          "eks:UpdateNodegroupConfig",
          "eks:TagResource",

        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "iam:PassRole",
          "iam:GetRole",
          "iam:ListAttachedRolePolicies"
        ],
        "Effect" : "Allow",
        "Resource" : [
          var.eks_worker_node_arn,
          var.eks_cluster_role_arn,
          "arn:aws:iam::${var.account_id}:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup"
        ]
      },
      {
        # To allow deletion of stale codebuild projects
        "Action" : [
          "codebuild:BatchGetProjects",
          "codebuild:DeleteProject",
          "codebuild:ListProjects"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cron_helper_invoker_deploy_build" {
  role       = data.aws_iam_role.deploy_build.name
  policy_arn = aws_iam_policy.cron_helper_invoker_policy.arn
}

