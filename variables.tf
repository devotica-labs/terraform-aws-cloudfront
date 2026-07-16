# ---------------------------------------------------------------------------
# Origin (single origin — a custom origin such as an ALB, or an S3 bucket via
# Origin Access Control)
# ---------------------------------------------------------------------------
variable "origin_type" {
  type        = string
  description = "Origin kind: \"custom\" (an HTTP origin such as an ALB or API domain) or \"s3\" (a private S3 bucket fronted by an Origin Access Control)."
  default     = "custom"

  validation {
    condition     = contains(["custom", "s3"], var.origin_type)
    error_message = "origin_type must be \"custom\" or \"s3\"."
  }
}

variable "origin_domain_name" {
  type        = string
  description = "The origin's domain name. For origin_type=custom, the ALB/API DNS name (e.g. my-alb-123.ap-south-1.elb.amazonaws.com). For origin_type=s3, the bucket regional domain name (e.g. my-bucket.s3.ap-south-1.amazonaws.com)."

  validation {
    condition     = length(var.origin_domain_name) > 0
    error_message = "origin_domain_name is required and must be non-empty."
  }
}

variable "origin_path" {
  type        = string
  description = "Optional path CloudFront appends to origin requests (e.g. \"/static\"). Empty string means the origin root."
  default     = ""
}

variable "custom_headers" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Custom headers CloudFront adds to every origin request — e.g. a shared secret an ALB checks to ensure traffic arrived via CloudFront."
  default     = []
}

# ── Custom-origin connection settings (origin_type=custom only) ──────────────
variable "origin_protocol_policy" {
  type        = string
  description = "How CloudFront connects to a custom origin: https-only (recommended), http-only, or match-viewer."
  default     = "https-only"

  validation {
    condition     = contains(["http-only", "https-only", "match-viewer"], var.origin_protocol_policy)
    error_message = "origin_protocol_policy must be one of: http-only, https-only, match-viewer."
  }
}

variable "origin_ssl_protocols" {
  type        = list(string)
  description = "SSL/TLS protocols CloudFront uses when connecting to a custom origin over HTTPS."
  default     = ["TLSv1.2"]
}

variable "origin_http_port" {
  type        = number
  description = "HTTP port CloudFront uses to reach a custom origin."
  default     = 80
}

variable "origin_https_port" {
  type        = number
  description = "HTTPS port CloudFront uses to reach a custom origin."
  default     = 443
}

variable "origin_keepalive_timeout" {
  type        = number
  description = "Keep-alive timeout (seconds) for connections to a custom origin."
  default     = 5
}

variable "origin_read_timeout" {
  type        = number
  description = "Read (response) timeout (seconds) for a custom origin."
  default     = 30
}

# ---------------------------------------------------------------------------
# Viewer certificate / aliases / TLS
# ---------------------------------------------------------------------------
variable "aliases" {
  type        = list(string)
  description = "Alternate domain names (CNAMEs) served by the distribution, e.g. [\"cdn.example.com\"]. Requires acm_certificate_arn — the CloudFront default certificate only serves *.cloudfront.net."
  default     = []
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of an ACM certificate in us-east-1 for the aliases. Null (default) uses the CloudFront default certificate (*.cloudfront.net only). Required when aliases are set."
  default     = null

  validation {
    condition     = var.acm_certificate_arn == null || can(regex("^arn:aws[a-z-]*:acm:", var.acm_certificate_arn))
    error_message = "acm_certificate_arn must be an ACM ARN (arn:aws*:acm:...) or null."
  }
}

variable "minimum_protocol_version" {
  type        = string
  description = "Minimum TLS version viewers may use. Applies only with a custom ACM certificate; the CloudFront default certificate forces TLSv1. Fintech default TLSv1.2_2021."
  default     = "TLSv1.2_2021"

  validation {
    condition     = contains(["TLSv1", "TLSv1_2016", "TLSv1.1_2016", "TLSv1.2_2018", "TLSv1.2_2019", "TLSv1.2_2021"], var.minimum_protocol_version)
    error_message = "minimum_protocol_version must be a valid CloudFront security policy (e.g. TLSv1.2_2021)."
  }
}

