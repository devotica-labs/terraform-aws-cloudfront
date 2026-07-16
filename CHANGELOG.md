# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## [Unreleased]

### Added

- Initial release: a single Amazon CloudFront distribution fronting one origin —
  a custom origin (ALB / API domain) or a private S3 bucket via an Origin Access
  Control (`sigv4`, created only when `origin_type = "s3"`) — with fintech-safe
  defaults: `redirect-to-https` viewers, a `TLSv1.2_2021` TLS floor (with a real
  ACM certificate), WAFv2 Web ACL passthrough (`web_acl_id`), `PriceClass_100`,
  optional access logging, geo restriction, and clean teardown
  (`retain_on_delete` off). Aliases require an ACM certificate (enforced at
  plan). Native `label.tf` naming; derived from `cloudposse/terraform-aws-cloudfront-cdn`.
