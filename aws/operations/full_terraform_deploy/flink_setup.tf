module "flink_namespace_config_reads" {
  source              = "./read_config"
  region              = var.region
  account_id          = var.account_id
  keys                = ["flink.operator.namespace", "flink.jobs.namespace"]
  default_config_path = var.default_config_path
  custom_config_path  = var.custom_config_path
}

# Role definition
resource "aws_iam_role" "flink_watchdog_iam_role" {
  name                 = "FlinkWatchdogRole"
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
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:${module.k8s.flink_watchdog_namespace}:flink-watchdog-ksa",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns  = local.core_permission_policies
}


resource "aws_iam_policy" "additional_flink_java_permissions_policy" {
  name        = "AdditionalFlinkJavaPermissions"
  description = "Additional permissions for the Flink Java Jobs role"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      # permissions to read rds root secrets for non-iam rds auth for flink java jobs
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : [
          "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:rds*"
        ]
      },
      # docs-dump bucket write permissions
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads"
        ],
        "Resource" : [
          "arn:aws:s3:::${module.s3.docs_dump_bucket}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucketMultipartUploads"
        ],
        "Resource" : [
          "arn:aws:s3:::${module.s3.docs_dump_bucket}"
        ]
      },
      # Allow CodeGuru Profiler agent to send profiles to CodeGuru Profiler service
      # Copied from AmazonCodeGuruProfilerAgentAccess AWS Managed Policy
      {
        "Effect" : "Allow",
        "Action" : [
          "codeguru-profiler:ConfigureAgent",
          "codeguru-profiler:CreateProfilingGroup",
          "codeguru-profiler:PostAgentProfile"
        ],
        "Resource" : "arn:aws:codeguru-profiler:*:*:profilingGroup/*"
      }
    ]
  })
}

resource "aws_iam_role" "flink_java_jobs_iam_role" {
  name                 = "FlinkJavaJobsRole"
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
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:${module.flink_namespace_config_reads.values["flink.jobs.namespace"]}:flink",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns = [
    module.eks_phase_1.cloudwatch_logs_policy_arn,
    module.s3.config_bucket_reader_policy_arn,
    module.kms.secret_store_cryptor_policy_arn,
    module.sql.sql_connect_policy_arn,
    module.sns.docbuilder_topic_publisher_policy_arn,
    module.sns.salient_terms_publisher_policy_arn,
    module.s3.flink_bucket_access_policy_arn,
    module.s3.docs_dump_bucket_reader_policy_arn,
    module.sns.docbuilder_sqs_reader_policy_arn,
    aws_iam_policy.additional_flink_java_permissions_policy.arn
  ]
}

# TODO(platform): We should facet by individual service pipeline rather than language here
resource "aws_iam_role" "flink_python_jobs_iam_role" {
  name                 = "FlinkPythonJobsRole"
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
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        },
        "StringLike": {
            "${module.eks_phase_1.oidc_provider}:sub": [
                "system:serviceaccount:*:beam-sdk-harness"
            ]
        }
      }
    }
  ]
}
EOF
  managed_policy_arns = [
    module.eks_phase_1.cloudwatch_logs_policy_arn,
    module.s3.config_bucket_reader_policy_arn,
    module.sql.sql_connect_policy_arn,
    module.s3.flink_bucket_access_policy_arn,
    module.s3.docs_dump_bucket_reader_policy_arn,
    module.s3.flink_python_additional_permissions_policy_arn
  ]
}

resource "aws_iam_policy" "flink_invoker_additional_permissions" {
  name        = "FlinkInvokerAdditionalPermissions"
  description = "Allows flink-invoker job to create, list and describe nodegroups in EKS, describe EC2 launch templates, create/update tags"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:ListNodegroups",
          "eks:CreateNodegroup",
          "eks:UpdateNodegroupVersion",
          "eks:UpdateNodegroupConfig",
          "eks:DescribeNodegroup",
          "eks:DescribeCluster",
          "eks:TagResource",
        ]
        Resource = [
          "arn:aws:eks:${var.region}:${var.account_id}:cluster/${module.eks_phase_1.cluster_name}",
          "arn:aws:eks:${var.region}:${var.account_id}:nodegroup/${module.eks_phase_1.cluster_name}/*",
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
        Effect = "Allow"
        Action = [
          "ec2:Create*",
          "ec2:Describe*",
          "ec2:RunInstances",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:GetRole",
          "iam:ListAttachedRolePolicies",
        ]
        Resource = [module.eks_phase_1.worker_node_arn, module.eks_phase_1.eks_cluster_role_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
        ]
        Resource = ["arn:aws:iam::${var.account_id}:role/aws-service-role/eks-nodegroup.amazonaws.com/AWSServiceRoleForAmazonEKSNodegroup"]
      },
  ] })
}


# IAM Role for accessing AWS resources like S3, RDS, Secrets Manager, etc.
resource "aws_iam_role" "flink_invoker_iam_role" {
  name                 = "FlinkInvoker"
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
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:${module.k8s.flink_invoker_namespace}:flink-invoker-ksa",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns = concat(local.core_permission_policies, [
    module.s3.flink_bucket_access_policy_arn,
    module.s3.query_metadata_bucket_reader_policy_arn,
    module.s3.config_bucket_reader_policy_arn,
    aws_iam_policy.flink_invoker_additional_permissions.arn
  ])
}
