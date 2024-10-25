# NOTE: all of the policies/roles here should be independent of any resources created by other modules, since this
# module should be able to run first in the setup/deploy flow.

resource "aws_iam_policy" "additional_codebuild_tagging_permissions_policy" {
  name = "AdditionalCodeBuildTaggingPermissionsPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "GleanTaggingPolicy",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetBucketTagging",
          "s3:PutBucketTagging",
          "s3:ListTagsForResource",
          "s3:TagResource",
          "s3:UntagResource",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging",
          "s3:DeleteObjectTagging",
          "iam:TagPolicy",
          "iam:UntagPolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagInstanceProfile",
          "iam:UntagInstanceProfile",
          "eks:TagResource",
          "eks:UntagResource",
          "iam:TagOpenIDConnectProvider",
          "iam:UntagOpenIDConnectProvider",
          "sqs:TagQueue",
          "sqs:UntagQueue",
          "wafv2:TagResource",
          "wafv2:UntagResource",
          "tag:GetResources",
          "tag:TagResources",
          "tag:UntagResources"
        ],
        "Resource" : "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "codebuild_additional_tagging_permissions_attachment" {
  policy_arn = aws_iam_policy.additional_codebuild_tagging_permissions_policy.arn
  role       = data.aws_iam_role.codebuild_role.name
}

resource "aws_iam_role" "ml_training" {
  name                 = "ml-training"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      },
    ]
  })
  depends_on = [aws_iam_role_policy_attachment.codebuild_additional_tagging_permissions_attachment]
  managed_policy_arns = [
    aws_iam_policy.ml_training_policy.arn,
    "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
  ]
}



