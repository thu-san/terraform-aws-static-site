output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.static_site.cloudfront_distribution_id
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.static_site.cloudfront_distribution_domain_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.static_site.bucket_id
}

output "subfolder_root_object_function_arn" {
  description = "ARN of the auto-created CloudFront function"
  value       = module.static_site.subfolder_root_object_function_arn
}