
### Create IAM role and policies for airflow nodegroup ###

resource "aws_iam_policy" "self_hosted_airflow_read_central_dags" {
  name        = "self_hosted_airflow_read_central_dags"
  description = "Allow airflow to read DAGs in aws-glean-eng glean-chomp-dags bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::glean-chomp-dags/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::glean-chomp-dags*"
        }
    ]
}
EOF
}


resource "aws_iam_policy" "self_hosted_airflow_read_test_dags" {
  name        = "self_hosted_airflow_read_test_dags"
  description = "Allow airflow to read DAGs in same deployment test bucket, delete post testing"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::glean-test-dags/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::glean-test-dags*"
        }
    ]
}
EOF
}


resource "aws_iam_policy" "self_hosted_airflow_logs_bucket_access" {
  name        = "self_hosted_airflow_logs_bucket_access"
  description = "Read/Write access airflow logs bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:GetObjectAttributes"
        ],
        "Resource" : [
          "${module.s3.self_hosted_airflow_logs_bucket_arn}/*",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucket",
          "s3:ListBucketVersions"
        ],
        "Resource" : [
          module.s3.self_hosted_airflow_logs_bucket_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "self_hosted_airflow_nodes_iam_role" {
  name                 = "AirflowNodesIAMRole"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.account_id}:oidc-provider/${module.eks_phase_1.oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:airflow:self-hosted-airflow-worker",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.account_id}:oidc-provider/${module.eks_phase_1.oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:airflow:self-hosted-airflow-webserver",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    data.aws_iam_policy.cloudwatch_agent_policy.arn,
    aws_iam_policy.lambda_invoker_policy.arn,
    aws_iam_policy.self_hosted_airflow_read_central_dags.arn,
    aws_iam_policy.self_hosted_airflow_read_test_dags.arn,
    aws_iam_policy.self_hosted_airflow_logs_bucket_access.arn
  ]
}