# ---------------------------------------------------------------------------
# Default cache behavior
# ---------------------------------------------------------------------------
variable "viewer_protocol_policy" {
  type        = string
  description = "Protocol policy for viewers on the default cache behavior. Fintech default redirect-to-https."
  default     = "redirect-to-https"

  validation {
    condition     = contains(["allow-all", "https-only", "redirect-to-https"], var.viewer_protocol_policy)
    error_message = "viewer_protocol_policy must be one of: allow-all, https-only, redirect-to-https."
  }
}

variable "allowed_methods" {
  type        = list(string)
  description = "HTTP methods CloudFront processes and forwards to the origin on the default behavior."
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  type        = list(string)
  description = "HTTP methods for which CloudFront caches responses on the default behavior."
  default     = ["GET", "HEAD"]
}

variable "compress" {
  type        = bool
  description = "Automatically compress objects for viewers that support it."
  default     = true
}

variable "cache_policy_id" {
  type        = string
  description = "Managed or custom cache policy ID for the default behavior. Defaults to the AWS managed CachingOptimized policy."
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

variable "origin_request_policy_id" {
  type        = string
  description = "Optional origin request policy ID for the default behavior."
  default     = null
}

variable "response_headers_policy_id" {
  type        = string
  description = "Optional response headers policy ID for the default behavior (e.g. a security-headers policy)."
  default     = null
}

# ---------------------------------------------------------------------------
# Distribution
# ---------------------------------------------------------------------------
variable "distribution_enabled" {
  type        = bool
  description = "Whether the distribution accepts and serves end-user requests."
  default     = true
}

variable "comment" {
  type        = string
  description = "Comment describing the distribution (shown in the console)."
  default     = null
}

variable "default_root_object" {
  type        = string
  description = "Object CloudFront returns for a request to the root URL (e.g. \"index.html\"). Null defaults to \"index.html\" for origin_type=s3 and to none for custom origins."
  default     = null
}

variable "price_class" {
  type        = string
  description = "Edge-location price class. Fintech default PriceClass_100 (North America + Europe)."
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "price_class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
}

variable "is_ipv6_enabled" {
  type        = bool
  description = "Enable IPv6 for the distribution."
  default     = true
}

variable "http_version" {
  type        = string
  description = "Maximum HTTP version viewers may negotiate."
  default     = "http2and3"

  validation {
    condition     = contains(["http1.1", "http2", "http2and3", "http3"], var.http_version)
    error_message = "http_version must be one of: http1.1, http2, http2and3, http3."
  }
}

variable "web_acl_id" {
  type        = string
  description = "ARN of a WAFv2 Web ACL (CLOUDFRONT scope) to associate. Null (default) attaches no firewall — pass the ARN from terraform-aws-wafv2."
  default     = null
}

variable "retain_on_delete" {
  type        = bool
  description = "Disable rather than delete the distribution on destroy. Fintech default false so teardown is clean."
  default     = false
}

# ---------------------------------------------------------------------------
# Geo restriction
# ---------------------------------------------------------------------------
variable "geo_restriction_type" {
  type        = string
  description = "Geo restriction mode: none, whitelist, or blacklist."
  default     = "none"

  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.geo_restriction_type)
    error_message = "geo_restriction_type must be one of: none, whitelist, blacklist."
  }
}

variable "geo_restriction_locations" {
  type        = list(string)
  description = "ISO 3166-1-alpha-2 country codes for the whitelist/blacklist. Ignored when geo_restriction_type=none."
  default     = []
}

# ---------------------------------------------------------------------------
# Access logging (optional)
# ---------------------------------------------------------------------------
variable "logging_bucket" {
  type        = string
  description = "S3 bucket domain name for access logs (e.g. my-logs.s3.amazonaws.com). Null (default) disables access logging."
  default     = null
}

variable "log_prefix" {
  type        = string
  description = "Key prefix for access-log objects in logging_bucket."
  default     = ""
}

variable "log_include_cookies" {
  type        = bool
  description = "Include cookies in access logs."
  default     = false
}
