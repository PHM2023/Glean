output "validated_ssl_cert_arn" {
  value = aws_acm_certificate_validation.acm_cert_validation.certificate_arn
}

output "alb_controller_id" {
  value = helm_release.alb_helm_release.id
}

output "ebs_storage_class_name" {
  value = kubernetes_storage_class.ebs_csi_storage_class.metadata[0].name
}

output "opensearch_snapshot_secrets" {
  value = [
    kubernetes_secret.opensearch_snapshot_web_identity_token_file_secret_1.metadata[0].name,
    kubernetes_secret.opensearch_snapshot_web_identity_token_file_secret_2.metadata[0].name
  ]
}