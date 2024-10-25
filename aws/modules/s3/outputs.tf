output "elastic_plugin_bucket" {
  value = aws_s3_bucket.elastic_plugin_bucket.id
}

output "flink_artifacts_bucket" {
  value = aws_s3_bucket.flink_artifacts_bucket.id
}

output "dataflow_bucket" {
  value = aws_s3_bucket.dataflow_bucket.id
}

output "config_bucket_reader_policy_arn" {
  value = aws_iam_policy.config_bucket_reader_policy.arn
  # Don't let the config bucket be used until versioning is enabled
  depends_on = [aws_s3_bucket_versioning.config_bucket_versioning]
}

output "config_bucket_writer_policy_arn" {
  value = aws_iam_policy.config_bucket_writer_policy.arn
  # Same as above, versioning must be enabled first before the config bucket is used
  depends_on = [aws_s3_bucket_versioning.config_bucket_versioning]
}

output "elastic_plugin_bucket_reader_policy_arn" {
  value = aws_iam_policy.elastic_plugin_bucket_reader_policy.arn
}

output "query_secrets_bucket" {
  value = aws_s3_bucket.query_secrets_bucket.id
}

output "feedback_data_bucket" {
  value = aws_s3_bucket.feedback_data_bucket.id
}

output "entity_data_bucket" {
  value = aws_s3_bucket.entity_data_bucket.id
}

output "image_data_bucket" {
  value = aws_s3_bucket.image_data_bucket.id
}

output "query_greenlist_bucket" {
  value = aws_s3_bucket.query_greenlist_bucket.id
}

output "query_metadata_bucket" {
  value = aws_s3_bucket.query_metadata_bucket.id
}

output "query_secrets_bucket_arn" {
  value = aws_s3_bucket.query_secrets_bucket.arn
}

output "entity_data_bucket_arn" {
  value = aws_s3_bucket.entity_data_bucket.arn
}

output "image_data_bucket_arn" {
  value = aws_s3_bucket.image_data_bucket.arn
}

output "feedback_data_bucket_arn" {
  value = aws_s3_bucket.feedback_data_bucket.arn
}

output "query_greenlist_bucket_arn" {
  value = aws_s3_bucket.query_greenlist_bucket.arn
}

output "query_metadata_bucket_arn" {
  value = aws_s3_bucket.query_metadata_bucket.arn
}

output "crawl_temp_bucket" {
  value = aws_s3_bucket.crawl_temp.id
}

output "gitlab_identity_bucket" {
  value = aws_s3_bucket.gitlab_identity_bucket.id
}

output "crawl_temp_bucket_arn" {
  value = aws_s3_bucket.crawl_temp.arn
}

output "gitlab_identity_bucket_arn" {
  value = aws_s3_bucket.gitlab_identity_bucket.arn
}

output "query_secrets_bucket_reader_policy_arn" {
  value = aws_iam_policy.query_secrets_bucket_reader.arn
}

output "query_metadata_bucket_reader_policy_arn" {
  value = aws_iam_policy.query_metadata_buckets_reader_policy.arn
}

output "elastic_snapshot_bucket_reader_policy_arn" {
  value = aws_iam_policy.elastic_snapshot_bucket_reader_policy.arn
}

output "elastic_snapshot_bucket_writer_policy_arn" {
  value = aws_iam_policy.elastic_snapshot_bucket_writer_policy.arn
}

output "activity_bucket_reader_policy_arn" {
  value = aws_iam_policy.scio_activity_bucket_reader_policy.arn
}

output "docs_dump_bucket" {
  value = aws_s3_bucket.docs_dump_bucket.id
}

output "docs_dump_bucket_arn" {
  value = aws_s3_bucket.docs_dump_bucket.arn
}

output "flink_bucket_access_policy_arn" {
  value = aws_iam_policy.flink_buckets_access_policy.arn
}

output "docs_dump_bucket_reader_policy_arn" {
  value = aws_iam_policy.docs_dump_bucket_reader_policy.arn
}

output "flink_python_additional_permissions_policy_arn" {
  value = aws_iam_policy.flink_python_additional_permissions_policy.arn
}

output "self_hosted_airflow_logs_bucket_arn" {
  value = aws_s3_bucket.self_hosted_airflow_logs_bucket.arn
}

output "csv_storage_bucket" {
  value = aws_s3_bucket.csv_storage_bucket.id
}

output "csv_storage_bucket_arn" {
  value = aws_s3_bucket.csv_storage_bucket.arn
}

output "ingress_logs_bucket" {
  value = aws_s3_bucket.ingress_logs_bucket.id
}

output "ingress_logs_bucket_arn" {
  value = aws_s3_bucket.ingress_logs_bucket.arn
}

output "general_query_metadata_bucket" {
  value = aws_s3_bucket.general_query_metadata_bucket.id
}

output "upgrade_operations_bucket" {
  value = aws_s3_bucket.upgrade_operations_bucket.id
}