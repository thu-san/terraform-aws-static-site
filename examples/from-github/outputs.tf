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