### THIS MODULE CONTAINS ANY K8s RESOURCES THAT SHOULD ONLY RUN IN AWS ###

module "ssl_cert_mapping_ipjc_update" {
  source            = "../../../../k8s/config_update"
  general_info      = local.config_update_general_info
  ipjc_channel_path = "/aws/dns/cert_mapping"
  ipjc_request_body = var.unvalidated_ssl_cert_arn
  path              = "ipjc_update"
  update_name       = "ssl-cert-dns-update"
  depends_on        = [var.initialize_config_job_id]
}

resource "aws_acm_certificate_validation" "acm_cert_validation" {
  certificate_arn = var.unvalidated_ssl_cert_arn
  # Only waits for validation after we've sent the ipjc request to scio-apps to trigger the mapping
  depends_on = [module.ssl_cert_mapping_ipjc_update]
}

# Tells scio-apps to update the DNS mapping for this deployment's backend to the loadbalancer dns name
module "external_lb_dns_ipjc_update" {
  source            = "../../../../k8s/config_update"
  general_info      = local.config_update_general_info
  path              = "ipjc_update"
  update_name       = "external-lb-ipjc-update"
  ipjc_channel_path = "/aws/dns/lb_mapping"
  ipjc_request_body = "<none>"
  # Note we don't actually need to send the value, scio-apps can already read it. We have to add this depends_on so we
  # only tell scio-apps to look for the lb after it has been created
  depends_on = [var.external_ingress_lb_host_name]
}