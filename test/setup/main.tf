# Test setup module for provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Mock provider configuration for testing
provider "aws" {
  region = "us-east-1"

  # Use mock endpoints for testing without real AWS credentials
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Mock endpoints for testing
  endpoints {
    s3             = "http://localhost:4566"
    cloudfront     = "http://localhost:4566"
    acm            = "http://localhost:4566"
    route53        = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3             = "http://localhost:4566"
    cloudfront     = "http://localhost:4566"
    acm            = "http://localhost:4566"
    route53        = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
  }
}