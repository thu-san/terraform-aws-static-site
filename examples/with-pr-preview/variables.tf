variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "example-pr-preview"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "cloudfront_distribution_name" {
  description = "Name/comment for the CloudFront distribution"
  type        = string
}

variable "main_domain" {
  description = "Main domain for the site (e.g., dev.example.com)"
  type        = string
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name (e.g., example.com)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Static Site with PR Preview"
    Environment = "development"
  }
}