resource "aws_iam_policy" "ml_training_policy" {
  name = "GleanMLTrainingPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectAttributes"
        ],
        "Resource" : [
          "arn:aws:s3:::config-${var.account_id}/*",
          "arn:aws:s3:::dataflow-${var.account_id}/*",
          "arn:aws:s3:::docs-dump-${var.account_id}/*",
          "arn:aws:s3:::scio-${var.account_id}-query-metadata/*",
          "arn:aws:s3:::scio-${var.account_id}-general-query-metadata/*",
          "arn:aws:s3:::scio-${var.account_id}-persistent-query-metadata/*",
        ]
      },
      {
        "Action" : [
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucket",
          "s3:ListBucketVersions"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::config-${var.account_id}",
          "arn:aws:s3:::dataflow-${var.account_id}",
          "arn:aws:s3:::docs-dump-${var.account_id}",
          "arn:aws:s3:::scio-${var.account_id}-query-metadata",
          "arn:aws:s3:::scio-${var.account_id}-general-query-metadata",
          "arn:aws:s3:::scio-${var.account_id}-persistent-query-metadata",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::scio-${var.account_id}-query-metadata/*",
          "arn:aws:s3:::scio-${var.account_id}-general-query-metadata/*",
          "arn:aws:s3:::scio-${var.account_id}-persistent-query-metadata/*",
        ]
      },
      # TODO: add permissions here to use the glean-vpc for each job
    ]
  })
}


resource "aws_iam_policy" "additional_codebuild_iam_permissions_policy" {
  name        = "AdditionalCodeBuildIAMPermissionsPolicy"
  description = "All additional IAM permissions needed by the codebuild role"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:CreatePolicyVersion",
          "iam:DeletePolicy",
          "iam:DeletePolicyVersion",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListInstanceProfilesForRole",
          "iam:ListPolicyVersions",
          "iam:ListRoles",
          "iam:PutRolePolicy",
          "iam:UpdateAssumeRolePolicy",
        ],
        "Resource" : "*"
      }
    ]
  })
  depends_on = [aws_iam_role_policy_attachment.codebuild_additional_tagging_permissions_attachment]
}

resource "aws_iam_policy" "additional_codebuild_permissions_policy" {
  name        = "AdditionalCodeBuildPermissionsPolicy"
  description = "All additional permissions needed by the codebuild role"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "servicequotas:Get*",
          "servicequotas:List*",
          "servicequotas:RequestServiceQuotaIncrease"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:Get*",
          "ssm:List*",
          "ssm:StartSession",
          "ssm:TerminateSession",
          "ssm:Describe*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "rds-db:connect"
        ],
        "Resource" : [
          # We could restrict this to the actual instances we create, but that would require knowing db instance id's
          # which are randomly generated by AWS. So we would have to only run this op after SETUP_SQL, which is unideal
          # given that this op should be able to run without any dependencies
          "arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:*",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:StartDBInstance",
          "rds:StopDBInstance",
          "rds:RebootDBInstance",
          "rds:DescribeDBSnapshots",
          "rds:DescribeOrderableDBInstanceOptions",
          "rds:RestoreDBInstanceFromDBSnapshot",
          "dynamodb:ListTables"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "DynamoDbForTerraform",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:CreateTable"
        ],
        "Resource" : "arn:aws:dynamodb:${var.region}:${var.account_id}:table/glean-terraform-state"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:PutSecretValue",
          "secretsmanager:DeleteSecret"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:DeleteNodeGroup",
          "eks:Update*",
          "eks:Create*",
          "eks:Delete*",
          "eks:List*",
          "eks:Describe*",
          "eks:AssociateEncryptionConfig",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:SetWebACL",
          "s3:PutBucketNotification",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DescribeTargetHealth",
          "codebuild:BatchGetProjects"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:SetWebACL",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeListeners",
          "ec2:*",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:CreateOrUpdateTags",
          "autoscaling:DeleteTags",
          "autoscaling:DescribeTags",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObjectAcl",
          "s3:PutObjectAcl",
          "s3:GetBucketNotification"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:ModifyDBInstance"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:DeleteBucket",
          "s3:DeleteBucketPolicy",
          "s3:GetAccountPublicAccessBlock",
          "s3:PutAccountPublicAccessBlock",
          "s3:PutBucketPolicy"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codeguru-profiler:CreateProfilingGroup",
          "codeguru-profiler:DeleteProfilingGroup",
          "codeguru-profiler:DescribeProfilingGroup",
          "codeguru-profiler:ListProfilingGroups",
          "codeguru-profiler:PostAgentProfile",
          "codeguru-profiler:ConfigureAgent",
          "codeguru-profiler:PutPermission",
          "codeguru-profiler:Get*",
          "codeguru-profiler:BatchGet*",
          "codeguru-profiler:List*",
          "codeguru-profiler:Describe*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          # These actions aren't documented in
          # https://docs.aws.amazon.com/service-authorization/latest/reference/list_awscloudformation.html but they are
          # needed for the codeguru api to be enabled in eks_phase_2/services_iam.tf
          "cloudformation:CreateResource",
          "cloudformation:DeleteResource",
          "cloudformation:GetResource*",
          "cloudformation:ListResource*",
          "cloudformation:UpdateResource",
          "cloudformation:TagResource",
          "cloudformation:UntagResource"
        ],
        "Resource" : "*"
      },
      {
        # for allowing codebuild to manage datasync resources needed to copy activity data from gcs
        "Effect" : "Allow",
        "Action" : [
          "datasync:*",
          # this one is needed specifically to get the right version of the ami
          "ssm:GetParameter"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudfront:Get*",
          "cloudfront:List*",
          "cloudfront:Describe*",
          "cloudfront:TagResource",
          "cloudfront:UntagResource",
          "cloudfront:UpdateDistribution",
          "cloudfront:CreateDistribution",
          "cloudfront:DeleteDistribution"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "wafv2:GetLoggingConfiguration",
          "wafv2:ListLoggingConfigurations",
          "wafv2:PutLoggingConfiguration",
          "wafv2:DeleteLoggingConfiguration",
          "wafv2:Create*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Sid" : "ExternalRepositoryPermissions",
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:ListImages",
        ],
        "Resource" : [
          # Allow pulling from the central us-east-1 repos
          "arn:aws:ecr:us-east-1:518642952506:repository/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Sid" : "InternalRepositoryPermissions"
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:ListImages",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:TagResource",
          "ecr:UntagResource",
          "ecr:ListTagsForResource",
          "ecr:DeleteRepository",
          "ecr:GetRepositoryPolicy",
          "ecr:SetRepositoryPolicy"
        ]
        "Resource" : [
          # Allow pulling/pushing images internally
          "arn:aws:ecr:${var.region}:${var.account_id}:repository/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Sid" : "InternalEcrPermissions"
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:CreateRepository"
        ],
        # No resource qualifier is applicable for these
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Sid" : "KMSRotation"
        "Action" : [
          "kms:EnableKeyRotation"
        ],
        "Resource" : "arn:aws:kms:${var.region}:${var.account_id}:key/*"
      }
    ]
  })
  depends_on = [
    aws_iam_role_policy_attachment.codebuild_additional_iam_permissions_attachment,
    aws_iam_role_policy_attachment.codebuild_additional_tagging_permissions_attachment
  ]
}

# this is an OK dependency to have since this must be created before any deploys can run (i.e. by the bootstrap CFT)
data "aws_iam_role" "codebuild_role" {
  name = "codebuild"
}

resource "aws_iam_role_policy_attachment" "codebuild_additional_iam_permissions_attachment" {
  policy_arn = aws_iam_policy.additional_codebuild_iam_permissions_policy.arn
  role       = data.aws_iam_role.codebuild_role.name
}

resource "aws_iam_role_policy_attachment" "codebuild_additional_permissions_attachment" {
  policy_arn = aws_iam_policy.additional_codebuild_permissions_policy.arn
  role       = data.aws_iam_role.codebuild_role.name
}

data "aws_iam_role" "glean-viewer-role" {
  name = "glean-viewer"
}

resource "aws_iam_policy" "additional_glean_viewer_permissions_policy" {
  name        = "AdditionalGleanViewerPermissionsPolicy"
  description = "All additional permissions needed by the glean-viewer role"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:Describe*",
          "rds:List*",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:Search*",
          "ec2:Get*",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Deny",
        "Action" : [
          "ec2:GetConsole*",
          "ec2:GetPassword*",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "pi:GetResourceMetrics",
          "pi:DescribeDimensionKeys",
          "pi:ListAvailableResourceMetrics",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:ListRoles",
          "iam:ListRolePolicies",
          "iam:ListRoleTags",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListEntitiesForPolicy"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:ListTagsLogGroup",
          "logs:GetLogRecord",
          "logs:GetQueryResults",
          "logs:DescribeLogStreams",
          "logs:DescribeSubscriptionFilters",
          "logs:StartQuery",
          "logs:FilterLogEvents",
          "logs:GetLogGroupFields",
        ],
        "Resource" : [
          "arn:aws:logs:*:${var.account_id}:log-group:/aws/sagemaker/*",
          "arn:aws:logs:*:${var.account_id}:log-group:glean_application_logs:*",
          "arn:aws:logs:*:${var.account_id}:log-group:extra-logs:*",
          "arn:aws:logs:*:${var.account_id}:log-group:operation-log:*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codeguru:Get*",
          "codeguru-profiler:Get*",
          "codeguru-profiler:BatchGet*",
          "codeguru-profiler:Describe*",
          "codeguru-profiler:List*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sagemaker:ListTags",
          "sagemaker:ListTrainingJobs",
          "sagemaker:DescribeTrainingJob"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:GetLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:*:${var.account_id}:log-group:/aws/sagemaker/*:log-stream:*",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "datasync:DescribeAgent",
          "datasync:DescribeTask",
          "datasync:DescribeTaskExecution",
          "datasync:List*",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "servicequotas:Get*",
          "servicequotas:List*",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ce:DescribeReport",
        ],
        "Resource" : "*"
      }
    ]
  })
  depends_on = [aws_iam_role_policy_attachment.codebuild_additional_tagging_permissions_attachment]
}

resource "aws_iam_role_policy_attachment" "glean_viewer_additional_permissions_attachment" {
  policy_arn = aws_iam_policy.additional_glean_viewer_permissions_policy.arn
  role       = data.aws_iam_role.glean-viewer-role.name
}

resource "aws_iam_role_policy_attachment" "glean_viewer_bedrock_viewer_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockReadOnly"
  role       = data.aws_iam_role.glean-viewer-role.name
}

resource "aws_iam_role_policy_attachment" "glean_viewer_billing_viewer_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
  role       = data.aws_iam_role.glean-viewer-role.name
}

data "aws_iam_role" "glean_deployer" {
  name = "glean-deployer"
}

resource "aws_iam_policy" "additional_glean_deployer_permissions_policy" {
  name        = "AdditionalGleanDeployerPermissions"
  description = "All additional permissions needed by the glean-deployer role"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudfront:ListDistributions"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "additional_glean_deployer_permissions_attachment" {
  policy_arn = aws_iam_policy.additional_glean_deployer_permissions_policy.arn
  role       = data.aws_iam_role.glean_deployer.name
}
