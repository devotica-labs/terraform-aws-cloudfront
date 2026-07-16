output "distribution_id" {
  description = "The CloudFront distribution id."
  value       = module.cloudfront.distribution_id
}

output "distribution_arn" {
  description = "The CloudFront distribution ARN."
  value       = module.cloudfront.distribution_arn
}

output "domain_name" {
  description = "The distribution domain name — the DNS target for the alias records."
  value       = module.cloudfront.domain_name
}

output "hosted_zone_id" {
  description = "CloudFront's Route 53 hosted zone id, for alias (A/AAAA) records."
  value       = module.cloudfront.hosted_zone_id
}

output "oac_id" {
  description = "The Origin Access Control id to reference in the S3 bucket policy."
  value       = module.cloudfront.oac_id
}
