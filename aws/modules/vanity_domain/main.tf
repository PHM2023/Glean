data "aws_cloudfront_cache_policy" "cfd_cache_policy" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "cfd_origin_request_policy" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "vanity_url_cfd" {
  enabled = true
  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "app.glean.com"
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.cfd_cache_policy.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.cfd_origin_request_policy.id
  }
  origin {
    domain_name = "app.glean.com"
    origin_id   = "app.glean.com"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = var.vanity_url_ssl_cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  is_ipv6_enabled = true
  aliases         = [var.vanity_url_domain]
  http_version    = "http2"
}