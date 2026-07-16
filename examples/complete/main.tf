# ---------------------------------------------------------------------------
# Provider block — CI-friendly skip flags + non-AWS-shaped placeholder creds.
# ---------------------------------------------------------------------------
provider "aws" {
  region                      = "ap-south-1"
  access_key                  = "not-a-real-aws-key"
  secret_key                  = "not-a-real-aws-secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# A private S3 static-site origin fronted by an Origin Access Control, served on
# a custom domain with a real ACM certificate, protected by a WAFv2 Web ACL, and
# writing access logs to a log bucket. The bucket stays fully private — only
# CloudFront (via the OAC output below) can read it.
module "cloudfront" {
  source = "../.."

  namespace = "dvtca"
  stage     = "prod"
  name      = "assets"

  # Private S3 origin — the module creates the OAC and wires it to the origin.
  origin_type        = "s3"
  origin_domain_name = "dvtca-prod-assets.s3.ap-south-1.amazonaws.com"

  # Serve on a custom domain. Aliases require a real ACM cert (us-east-1 for
  # CloudFront); the hardened TLSv1.2_2021 floor applies once it is attached.
  aliases                  = ["cdn.example.com"]
  acm_certificate_arn      = "arn:aws:acm:us-east-1:111122223333:certificate/00000000-0000-0000-0000-000000000000"
  minimum_protocol_version = "TLSv1.2_2021"

  # index.html is the default root object for an S3 origin.
  default_root_object = "index.html"
  price_class         = "PriceClass_200"

  # Attach the edge firewall (WAFv2 Web ACL, CLOUDFRONT scope).
  web_acl_id = "arn:aws:wafv2:us-east-1:111122223333:global/webacl/dvtca-prod-edge/00000000-0000-0000-0000-000000000000"

  # Only serve viewers in a set of countries.
  geo_restriction_type      = "whitelist"
  geo_restriction_locations = ["US", "CA", "GB", "IN"]

  # Access logging to a dedicated log bucket.
  logging_bucket      = "dvtca-prod-cloudfront-logs.s3.amazonaws.com"
  log_prefix          = "assets/"
  log_include_cookies = false

  tags = {
    Environment = "prod"
    Project     = "terraform-aws-cloudfront"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-cloudfront"
  }
}
