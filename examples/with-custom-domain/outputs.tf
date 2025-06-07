output "s3_bucket_id" {
  description = "The name of the S3 bucket"
  value       = module.static_site.bucket_id
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.static_site.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.static_site.cloudfront_distribution_id
}

output "acm_certificate_domain_validation_options" {
  description = "Domain validation options - use these to create DNS records"
  value       = module.static_site.acm_certificate_domain_validation_options
}