variable "s3_bucket_name" {
  description = "Name of the S3 bucket for static site hosting"
  type        = string
}

variable "cloudfront_distribution_name" {
  description = "Name/comment for the CloudFront distribution"
  type        = string
}

variable "domain_names" {
  description = "List of domain names for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "log_delivery_destination_arn" {
  description = "ARN of the CloudWatch log delivery destination"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for creating DNS records"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "s3_delivery_configuration" {
  description = "S3 delivery configuration for CloudWatch logs"
  type = list(object({
    suffix_path                 = string
    enable_hive_compatible_path = bool
  }))
  default = [
    {
      suffix_path                 = "/{account-id}/{DistributionId}/{yyyy}/{MM}/{dd}/{HH}"
      enable_hive_compatible_path = false
    }
  ]
}

variable "log_record_fields" {
  description = "List of CloudWatch log record fields to include in log delivery. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/standard-logs-reference.html#BasicDistributionFileFormat"
  type        = list(string)
  default     = []
}
