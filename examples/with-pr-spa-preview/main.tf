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

# CloudFront function for PR routing with SPA support
resource "aws_cloudfront_function" "pr_spa_router" {
  name    = "${var.project_name}-pr-spa-router"
  runtime = "cloudfront-js-2.0"
  comment = "Routes PR subdomain requests to S3 subfolders with SPA support"
  publish = true

  code = <<-EOT
    function handler(event) {
      var request = event.request;
      var host = request.headers.host.value;
      var uri = request.uri;
      
      // Extract PR number from subdomain (e.g., pr123.dev.example.com)
      var prMatch = host.match(/^pr(\d+)\./);
      var prefix = '';
      
      if (prMatch) {
        var prNumber = prMatch[1];
        prefix = '/pr' + prNumber;
      }
      
      // Extract filename from the URI path
      var segments = uri.split('/');
      var filename = segments[segments.length - 1];
      
      // If filename contains a dot, treat it as a static file
      // This covers all file types without maintaining a list
      var isFile = filename.indexOf('.') !== -1;
      
      // Alternative: To restrict to specific extensions only, uncomment below:
      // var allowedExtensions = /\.(css|js|json|png|jpg|jpeg|gif|svg|ico|woff|woff2|ttf)$/i;
      // var isFile = allowedExtensions.test(filename);
      
      // Handle the root path
      if (uri === '/' || uri === prefix + '/') {
        request.uri = prefix + '/index.html';
        return request;
      }
      
      // If no file extension (likely a SPA route), serve index.html
      if (!isFile || filename === '') {
        request.uri = prefix + '/index.html';
      } else if (prMatch && !uri.startsWith(prefix)) {
        // For PR subdomains with static files, prepend the PR folder
        request.uri = prefix + uri;
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

  # Custom error responses for complete SPA support
  # This handles cases where static files are missing or access is denied
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

  # Attach CloudFront function for PR routing with SPA support
  cloudfront_function_associations = [{
    event_type   = "viewer-request"
    function_arn = aws_cloudfront_function.pr_spa_router.arn
  }]

  # Enable cache invalidation for automatic updates
  enable_cache_invalidation = var.enable_cache_invalidation

  # Configure cache invalidation for SPA deployments
  invalidation_mode = var.enable_cache_invalidation ? "custom" : "direct"
  invalidation_path_mappings = var.enable_cache_invalidation ? [
    {
      source_pattern     = "^pr\\d+/.*"
      invalidation_paths = ["/*"]
      description        = "Invalidate all paths when PR content changes"
    },
    {
      source_pattern     = "^(?!pr\\d+/).*"
      invalidation_paths = ["/*"]
      description        = "Invalidate all paths when main content changes"
    }
  ] : []

  tags = merge(
    var.tags,
    {
      Example    = "pr-spa-preview"
      SPAEnabled = "true"
    }
  )

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}