
###################### DSE ######################

# A policy for all additional permissions needed by DSE that aren't really shared with other roles
resource "aws_iam_policy" "dse_permissions_policy" {
  name        = "AdditionalDSEPermissions"
  description = "Additional permissions for the datasource events handler role. Allows the role to run queries on the sensitive-logs logs group"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:StartQuery",
          "logs:GetQueryResults"
        ],
        "Resource" : [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:sensitive-logs"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Sign",
          "kms:GetPublicKey"
        ],
        "Resource" : [
          module.kms.slackbot_key_arn,
          module.kms.tools_key_arn
        ]
      },
      {
        # Needed by debug handlers for pipelines dashboard
        "Effect" : "Allow",
        "Action" : "lambda:InvokeFunction",
        "Resource" : [
          "arn:aws:lambda:${var.region}:${var.account_id}:function:cron_helper"
        ]
      },
      # For getting backups for sql health check
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDBSnapshots",
        ],
        "Resource" : [
          "arn:aws:rds:${var.region}:${var.account_id}:db:*",
          "arn:aws:rds:${var.region}:${var.account_id}:snapshot:*"
        ]
      },
      # For autoscaling rds instance for autosize health check
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDBInstances",
          "rds:ModifyDBInstance",
        ],
        "Resource" : [
          "arn:aws:rds:${var.region}:${var.account_id}:db:*"
        ]
      },
      # For getting metrics for health checks
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:GetMetricData",
        ]
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectAttributes"
        ],
        "Resource" : [
          "arn:aws:s3:::${module.s3.feedback_data_bucket}/*",
        ]
      }
    ]
  })
}

# Role definition
resource "aws_iam_role" "dse" {
  name                 = "DatasourceEventsHandlerRole"
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
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:default:datasource-events",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns = concat(local.core_permission_policies, [
    module.kms.ipjc_signing_key_get_public_key_policy_arn,
    module.kms.slackbot_key_get_public_key_policy_arn,
    module.s3.config_bucket_writer_policy_arn,
    module.sns.docbuilder_topic_publisher_policy_arn,
    aws_iam_policy.dse_permissions_policy.arn
  ])
}

