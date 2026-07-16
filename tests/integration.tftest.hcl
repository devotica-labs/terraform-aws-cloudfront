# Integration tests — apply + assert + destroy. Requires real AWS credentials.
# A single distribution over a custom origin with the CloudFront default
# certificate is cheap to create and destroys cleanly (retain_on_delete off).

provider "aws" {
  region = "ap-south-1"
}

variables {
  namespace          = "dvtca"
  stage              = "integ"
  name               = "cf"
  origin_type        = "custom"
  origin_domain_name = "example.com"
  price_class        = "PriceClass_100"

  tags = {
    Environment = "integration-test"
    Ephemeral   = "true"
  }
}

run "apply_and_assert" {
  command = apply

  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : d.arn]) != ""
    error_message = "Distribution must be created with an ARN."
  }
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : d.domain_name]) != ""
    error_message = "Distribution must expose a *.cloudfront.net domain name."
  }
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : d.default_cache_behavior[0].viewer_protocol_policy]) == "redirect-to-https"
    error_message = "viewer_protocol_policy must apply as redirect-to-https against the real API."
  }
}
