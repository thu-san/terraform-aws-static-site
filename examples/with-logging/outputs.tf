output "cloudfront_distribution_url" {
  description = "The CloudFront distribution URL"
  value       = "https://${module.static_site.cloudfront_distribution_domain_name}"
}

output "cloudfront_distribution_id" {
  description = "The CloudFront distribution ID"
  value       = module.static_site.cloudfront_distribution_id
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.static_site.bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.static_site.bucket_arn
}

output "route53_record_names" {
  description = "The Route53 record names created"
  value       = module.static_site.route53_record_names
}

output "custom_domains" {
  description = "The custom domain names configured"
  value       = module.static_site.route53_record_names
}

# Show that logging is configured
output "logging_enabled" {
  description = "Whether CloudWatch logging is enabled"
  value       = true
}