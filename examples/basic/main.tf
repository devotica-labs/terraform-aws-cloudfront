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

# Uses local path during development.
# Change to Registry source after first release:
#   source  = "devotica-labs/cloudfront/aws"
#   version = "~> 0.1"

module "cloudfront" {
  source = "../.."

  # Distribution id composes to: dvtca-sandbox-web
  namespace = "dvtca"
  stage     = "sandbox"
  name      = "web"

  # A custom origin — e.g. a public ALB. CloudFront talks to it over HTTPS.
  origin_type        = "custom"
  origin_domain_name = "dvtca-sandbox-alb-123456789.ap-south-1.elb.amazonaws.com"

  # Fintech defaults cover the rest: viewers are redirected to HTTPS,
  # PriceClass_100, IPv6 on, and the CloudFront default certificate (no aliases).

  tags = {
    Environment = "sandbox"
    Project     = "terraform-aws-cloudfront"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-cloudfront"
  }
}
