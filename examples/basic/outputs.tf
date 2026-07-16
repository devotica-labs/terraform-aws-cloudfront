output "distribution_id" {
  description = "The CloudFront distribution id."
  value       = module.cloudfront.distribution_id
}

output "domain_name" {
  description = "The distribution domain name (*.cloudfront.net)."
  value       = module.cloudfront.domain_name
}
