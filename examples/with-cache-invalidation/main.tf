# Example: Static Site with Cache Invalidation

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Configure the AWS Provider for us-east-1 (required for ACM)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Example 1: Direct mode - invalidate exact paths
module "static_site_direct" {
  source = "../.."

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  s3_bucket_name               = "my-site-with-direct-invalidation"
  cloudfront_distribution_name = "my-site-direct"

  # Enable cache invalidation
  enable_cache_invalidation = true
  invalidation_mode         = "direct"

  # Optional: Configure SQS and Lambda settings
  invalidation_sqs_config = {
    batch_window_seconds   = 30 # Collect events for 30 seconds
    batch_size             = 50 # Process up to 50 files at once
    message_retention_days = 4
    visibility_timeout     = 300
  }

  invalidation_lambda_config = {
    memory_size          = 256 # Reduce memory for cost savings
    timeout              = 60  # 1 minute timeout
    reserved_concurrency = 3   # Limit concurrent executions
  }

  tags = {
    Environment = "production"
    Project     = "static-site-demo"
  }
}

# Example 2: Custom mode with path mappings
module "static_site_custom" {
  source = "../.."

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  s3_bucket_name               = "my-site-with-custom-invalidation"
  cloudfront_distribution_name = "my-site-custom"
  domain_names                 = ["custom-invalidation.example.com"]

  # Enable cache invalidation with custom mappings
  enable_cache_invalidation = true
  invalidation_mode         = "custom"

  # Define custom path mappings
  invalidation_path_mappings = [
    {
      source_pattern     = "^images/.*"
      invalidation_paths = ["/images/*"]
      description        = "Invalidate all images when any image is uploaded"
    },
    {
      source_pattern     = "^css/.*\\.css$"
      invalidation_paths = ["/css/*", "/*"]
      description        = "CSS changes invalidate CSS folder and homepage"
    },
    {
      source_pattern     = "^js/.*\\.js$"
      invalidation_paths = ["/js/*"]
      description        = "JavaScript changes invalidate JS folder"
    },
    {
      source_pattern     = "^(index\\.html|home\\.html)$"
      invalidation_paths = ["/*", "/index.html", "/home.html"]
      description        = "Homepage changes invalidate root paths"
    },
    {
      source_pattern     = "^api/.*\\.json$"
      invalidation_paths = ["/api/*"]
      description        = "API data changes invalidate API paths"
    }
  ]

  # Optimize for high-volume uploads
  invalidation_sqs_config = {
    batch_window_seconds   = 60  # Wait 1 minute to collect more events
    batch_size             = 100 # Process up to 100 files at once
    message_retention_days = 7   # Keep messages longer
    visibility_timeout     = 600 # 10 minute processing window
  }

  tags = {
    Environment = "production"
    Project     = "api-docs-site"
  }
}

# Example 3: With Dead Letter Queue
resource "aws_sqs_queue" "invalidation_dlq" {
  name                      = "cache-invalidation-dlq"
  message_retention_seconds = 14 * 24 * 60 * 60 # 14 days
}

module "static_site_with_dlq" {
  source = "../.."

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  s3_bucket_name               = "my-site-with-dlq"
  cloudfront_distribution_name = "my-site-dlq"

  enable_cache_invalidation = true
  invalidation_mode         = "direct"

  # Specify DLQ for failed invalidations
  invalidation_dlq_arn = aws_sqs_queue.invalidation_dlq.arn

  # Lambda configuration
  invalidation_lambda_config = {
    memory_size          = 512
    timeout              = 300
    reserved_concurrency = 5
  }

  tags = {
    Environment = "production"
    Project     = "critical-site"
  }
}
