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

variable "hosted_zone_name" {
  description = "Route53 hosted zone name for creating DNS records (e.g., example.com)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "cache_policy_id" {
  description = "The ID of the CloudFront cache policy to use. Defaults to AWS managed 'CachingOptimized' policy when null."
  type        = string
  nullable    = true
  default     = null
}

variable "origin_request_policy_id" {
  description = "The ID of the CloudFront origin request policy to use. Set to null to use no origin request policy."
  type        = string
  nullable    = true
  default     = null
}

variable "response_headers_policy_id" {
  description = "The ID of the CloudFront response headers policy to use"
  type        = string
  default     = null
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

variable "cloudfront_function_associations" {
  description = "List of CloudFront function associations for the default cache behavior"
  type = list(object({
    event_type   = string # Must be one of: viewer-request, viewer-response
    function_arn = string # Full ARN of the CloudFront function
  }))
  default = []

  validation {
    condition = alltrue([
      for assoc in var.cloudfront_function_associations :
      contains(["viewer-request", "viewer-response"], assoc.event_type)
    ])
    error_message = "Event type must be either 'viewer-request' or 'viewer-response'."
  }
}

variable "default_root_object" {
  description = "The object that CloudFront returns when requests point to root URL"
  type        = string
  default     = "index.html"
}

variable "subfolder_root_object" {
  description = "When set, creates a CloudFront function to serve this file as the default object for subfolder requests (e.g., 'index.html'). Does not affect the root path, which uses default_root_object."
  type        = string
  default     = ""
}

variable "skip_certificate_validation" {
  description = "Skip ACM certificate DNS validation records (useful for testing)"
  type        = bool
  default     = false
}

variable "custom_error_responses" {
  description = <<-EOT
    List of custom error response configurations for CloudFront.
    
    Common patterns:
    - SPA routing: Set 403/404 errors to return 200 with /index.html
    - Custom error pages: Return specific HTML files for different errors
    - Maintenance mode: Configure 503 responses
  EOT
  type = list(object({
    error_code            = number
    response_code         = optional(number)
    response_page_path    = optional(string)
    error_caching_min_ttl = optional(number, 0)
  }))
  default = []

  validation {
    condition = alltrue([
      for response in var.custom_error_responses :
      response.error_code >= 400 && response.error_code <= 599
    ])
    error_message = "Error codes must be 4xx or 5xx status codes (400-599)."
  }
}
