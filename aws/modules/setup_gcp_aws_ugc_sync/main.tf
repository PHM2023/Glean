resource "aws_iam_role" "aws-gcp-migrator-role" {
  name                 = "gcp-aws-migrator"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "accounts.google.com"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "accounts.google.com:aud" : var.gcp_client_id
          }
        }
      }
    ]
  })
}


data "aws_instance" "bastion-instance" {
  filter {
    name   = "tag:Name"
    values = ["bastion"]
  }
}

data "aws_db_instance" "fe-instance" {
  db_instance_identifier = "fe-instance"
}

resource "aws_iam_policy" "migrator-connection-policy" {
  name        = "GleanGcpAwsMigratorPolicy"
  description = "Policy for allowing sql connections to the frontend rds instance to migrate UGC data"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "rds-db:connect"
        ],
        "Resource" : "arn:aws:rds-db:${var.region}:${var.account_id}:dbuser:${data.aws_db_instance.fe-instance.resource_id}/glean-ugc-migrator"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDBInstances"
        ],
        "Resource" : [
          data.aws_db_instance.fe-instance.db_instance_arn
        ]
      },
      {
        # We also need these permissions for creating a bastion connection
        "Effect" : "Allow",
        "Action" : [
          "ec2:Describe*",
          "ssm:Get*",
          "ssm:Describe*",
          "ssm:List*",
          "ssm:StartSession",
          "ssm:TerminateSession",
          "sts:GetCallerIdentity"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:Describe*",
          "ssm:StartSession",
          "ssm:TerminateSession",
        ],
        "Resource" : data.aws_instance.bastion-instance.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "gcp-migrator-policy-attachment" {
  policy_arn = aws_iam_policy.migrator-connection-policy.arn
  role       = aws_iam_role.aws-gcp-migrator-role.name
}

data "aws_iam_policy" "config-bucket-reader-policy" {
  name = "GleanConfigBucketRead"
}

resource "aws_iam_role_policy_attachment" "gcp-migrator-policy-config-attachment" {
  policy_arn = data.aws_iam_policy.config-bucket-reader-policy.arn
  role       = aws_iam_role.aws-gcp-migrator-role.name
}