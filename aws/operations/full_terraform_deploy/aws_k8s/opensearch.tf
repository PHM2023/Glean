
resource "kubernetes_secret" "opensearch_snapshot_web_identity_token_file_secret_1" {
  metadata {
    name      = local.opensearch_s3_secret_name
    namespace = var.opensearch_1_namespace
  }

  data = local.opensearch_snapshot_secret_data
}

resource "kubernetes_secret" "opensearch_snapshot_web_identity_token_file_secret_2" {
  metadata {
    name      = local.opensearch_s3_secret_name
    namespace = var.opensearch_2_namespace
  }

  data = local.opensearch_snapshot_secret_data
}
