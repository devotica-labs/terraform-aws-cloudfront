# Plan-only unit tests — no AWS credentials required. All assertions are on
# config-set values and resource cardinality (never provider-computed attrs).

mock_provider "aws" {}

variables {
  namespace          = "dvtca"
  stage              = "test"
  name               = "unit"
  origin_type        = "custom"
  origin_domain_name = "example-alb-123.ap-south-1.elb.amazonaws.com"
}

run "single_distribution_planned" {
  command = plan
  assert {
    condition     = length(aws_cloudfront_distribution.this) == 1
    error_message = "Exactly one CloudFront distribution must be planned."
  }
}

run "viewer_protocol_policy_redirect_to_https" {
  command = plan
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : d.default_cache_behavior[0].viewer_protocol_policy]) == "redirect-to-https"
    error_message = "viewer_protocol_policy must default to redirect-to-https."
  }
}

run "no_oac_for_custom_origin" {
  command = plan
  assert {
    condition     = length(aws_cloudfront_origin_access_control.this) == 0
    error_message = "No Origin Access Control must be created for a custom origin."
  }
}

run "oac_created_for_s3_origin" {
  command = plan
  variables {
    origin_type        = "s3"
    origin_domain_name = "dvtca-test-assets.s3.ap-south-1.amazonaws.com"
  }
  assert {
    condition     = length(aws_cloudfront_origin_access_control.this) == 1
    error_message = "An Origin Access Control must be created when origin_type=s3."
  }
  assert {
    condition     = one([for o in aws_cloudfront_origin_access_control.this : o.signing_protocol]) == "sigv4"
    error_message = "OAC must sign origin requests with sigv4."
  }
}

run "minimum_protocol_version_default_with_cert" {
  command = plan
  variables {
    aliases             = ["cdn.example.com"]
    acm_certificate_arn = "arn:aws:acm:us-east-1:111122223333:certificate/00000000-0000-0000-0000-000000000000"
  }
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : d.viewer_certificate[0].minimum_protocol_version]) == "TLSv1.2_2021"
    error_message = "minimum_protocol_version must default to TLSv1.2_2021 when a real ACM certificate is attached."
  }
}

run "default_certificate_without_aliases" {
  command = plan
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : d.viewer_certificate[0].cloudfront_default_certificate]) == true
    error_message = "With no ACM certificate the distribution must use the CloudFront default certificate."
  }
}

run "s3_default_root_object_is_index_html" {
  command = plan
  variables {
    origin_type        = "s3"
    origin_domain_name = "dvtca-test-assets.s3.ap-south-1.amazonaws.com"
  }
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : d.default_root_object]) == "index.html"
    error_message = "default_root_object must default to index.html for an S3 origin."
  }
}

run "web_acl_passthrough" {
  command = plan
  variables {
    web_acl_id = "arn:aws:wafv2:us-east-1:111122223333:global/webacl/edge/00000000-0000-0000-0000-000000000000"
  }
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : d.web_acl_id]) == "arn:aws:wafv2:us-east-1:111122223333:global/webacl/edge/00000000-0000-0000-0000-000000000000"
    error_message = "web_acl_id must pass through to the distribution."
  }
}

run "disabled_creates_nothing" {
  command = plan
  variables {
    enabled = false
  }
  assert {
    condition     = length(aws_cloudfront_distribution.this) == 0
    error_message = "enabled=false must create no distribution."
  }
  assert {
    condition     = length(aws_cloudfront_origin_access_control.this) == 0
    error_message = "enabled=false must create no OAC."
  }
}
