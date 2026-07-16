# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## 0.1.0 (2026-07-16)


### Features

* **ci:** add architecture-diagram workflow + renderer ([86933ab](https://github.com/devotica-labs/terraform-aws-cloudfront/commit/86933ab29600fcca55b36caf08e7bb3787bef043))
* initial release of terraform-aws-cloudfront ([44eaad8](https://github.com/devotica-labs/terraform-aws-cloudfront/commit/44eaad8a3c36a8c7e4625a3ff9027ac29dfdfd2a))


### Bug Fixes

* **ci:** drop dead pip/scripts dependabot entry; tflint clean ([00f62ba](https://github.com/devotica-labs/terraform-aws-cloudfront/commit/00f62baf52f677f46bb43f8cc08f6c8d2e6b9b6d))

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
