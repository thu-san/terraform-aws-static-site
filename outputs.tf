output "bucket_id" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.id
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.arn
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "cloudfront_oac_id" {
  description = "The ID of the CloudFront Origin Access Control"
  value       = aws_cloudfront_origin_access_control.this.id
}

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = local.create_certificate ? aws_acm_certificate.this[0].arn : null
}

output "acm_certificate_domain_validation_options" {
  description = "Domain validation options for the ACM certificate"
  value       = local.create_certificate ? aws_acm_certificate.this[0].domain_validation_options : []
}

output "route53_record_names" {
  description = "The names of the Route53 A records created"
  value       = local.create_route53_records ? [for r in aws_route53_record.this : r.name] : []
}

output "route53_record_fqdns" {
  description = "The FQDNs of the Route53 A records created"
  value       = local.create_route53_records ? [for r in aws_route53_record.this : r.fqdn] : []
}

# Cache Invalidation Outputs
output "lambda_function_arn" {
  description = "ARN of the cache invalidation Lambda function"
  value       = var.enable_cache_invalidation ? aws_lambda_function.invalidation[0].arn : null
}

output "lambda_log_group_arn" {
  description = "ARN of the Lambda CloudWatch Log Group for monitoring"
  value       = var.enable_cache_invalidation ? aws_cloudwatch_log_group.invalidation_lambda[0].arn : null
}

output "sqs_queue_url" {
  description = "URL of the SQS queue for cache invalidation"
  value       = var.enable_cache_invalidation ? aws_sqs_queue.invalidation_queue[0].url : null
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue for cache invalidation"
  value       = var.enable_cache_invalidation ? aws_sqs_queue.invalidation_queue[0].arn : null
}

# Subfolder Root Object Function Output
output "subfolder_root_object_function_arn" {
  description = "ARN of the auto-created CloudFront function for subfolder root object handling"
  value       = local.create_subfolder_function ? aws_cloudfront_function.subfolder_root_object[0].arn : null
}