###################### QE ######################
# A policy for all additional permissions needed by QE that aren't really shared with other roles
resource "aws_iam_policy" "qe_permissions_policy" {
  name        = "AdditionalQueryEndpointPermissions"
  description = "Additional permissions for the query endpoint handler role"
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
          "arn:aws:s3:::${module.s3.query_secrets_bucket}/*",
          "arn:aws:s3:::${module.s3.entity_data_bucket}/*",
          "arn:aws:s3:::${module.s3.image_data_bucket}/*",
          "arn:aws:s3:::${module.s3.feedback_data_bucket}/*",
          "arn:aws:s3:::${module.s3.query_greenlist_bucket}/*",
          "arn:aws:s3:::${module.s3.query_metadata_bucket}/*",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${module.s3.entity_data_bucket}/*",
          "arn:aws:s3:::${module.s3.image_data_bucket}/*",
          "arn:aws:s3:::${module.s3.feedback_data_bucket}/*",
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
          module.s3.query_secrets_bucket_arn,
          module.s3.entity_data_bucket_arn,
          module.s3.image_data_bucket_arn,
          module.s3.feedback_data_bucket_arn,
          module.s3.query_greenlist_bucket_arn,
          module.s3.query_metadata_bucket_arn
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish"
        ],
        "Resource" : [
          module.sns.answers_topic_arn,
          module.sns.docbuilder_topic_arn
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Sign",
          "kms:GetPublicKey"
        ],
        "Resource" : [
          module.kms.slackbot_key_arn,
          module.kms.tools_key_arn,
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ],
        "Resource" : [
          "arn:aws:bedrock:*::foundation-model/*",
          "arn:aws:bedrock:${var.region}:${var.account_id}:provisioned-model/*"
        ]
      }
    ]
  })
}


# Role definition
resource "aws_iam_role" "qe_iam_role" {
  name                 = "QueryEndpointHandlerRole"
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
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:default:query-endpoint",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns = concat(local.core_permission_policies, [
    aws_iam_policy.qe_permissions_policy.arn,
    module.kms.query_secret_key_cryptor_policy_arn,
    module.sns.qe_cache_refreshes_policy_arn,
    module.kms.slackbot_key_get_public_key_policy_arn
  ])
}



###################### Task Handlers (Crawler) ######################

resource "aws_iam_policy" "task_handlers_additional_policy" {
  name        = "GleanTaskHandlersAdditionalPermissions"
  description = "Additional permissions needed only by task handlers"
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
          "arn:aws:s3:::${module.s3.entity_data_bucket}/*",
          "arn:aws:s3:::${module.s3.crawl_temp_bucket}/*",
          "arn:aws:s3:::${module.s3.gitlab_identity_bucket}/*",
          "arn:aws:s3:::${module.s3.csv_storage_bucket}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${module.s3.crawl_temp_bucket}/*",
          "arn:aws:s3:::${module.s3.csv_storage_bucket}/*",
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
          module.s3.entity_data_bucket_arn,
          module.s3.crawl_temp_bucket_arn,
          module.s3.gitlab_identity_bucket_arn,
          module.s3.csv_storage_bucket_arn
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Sign",
          "kms:GetPublicKey"
        ],
        "Resource" : [
          module.kms.slackbot_key_arn
        ]
      },
      # For getting backups for sql health check
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDBSnapshots",
        ],
        "Resource" : [
          "arn:aws:rds:${var.region}:${var.account_id}:db:*",
          "arn:aws:rds:${var.region}:${var.account_id}:snapshot:*"
        ]
      },
      # For autoscaling rds instance for autosize health check
      {
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDBInstances",
          "rds:ModifyDBInstance",
        ],
        "Resource" : [
          "arn:aws:rds:${var.region}:${var.account_id}:db:*"
        ]
      },
      # For getting metrics for health checks
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:GetMetricData",
        ],
        "Resource" : [
          "*"
        ]
      },
      # For getting resource metrics
      {
        "Effect" : "Allow",
        "Action" : [
          "pi:GetResourceMetrics",
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}


# Role definition
resource "aws_iam_role" "task_handlers_iam_role" {
  name                 = "TaskHandlersRole"
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
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:default:task-handlers",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns = concat(local.core_permission_policies, [
    module.sns.docbuilder_topic_publisher_policy_arn,
    aws_iam_policy.task_handlers_additional_policy.arn,
    module.probe_initiator.probe_initiator_invoker_policy_arn
  ])
}

###################### Query Parser ######################
# Role definition
resource "aws_iam_role" "query_parser_iam_role" {
  name                 = "QueryParserRole"
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
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:default:query-parser",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns = concat(local.core_permission_policies, [
    module.s3.query_secrets_bucket_reader_policy_arn,
    module.kms.query_secret_key_cryptor_policy_arn,
    module.s3.query_metadata_bucket_reader_policy_arn,
    module.s3.config_bucket_writer_policy_arn
  ])
}

###################### Scholastic ######################
# Role definition
resource "aws_iam_role" "scholastic_iam_role" {
  name                 = "ScholasticRole"
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
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:default:scholastic",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns = [
    module.sql.sql_connect_policy_arn,
    module.eks_phase_1.cloudwatch_logs_policy_arn,
    module.s3.config_bucket_reader_policy_arn,
    module.sns.answers_subscriber_policy_arn,
    module.sns.docbuilder_subscriber_policy_arn,
    module.sns.salient_terms_subscriber_policy_arn,
    module.sns.tools_subscriber_policy_arn,
    module.s3.query_metadata_bucket_reader_policy_arn,
    module.kms.query_secret_key_cryptor_policy_arn,
    module.s3.query_secrets_bucket_reader_policy_arn
  ]
}


###################### Admin Console ######################

resource "aws_iam_policy" "admin_console_additional_permissions_policy" {
  name        = "AdditionalAdminConsolePermissions"
  description = "Additional permissions needed by the admin console role"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        # Needed for toggling crawls after datasource setup
        "Effect" : "Allow",
        "Action" : "lambda:InvokeFunction",
        "Resource" : "arn:aws:lambda:${var.region}:${var.account_id}:function:deploy_build"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Sign"
        ],
        "Resource" : [
          module.kms.slackbot_key_arn
        ]
      }
    ]
  })
}


# Role definition
resource "aws_iam_role" "admin_console_iam_role" {
  name                 = "AdminConsoleRole"
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
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:default:admin-console",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns = concat(local.core_permission_policies, [
    module.s3.config_bucket_writer_policy_arn,
    module.sns.tools_publisher_policy_arn,
    aws_iam_policy.admin_console_additional_permissions_policy.arn
  ])
}


###################### Task Push ##########################
# Role definition
resource "aws_iam_role" "task_push_iam_role" {
  name                 = "TaskPushRole"
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
          "${module.eks_phase_1.oidc_provider}:sub": "system:serviceaccount:default:task-push",
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns  = local.core_permission_policies
}


###################### Opensearch ##########################
# Role definition
resource "aws_iam_role" "elastic_compute_iam_role" {
  name                 = "ElasticComputeRole"
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
          "${module.eks_phase_1.oidc_provider}:sub": [
            "system:serviceaccount:elasticsearch-1-namespace:elastic-compute-ksa",
            "system:serviceaccount:elasticsearch-2-namespace:elastic-compute-ksa"
          ],
          "${module.eks_phase_1.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
  managed_policy_arns = concat(local.core_permission_policies, [
    module.s3.elastic_plugin_bucket_reader_policy_arn,
    module.s3.elastic_snapshot_bucket_reader_policy_arn,
    module.s3.elastic_snapshot_bucket_writer_policy_arn,
    module.s3.activity_bucket_reader_policy_arn
  ])
}