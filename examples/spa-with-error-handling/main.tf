terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.32"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "spa_static_site" {
  source = "../../"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  s3_bucket_name               = "example-spa-bucket-${random_id.bucket_suffix.hex}"
  cloudfront_distribution_name = "example-spa-distribution"

  # Configure error responses for SPA client-side routing
  # This ensures that requests to non-existent paths return index.html
  # allowing the SPA's router to handle the route
  custom_error_responses = [
    {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    },
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]

  tags = {
    Environment = "development"
    Project     = "spa-example"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}