# S3 Buckets

resource "aws_s3_bucket" "config_bucket" {
  bucket = "config-${var.account_id}"
}

resource "aws_s3_bucket_versioning" "config_bucket_versioning" {
  bucket = aws_s3_bucket.config_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "dataflow_bucket" {
  bucket = "dataflow-${var.account_id}"
}

resource "aws_s3_bucket" "docs_dump_bucket" {
  bucket = "docs-dump-${var.account_id}"
}

resource "aws_s3_bucket" "elastic_plugin_bucket" {
  bucket = "elastic-plugin-${var.account_id}"
}

resource "aws_s3_bucket" "elastic_snapshots_bucket" {
  bucket = "elastic-snapshots-${var.account_id}"
}

resource "aws_s3_bucket" "general_query_metadata_bucket" {
  bucket = "scio-${var.account_id}-general-query-metadata"
}

resource "aws_s3_bucket" "persistent_query_metadata_bucket" {
  bucket = "scio-${var.account_id}-persistent-query-metadata"
}

resource "aws_s3_object" "synonyms_txt" {
  bucket  = aws_s3_bucket.persistent_query_metadata_bucket.id
  key     = "synonyms.txt"
  content = ""
}

resource "aws_s3_bucket" "query_metadata_bucket" {
  bucket = "scio-${var.account_id}-query-metadata"
}

resource "aws_s3_bucket" "query_secrets_bucket" {
  bucket = "scio-secrets-${var.account_id}"
}

resource "aws_s3_bucket" "flink_artifacts_bucket" {
  bucket = "glean-flink-artifacts-${var.account_id}"
}

resource "aws_s3_bucket" "flink_checkpoints_bucket" {
  bucket = "glean-flink-checkpoints-${var.account_id}"
}

resource "aws_s3_bucket" "flink_completed_jobs_bucket" {
  bucket = "glean-flink-completed-jobs-${var.account_id}"
}

resource "aws_s3_bucket" "people_distance_bucket" {
  bucket = "people-distance-${var.account_id}"
}

# We want to delete old artifacts and checkpoints after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "flink_artifacts_expiration" {
  bucket = aws_s3_bucket.flink_artifacts_bucket.id
  rule {
    id     = "flink-artifacts-expiration"
    status = "Enabled"
    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "flink_checkpoints_expiration" {
  bucket = aws_s3_bucket.flink_checkpoints_bucket.id
  rule {
    id     = "flink-checkpoints-expiration"
    status = "Enabled"
    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket" "activity_export" {
  for_each = toset(local.s3_exports)
  # TODO: remove this after workflows bucket is cleaned up
  force_destroy = each.key == "workflows"
  bucket        = "scio-${var.account_id}-${each.key}"
}

resource "aws_s3_bucket" "upgrade_operations_bucket" {
  bucket = "${var.account_id}-upgrade-operations"
}

resource "aws_s3_bucket_versioning" "upgrade_op_bucket_versioning" {
  bucket = aws_s3_bucket.upgrade_operations_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "async_operations_bucket" {
  bucket = "async-ops-${var.account_id}"
}

resource "aws_s3_bucket_versioning" "async_operations_bucket_versioning" {
  bucket = aws_s3_bucket.async_operations_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "entity_data_bucket" {
  bucket = "entity-data-${var.account_id}"
}

resource "aws_s3_bucket" "image_data_bucket" {
  bucket = "image-data-${var.account_id}"
}

resource "aws_s3_bucket" "feedback_data_bucket" {
  bucket = "feedback-data-${var.account_id}"
}

resource "aws_s3_bucket" "crawl_temp" {
  bucket = "crawl-temp-${var.account_id}"
}

resource "aws_s3_bucket_lifecycle_configuration" "crawl_temp_expiration" {
  bucket = aws_s3_bucket.crawl_temp.id
  rule {
    id     = "crawl-temp-expiration"
    status = "Enabled"
    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket" "self_hosted_airflow_logs_bucket" {
  bucket = "glean-airflow-logs-${var.account_id}"
}

resource "aws_s3_bucket" "query_greenlist_bucket" {
  bucket = "greenlisted-queries-${var.account_id}"
}

resource "aws_s3_bucket_object" "initial_query_greenlist" {
  bucket  = aws_s3_bucket.query_greenlist_bucket.id
  key     = "whitelisted_queries.txt"
  content = "*\n"
  lifecycle {
    ignore_changes = [
      # Ignore any content changes after initial setup
      content,
      content_base64
    ]
  }
}

# The following s3 bucket setup for access logs from ALB (glean-ingress) is based on https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
resource "aws_s3_bucket" "ingress_logs_bucket" {
  bucket = "ingress-logs-${var.account_id}"
}

data "aws_iam_policy_document" "ingress_access_logs_bucket_policy_document" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.ingress_logs_bucket.bucket}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.elb_account_ids[var.region]}:root"]
    }
  }
}

resource "aws_s3_bucket_policy" "ingress_access_logs_bucket_policy" {
  bucket = aws_s3_bucket.ingress_logs_bucket.id
  policy = data.aws_iam_policy_document.ingress_access_logs_bucket_policy_document.json
}

resource "aws_s3_bucket" "static_workflows_bucket" {
  bucket = "scio-${var.account_id}-static-workflows"
}

resource "aws_s3_bucket" "gitlab_identity_bucket" {
  bucket = "scio-${var.account_id}-gitlab-identity"
}

resource "aws_s3_bucket" "csv_storage_bucket" {
  bucket = "glean-${var.account_id}-csv-storage"
}
