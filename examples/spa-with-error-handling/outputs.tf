output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.spa_static_site.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.spa_static_site.cloudfront_distribution_id
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.spa_static_site.bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.spa_static_site.bucket_arn
}

output "cloudfront_url" {
  description = "The full URL to access the SPA"
  value       = "https://${module.spa_static_site.cloudfront_distribution_domain_name}"
}