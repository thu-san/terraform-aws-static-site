output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.static_site.bucket_id
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.static_site.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.static_site.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = module.static_site.cloudfront_distribution_arn
}

output "website_url" {
  description = "URL to access the website"
  value       = "https://${module.static_site.cloudfront_distribution_domain_name}"
}