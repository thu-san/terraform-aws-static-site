terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# CloudFront function for PR routing
resource "aws_cloudfront_function" "pr_router" {
  name    = "${var.project_name}-pr-router"
  runtime = "cloudfront-js-2.0"
  comment = "Routes PR subdomain requests to S3 subfolders"
  publish = true

  code = <<-EOT
    function handler(event) {
      var request = event.request;
      var host = request.headers.host.value;
      
      // Extract PR number from subdomain (e.g., pr123.dev.example.com)
      var prMatch = host.match(/^pr(\d+)\./);
      
      if (prMatch) {
        var prNumber = prMatch[1];
        // Prepend PR folder to the URI
        request.uri = '/pr' + prNumber + request.uri;
      }
      
      // If URI ends with '/', append 'index.html'
      if (request.uri.endsWith('/')) {
        request.uri += 'index.html';
      }
      
      return request;
    }
  EOT
}

module "static_site" {
  source = "../.."

  s3_bucket_name               = var.s3_bucket_name
  cloudfront_distribution_name = var.cloudfront_distribution_name

  # Multiple domains including wildcard for PR previews
  domain_names = [
    var.main_domain,
    "*.${var.main_domain}"
  ]

  hosted_zone_name = var.hosted_zone_name

  # Attach CloudFront function for PR routing
  cloudfront_function_associations = [{
    event_type   = "viewer-request"
    function_arn = aws_cloudfront_function.pr_router.arn
  }]

  # Enable cache invalidation for automatic updates
  enable_cache_invalidation = true

  tags = var.tags

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}