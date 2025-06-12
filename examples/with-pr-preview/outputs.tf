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

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.static_site.bucket_arn
}

output "route53_record_names" {
  description = "Names of created Route53 records"
  value       = module.static_site.route53_record_names
}

output "cloudfront_function_arn" {
  description = "ARN of the CloudFront function for PR routing"
  value       = aws_cloudfront_function.pr_router.arn
}