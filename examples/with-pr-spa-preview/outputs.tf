output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.static_site.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
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

output "main_site_url" {
  description = "URL for the main site"
  value       = "https://${var.main_domain}"
}

output "pr_preview_url_pattern" {
  description = "URL pattern for PR previews"
  value       = "https://pr{NUMBER}.${var.main_domain}"
}

output "cloudfront_function_name" {
  description = "Name of the CloudFront function handling SPA routing"
  value       = aws_cloudfront_function.pr_spa_router.name
}

output "cloudfront_function_arn" {
  description = "ARN of the CloudFront function"
  value       = aws_cloudfront_function.pr_spa_router.arn
}

output "deployment_instructions" {
  description = "Instructions for deploying PR previews"
  value       = <<-EOT
    To deploy PR previews:
    
    1. Main branch (${var.main_domain}):
       aws s3 sync ./dist s3://${module.static_site.bucket_id}/ --delete
    
    2. PR preview (e.g., PR #123):
       aws s3 sync ./dist s3://${module.static_site.bucket_id}/pr123/ --delete
       Access at: https://pr123.${var.main_domain}
    
    Note: Each PR folder should contain a complete SPA build including index.html
  EOT
}