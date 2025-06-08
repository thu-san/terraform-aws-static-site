# Outputs for Direct Mode Example
output "direct_mode_bucket_name" {
  description = "S3 bucket name for direct mode example"
  value       = module.static_site_direct.bucket_id
}

output "direct_mode_cloudfront_domain" {
  description = "CloudFront domain for direct mode example"
  value       = module.static_site_direct.cloudfront_distribution_domain_name
}

output "direct_mode_lambda_log_group" {
  description = "CloudWatch Log Group for monitoring direct mode Lambda"
  value       = module.static_site_direct.lambda_log_group_arn
}

# Outputs for Custom Mode Example
output "custom_mode_bucket_name" {
  description = "S3 bucket name for custom mode example"
  value       = module.static_site_custom.bucket_id
}

output "custom_mode_cloudfront_domain" {
  description = "CloudFront domain for custom mode example"
  value       = module.static_site_custom.cloudfront_distribution_domain_name
}

output "custom_mode_sqs_queue_url" {
  description = "SQS queue URL for custom mode example"
  value       = module.static_site_custom.sqs_queue_url
}

# Outputs for DLQ Example
output "dlq_example_bucket_name" {
  description = "S3 bucket name for DLQ example"
  value       = module.static_site_with_dlq.bucket_id
}

output "dlq_example_lambda_function" {
  description = "Lambda function ARN for DLQ example"
  value       = module.static_site_with_dlq.lambda_function_arn
}

output "dlq_url" {
  description = "Dead Letter Queue URL for monitoring failed invalidations"
  value       = aws_sqs_queue.invalidation_dlq.url
}