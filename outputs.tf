output "distribution_id" {
  description = "The identifier of the CloudFront distribution."
  value       = try(aws_cloudfront_distribution.this[0].id, null)
}

output "distribution_arn" {
  description = "The ARN of the CloudFront distribution."
  value       = try(aws_cloudfront_distribution.this[0].arn, null)
}

output "domain_name" {
  description = "The distribution domain name (e.g. d111111abcdef8.cloudfront.net) — the DNS target for your alias records."
  value       = try(aws_cloudfront_distribution.this[0].domain_name, null)
}

output "hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID, used when creating an alias (A/AAAA) record pointing at the distribution."
  value       = try(aws_cloudfront_distribution.this[0].hosted_zone_id, null)
}

output "oac_id" {
  description = "The Origin Access Control ID (null unless origin_type=s3) — attach it in the bucket policy's SourceArn condition."
  value       = try(aws_cloudfront_origin_access_control.this[0].id, null)
}
