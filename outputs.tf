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
