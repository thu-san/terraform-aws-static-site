variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for hosting the static site"
  type        = string
  default     = "nextjs-spa-example-bucket"
}