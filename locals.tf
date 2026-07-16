locals {
  # A single origin; its id doubles as the default cache behavior target.
  origin_id = local.id

  # OAC is only meaningful for a private S3 origin.
  create_oac = local.enabled && var.origin_type == "s3"

  # index.html is the sensible root object for an S3 static site; a custom
  # (ALB/API) origin usually routes "/" itself, so leave it unset there.
  default_root_object = var.default_root_object != null ? var.default_root_object : (
    var.origin_type == "s3" ? "index.html" : null
  )

  # The CloudFront default certificate (*.cloudfront.net) forces TLSv1 and
  # cannot serve custom aliases; a real ACM cert unlocks the hardened floor.
  use_default_certificate = var.acm_certificate_arn == null
}
