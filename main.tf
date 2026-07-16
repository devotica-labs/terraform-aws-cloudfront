# Origin Access Control — created only for a private S3 origin. OAC (sigv4)
# supersedes the legacy Origin Access Identity: CloudFront signs every origin
# request so the bucket can stay fully private (no public policy).
resource "aws_cloudfront_origin_access_control" "this" {
  count = local.create_oac ? 1 : 0

  name                              = "${local.id}-oac"
  description                       = "OAC for ${local.id} CloudFront distribution"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# A single CloudFront distribution fronting one origin with one default cache
# behavior. Fintech defaults: redirect-to-https for viewers, TLSv1.2_2021 floor
# (with a real ACM cert), WAF passthrough, and clean teardown (retain_on_delete
# off). WAF is configured via var.web_acl_id.
resource "aws_cloudfront_distribution" "this" {
  count = local.enabled ? 1 : 0

  enabled             = var.distribution_enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  http_version        = var.http_version
  comment             = var.comment
  default_root_object = local.default_root_object
  price_class         = var.price_class
  aliases             = var.aliases
  web_acl_id          = var.web_acl_id
  retain_on_delete    = var.retain_on_delete

  origin {
    domain_name              = var.origin_domain_name
    origin_id                = local.origin_id
    origin_path              = var.origin_path
    origin_access_control_id = local.create_oac ? aws_cloudfront_origin_access_control.this[0].id : null

    dynamic "custom_origin_config" {
      for_each = var.origin_type == "custom" ? [1] : []
      content {
        http_port                = var.origin_http_port
        https_port               = var.origin_https_port
        origin_protocol_policy   = var.origin_protocol_policy
        origin_ssl_protocols     = var.origin_ssl_protocols
        origin_keepalive_timeout = var.origin_keepalive_timeout
        origin_read_timeout      = var.origin_read_timeout
      }
    }

    dynamic "custom_header" {
      for_each = var.custom_headers
      content {
        name  = custom_header.value.name
        value = custom_header.value.value
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = var.viewer_protocol_policy
    allowed_methods        = var.allowed_methods
    cached_methods         = var.cached_methods
    compress               = var.compress

    cache_policy_id            = var.cache_policy_id
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id
  }

  viewer_certificate {
    cloudfront_default_certificate = local.use_default_certificate
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = local.use_default_certificate ? null : "sni-only"
    # AWS forces TLSv1 for the default certificate; the hardened floor only
    # applies once a real ACM certificate is attached.
    minimum_protocol_version = local.use_default_certificate ? "TLSv1" : var.minimum_protocol_version
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  dynamic "logging_config" {
    for_each = var.logging_bucket != null ? [1] : []
    content {
      bucket          = var.logging_bucket
      prefix          = var.log_prefix
      include_cookies = var.log_include_cookies
    }
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = length(var.aliases) == 0 || var.acm_certificate_arn != null
      error_message = "acm_certificate_arn is required when aliases are set — the CloudFront default certificate only serves *.cloudfront.net."
    }
  }
}
