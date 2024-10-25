# IAM Policies for the buckets

resource "aws_iam_policy" "config_bucket_reader_policy" {
  name        = "GleanConfigBucketRead"
  description = "Read access to the config bucket (e.g. for reading dynamic.ini object)"
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
          "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}/*"
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
        "Resource" : aws_s3_bucket.config_bucket.arn
      }
    ]
  })
}

resource "aws_iam_policy" "config_bucket_writer_policy" {
  name        = "GleanConfigBucketWrite"
  description = "Write access to the config bucket (e.g. for reading dynamic.ini object)"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.config_bucket.id}/*"
        ]
      },
      {
        "Action" : "s3:ListBucket",
        "Effect" : "Allow",
        "Resource" : aws_s3_bucket.config_bucket.arn
      }
    ]
  })
}

resource "aws_iam_policy" "dataflow_bucket_reader_policy" {
  name        = "GleanDataflowBucketRead"
  description = "Read access to the dataflow bucket (for pipeline jobs and qp/scholastic processing)"
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
          "arn:aws:s3:::${aws_s3_bucket.dataflow_bucket.id}/*"
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
        "Resource" : aws_s3_bucket.dataflow_bucket.arn
      }
    ]
  })
}

resource "aws_iam_policy" "dataflow_bucket_writer_policy" {
  name        = "GleanDataflowBucketWrite"
  description = "Write access to the dataflow bucket (for quality/training jobs)"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.dataflow_bucket.id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "docs_dump_bucket_reader_policy" {
  name        = "GleanDocsDumpBucketRead"
  description = "Read access to the docs dump bucket (for pipeline jobs and qp/scholastic processing)"
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
          "arn:aws:s3:::${aws_s3_bucket.docs_dump_bucket.id}/*"
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
        "Resource" : aws_s3_bucket.docs_dump_bucket.arn
      }
    ]
  })
}


resource "aws_iam_policy" "docs_dump_bucket_writer_policy" {
  name        = "GleanDocsDumpBucketWrite"
  description = "Write access to the docs dump bucket (for pipeline jobs and qp/scholastic processing)"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
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
          "arn:aws:s3:::${aws_s3_bucket.docs_dump_bucket.id}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucketMultipartUploads"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.docs_dump_bucket.id}"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "scio_activity_bucket_reader_policy" {
  name        = "GleanActivityBucketRead"
  description = "Read access to the scio activity bucket"
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
          "arn:aws:s3:::${aws_s3_bucket.activity_export["activity"].id}/*"
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
        "Resource" : aws_s3_bucket.activity_export["activity"].arn
      }
    ]
  })
}

resource "aws_iam_policy" "elastic_snapshot_bucket_reader_policy" {
  name        = "GleanElasticSnapshotBucketRead"
  description = "Read access to the elastic snapshots bucket (for backing up the index)"
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
          "arn:aws:s3:::${aws_s3_bucket.elastic_snapshots_bucket.id}/*"
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
        "Resource" : aws_s3_bucket.elastic_snapshots_bucket.arn
      }
    ]
  })
}


resource "aws_iam_policy" "elastic_snapshot_bucket_writer_policy" {
  name        = "GleanElasticSnapshotBucketWrite"
  description = "Write access to the elastic snapshots bucket (for backing up the index)"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.elastic_snapshots_bucket.id}/*"
        ]
      }
    ]
  })
}



resource "aws_iam_policy" "elastic_plugin_bucket_reader_policy" {
  name        = "GleanElasticPluginBucketRead"
  description = "Read access to the elastic plugin bucket (for downloading new versions of our plugin within the opensearch image)"
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
          "arn:aws:s3:::${aws_s3_bucket.elastic_plugin_bucket.id}/*"
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
        "Resource" : aws_s3_bucket.elastic_plugin_bucket.arn
      }
    ]
  })
}


resource "aws_iam_policy" "elastic_plugin_bucket_writer_policy" {
  name        = "GleanElasticPluginBucketWrite"
  description = "Write access to the elastic plugin bucket (for uploading new versions of the plugin during deploys)"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.elastic_plugin_bucket.id}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_policy" "query_metadata_buckets_reader_policy" {
  name        = "GleanQueryMetadataBucketsRead"
  description = "Read access to the relevant query metadata buckets"
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
          "arn:aws:s3:::${aws_s3_bucket.query_metadata_bucket.id}/*",
          "arn:aws:s3:::${aws_s3_bucket.general_query_metadata_bucket.id}/*",
          "arn:aws:s3:::${aws_s3_bucket.persistent_query_metadata_bucket.id}/*"
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
          "arn:aws:s3:::${aws_s3_bucket.query_metadata_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.general_query_metadata_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.persistent_query_metadata_bucket.id}"
        ]
      }
    ]
  })
}


resource "aws_iam_policy" "query_metadata_buckets_writer_policy" {
  name        = "GleanQueryMetadataBucketsWrite"
  description = "Write access to the relevant query metadata buckets"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.query_metadata_bucket.id}/*",
          "arn:aws:s3:::${aws_s3_bucket.general_query_metadata_bucket.id}/*",
          "arn:aws:s3:::${aws_s3_bucket.persistent_query_metadata_bucket.id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "query_secrets_bucket_reader" {
  name        = "GleanQuerySecretsBucketReader"
  description = "Read access to the secrets bucket used for secure communication between query services"
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
          "arn:aws:s3:::${aws_s3_bucket.query_secrets_bucket.id}/*",
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
        "Resource" : aws_s3_bucket.query_secrets_bucket.arn
      }
    ]
  })
}


resource "aws_iam_policy" "flink_artifacts_bucket_write_policy" {
  name        = "GleanFlinkArtifactsBucketWrite"
  description = "Write access to the S3 bucket which stores Flink job artifacts"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
        ],
        "Resource" : [
          "${aws_s3_bucket.flink_artifacts_bucket.arn}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_policy" "flink_buckets_access_policy" {
  name        = "GleanFlinkBucketsAccess"
  description = "Read/Write access to the Flink checkpoints and artifacts buckets"
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
          "${aws_s3_bucket.flink_checkpoints_bucket.arn}/*",
          "${aws_s3_bucket.flink_completed_jobs_bucket.arn}/*",
          "${aws_s3_bucket.people_distance_bucket.arn}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectAttributes"
        ],
        "Resource" : [
          "${aws_s3_bucket.flink_artifacts_bucket.arn}/*"
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
          aws_s3_bucket.flink_checkpoints_bucket.arn,
          aws_s3_bucket.flink_artifacts_bucket.arn,
          aws_s3_bucket.flink_completed_jobs_bucket.arn,
          aws_s3_bucket.people_distance_bucket.arn
        ]
      },
      {
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Effect = "Allow",
        Resource = [
          for bucket_name in local.s3_exports : "arn:aws:s3:::scio-${var.account_id}-${bucket_name}/*"
        ]
      },
      {
        Action = ["s3:ListBucket"],
        Effect = "Allow",
        Resource = [
          for bucket_name in local.s3_exports : "arn:aws:s3:::scio-${var.account_id}-${bucket_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "flink_python_additional_permissions_policy" {
  name        = "GleanFlinkPythonAdditionalPermissions"
  description = "Additional permissions for python quality Flink jobs"
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
          "${aws_s3_bucket.flink_artifacts_bucket.arn}/*"
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
          aws_s3_bucket.flink_artifacts_bucket.arn
        ]
      },
      {
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:GetObjectAttributes"],
        Effect = "Allow",
        Resource = [
          for bucket_name in local.quality_s3_exports : "arn:aws:s3:::scio-${var.account_id}-${bucket_name}/*"
        ]
      },
      {
        Action = ["s3:ListBucket"],
        Effect = "Allow",
        Resource = [
          for bucket_name in local.quality_s3_exports : "arn:aws:s3:::scio-${var.account_id}-${bucket_name}"
        ]
      }
    ]
  })
}
