# Contract tests — the fintech defaults that callers depend on stay stable
# across versions: TLS 1.2 floor, price class, and single-origin cardinality.

mock_provider "aws" {}

variables {
  namespace           = "dvtca"
  stage               = "test"
  name                = "contract"
  origin_type         = "s3"
  origin_domain_name  = "dvtca-test-contract.s3.ap-south-1.amazonaws.com"
  aliases             = ["cdn.example.com"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:111122223333:certificate/00000000-0000-0000-0000-000000000000"
}

run "tls_1_2_2021_is_the_default_floor" {
  command = plan
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : d.viewer_certificate[0].minimum_protocol_version]) == "TLSv1.2_2021"
    error_message = "The minimum TLS version floor must remain TLSv1.2_2021."
  }
}

run "price_class_default_is_100" {
  command = plan
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : d.price_class]) == "PriceClass_100"
    error_message = "price_class default must remain PriceClass_100."
  }
}

run "single_origin_and_default_behavior" {
  command = plan
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : length(d.origin)]) == 1
    error_message = "The distribution must front exactly one origin."
  }
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : length(d.default_cache_behavior)]) == 1
    error_message = "The distribution must have exactly one default cache behavior."
  }
}

run "origin_id_matches_target_origin_id" {
  command = plan
  assert {
    condition     = one([for d in aws_cloudfront_distribution.this : d.default_cache_behavior[0].target_origin_id]) == "dvtca-test-contract"
    error_message = "The default cache behavior must target the single origin composed from the label id."
  }
}
