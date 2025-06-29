variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "pr-spa-preview"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for static site hosting"
  type        = string
}

variable "cloudfront_distribution_name" {
  description = "Name/comment for the CloudFront distribution"
  type        = string
}

variable "main_domain" {
  description = "Main domain for the site (e.g., dev.example.com). PR previews will use subdomains like pr123.dev.example.com"
  type        = string
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name for creating DNS records (e.g., example.com)"
  type        = string
}

variable "enable_cache_invalidation" {
  description = "Enable automatic cache invalidation on S3 uploads. Recommended for SPA deployments."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Purpose   = "pr-spa-preview"
  }
}