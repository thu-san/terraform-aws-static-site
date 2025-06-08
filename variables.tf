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

# Cache Invalidation Variables
variable "enable_cache_invalidation" {
  description = "Enable automatic cache invalidation on S3 uploads"
  type        = bool
  default     = false
}

variable "invalidation_mode" {
  description = "Cache invalidation mode: 'direct' or 'custom'"
  type        = string
  default     = "direct"

  validation {
    condition     = contains(["direct", "custom"], var.invalidation_mode)
    error_message = "Invalidation mode must be 'direct' or 'custom'"
  }
}

variable "invalidation_path_mappings" {
  description = "Custom path mappings for cache invalidation (used when invalidation_mode is 'custom')"
  type = list(object({
    source_pattern     = string
    invalidation_paths = list(string)
    description        = optional(string)
  }))
  default = []
}

variable "invalidation_sqs_config" {
  description = "SQS configuration for batch processing"
  type = object({
    batch_window_seconds   = optional(number)
    batch_size             = optional(number)
    message_retention_days = optional(number)
    visibility_timeout     = optional(number)
  })
  default = {}
}

variable "invalidation_lambda_config" {
  description = "Lambda function configuration"
  type = object({
    memory_size          = optional(number)
    timeout              = optional(number)
    reserved_concurrency = optional(number)
    log_retention_days   = optional(number)
  })
  default = {}
}

variable "invalidation_dlq_arn" {
  description = "ARN of existing SQS queue to use as DLQ for failed invalidations"
  type        = string
  default     = ""
}
