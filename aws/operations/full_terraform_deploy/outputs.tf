output "last_version_used" {
  value      = var.version_tag
  depends_on = [null_resource.version_check]
}
