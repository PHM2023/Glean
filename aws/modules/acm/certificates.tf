resource "aws_acm_certificate" "glean_ssl_cert" {
  domain_name       = "${var.subdomain_name}-be.glean.com"
  validation_method = "DNS"
}
