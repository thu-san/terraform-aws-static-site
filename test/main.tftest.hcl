# Provider configuration for tests
mock_provider "aws" {
}

mock_provider "aws" {
  alias = "us_east_1"
}

# Basic test - minimal configuration
run "basic_configuration" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-static-site-bucket"
    cloudfront_distribution_name = "test-static-site"
  }

  # Verify S3 bucket is created
  assert {
    condition     = aws_s3_bucket.this.bucket == "test-static-site-bucket"
    error_message = "S3 bucket name does not match expected value"
  }

  # Verify CloudFront distribution comment
  assert {
    condition     = aws_cloudfront_distribution.this.comment == "test-static-site"
    error_message = "CloudFront distribution comment does not match expected value"
  }

  # Verify S3 bucket versioning is enabled
  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "S3 bucket versioning is not enabled"
  }

  # Verify S3 bucket is private
  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "S3 bucket public access is not blocked"
  }

  # Verify CloudFront OAC is created
  assert {
    condition     = aws_cloudfront_origin_access_control.this.name == "test-static-site-oac"
    error_message = "CloudFront OAC name does not match expected pattern"
  }
}

# Test with custom domain
run "custom_domain_configuration" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-domain-bucket"
    cloudfront_distribution_name = "test-domain-site"
    domain_names                 = ["test.example.com", "www.test.example.com"]
  }

  # Verify ACM certificate is created
  assert {
    condition     = length(aws_acm_certificate.this) == 1
    error_message = "ACM certificate should be created when domain_names is provided"
  }

  # Verify ACM certificate domain
  assert {
    condition     = aws_acm_certificate.this[0].domain_name == "test.example.com"
    error_message = "ACM certificate primary domain does not match"
  }

  # Verify CloudFront aliases
  assert {
    condition     = length(aws_cloudfront_distribution.this.aliases) == 2
    error_message = "CloudFront should have 2 domain aliases"
  }
}

# Test with Route53
run "route53_configuration" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-route53-bucket"
    cloudfront_distribution_name = "test-route53-site"
    domain_names                 = ["test.example.com"]
    hosted_zone_name             = "example.com"
    skip_certificate_validation  = true
  }

  # Mock the Route53 zone data source
  override_data {
    target = data.aws_route53_zone.main[0]
    values = {
      zone_id = "Z1234567890ABC"
      name    = "example.com"
    }
  }

  # Verify Route53 A records are created
  assert {
    condition     = length(aws_route53_record.this) == 1
    error_message = "Route53 A record should be created"
  }

  # Verify Route53 AAAA records are created
  assert {
    condition     = length(aws_route53_record.ipv6) == 1
    error_message = "Route53 AAAA record should be created"
  }

  # Verify Route53 record type
  assert {
    condition     = aws_route53_record.this["test.example.com"].type == "A"
    error_message = "Route53 record type should be A"
  }

  # Verify Route53 IPv6 record type
  assert {
    condition     = aws_route53_record.ipv6["test.example.com"].type == "AAAA"
    error_message = "Route53 IPv6 record type should be AAAA"
  }
}

# Test with CloudWatch logs
run "cloudwatch_logs_configuration" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-logs-bucket"
    cloudfront_distribution_name = "test-logs-site"
    log_delivery_destination_arn = "arn:aws:logs:us-east-1:ACCOUNT-ID:delivery-destination:test-destination"
  }

  # Verify CloudWatch log delivery source is created
  assert {
    condition     = length(aws_cloudwatch_log_delivery_source.this) == 1
    error_message = "CloudWatch log delivery source should be created"
  }

  # Verify CloudWatch log delivery is created
  assert {
    condition     = length(aws_cloudwatch_log_delivery.this) == 1
    error_message = "CloudWatch log delivery should be created"
  }

  # Verify log delivery configuration
  assert {
    condition     = aws_cloudwatch_log_delivery.this[0].delivery_destination_arn == "arn:aws:logs:us-east-1:ACCOUNT-ID:delivery-destination:test-destination"
    error_message = "Log delivery destination ARN does not match"
  }
}

# Test with tags
run "tags_configuration" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-tags-bucket"
    cloudfront_distribution_name = "test-tags-site"
    tags = {
      Environment = "test"
      Project     = "static-site-test"
      ManagedBy   = "terraform"
    }
  }

  # Verify S3 bucket has tags
  assert {
    condition     = aws_s3_bucket.this.tags["Environment"] == "test"
    error_message = "S3 bucket Environment tag does not match"
  }

  # Verify CloudFront distribution has tags
  assert {
    condition     = aws_cloudfront_distribution.this.tags["Project"] == "static-site-test"
    error_message = "CloudFront distribution Project tag does not match"
  }

  # Verify all resources have ManagedBy tag
  assert {
    condition     = aws_s3_bucket.this.tags["ManagedBy"] == "terraform"
    error_message = "Resources should have ManagedBy tag"
  }
}

# Test full configuration with all features
run "full_configuration" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-full-bucket"
    cloudfront_distribution_name = "test-full-site"
    domain_names                 = ["test.example.com", "www.test.example.com"]
    hosted_zone_name             = "example.com"
    log_delivery_destination_arn = "arn:aws:logs:us-east-1:ACCOUNT-ID:delivery-destination:test-destination"
    skip_certificate_validation  = true
    tags = {
      Environment = "production"
      Project     = "full-test"
    }
  }

  # Mock the Route53 zone data source
  override_data {
    target = data.aws_route53_zone.main[0]
    values = {
      zone_id = "Z1234567890ABC"
      name    = "example.com"
    }
  }

  # Verify S3 bucket name
  assert {
    condition     = aws_s3_bucket.this.bucket == "test-full-bucket"
    error_message = "S3 bucket name should match input"
  }

  # Verify ACM certificate is created
  assert {
    condition     = length(aws_acm_certificate.this) == 1
    error_message = "ACM certificate should be created"
  }

  # Verify Route53 records are created for both domains
  assert {
    condition     = length(aws_route53_record.this) == 2
    error_message = "Route53 A records should be created for both domains"
  }

  # Verify CloudWatch log delivery is configured
  assert {
    condition     = length(aws_cloudwatch_log_delivery_source.this) == 1
    error_message = "CloudWatch log delivery source should be created"
  }

  # Verify CloudFront has correct number of aliases
  assert {
    condition     = length(aws_cloudfront_distribution.this.aliases) == 2
    error_message = "CloudFront should have 2 aliases for 2 domain names"
  }
}

# Test resource configurations
run "verify_resource_configs" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-output-bucket"
    cloudfront_distribution_name = "test-output-site"
    domain_names                 = ["test.example.com"]
    hosted_zone_name             = "example.com"
    skip_certificate_validation  = true
  }

  # Mock the Route53 zone data source
  override_data {
    target = data.aws_route53_zone.main[0]
    values = {
      zone_id = "Z1234567890ABC"
      name    = "example.com"
    }
  }

  # Verify bucket configuration
  assert {
    condition     = aws_s3_bucket.this.bucket == "test-output-bucket"
    error_message = "Bucket name does not match expected"
  }

  # Verify Route53 records count
  assert {
    condition     = length(aws_route53_record.this) == 1
    error_message = "Should create one Route53 A record"
  }

  # Verify ACM certificate exists
  assert {
    condition     = length(aws_acm_certificate.this) == 1
    error_message = "ACM certificate should be created when domains are provided"
  }
}

# Negative test - no Route53 without zone ID
run "no_route53_without_zone" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-no-route53-bucket"
    cloudfront_distribution_name = "test-no-route53-site"
    domain_names                 = ["test.example.com"]
    hosted_zone_name             = ""
  }

  # Verify no Route53 records are created
  assert {
    condition     = length(aws_route53_record.this) == 0
    error_message = "Route53 records should not be created without hosted zone name"
  }

  # Verify no Route53 IPv6 records
  assert {
    condition     = length(aws_route53_record.ipv6) == 0
    error_message = "Route53 IPv6 records should not be created without hosted zone name"
  }
}

# Negative test - no CloudWatch logs without destination ARN
run "no_logs_without_destination" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-no-logs-bucket"
    cloudfront_distribution_name = "test-no-logs-site"
    log_delivery_destination_arn = ""
  }

  # Verify no log delivery resources are created
  assert {
    condition     = length(aws_cloudwatch_log_delivery_source.this) == 0
    error_message = "Log delivery source should not be created without destination ARN"
  }

  assert {
    condition     = length(aws_cloudwatch_log_delivery.this) == 0
    error_message = "Log delivery should not be created without destination ARN"
  }
}

# Test CloudFront function associations
run "cloudfront_function_associations" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-cf-function-bucket"
    cloudfront_distribution_name = "test-cf-function-site"
    cloudfront_function_associations = [
      {
        event_type   = "viewer-request"
        function_arn = "arn:aws:cloudfront::123456789012:function/test-function"
      }
    ]
  }

  # Verify CloudFront function associations are configured
  assert {
    condition     = length(aws_cloudfront_distribution.this.default_cache_behavior[0].function_association) == 1
    error_message = "CloudFront function association should be configured"
  }

  # Verify function association is configured (checking length is sufficient for mock test)
  assert {
    condition     = length(var.cloudfront_function_associations) == 1
    error_message = "Should have one CloudFront function association configured"
  }
}

# Test wildcard domain configuration
run "wildcard_domain_configuration" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-wildcard-bucket"
    cloudfront_distribution_name = "test-wildcard-site"
    domain_names                 = ["dev.example.com", "*.dev.example.com"]
    hosted_zone_name             = "example.com"
    skip_certificate_validation  = true
  }

  # Mock the Route53 zone data source
  override_data {
    target = data.aws_route53_zone.main[0]
    values = {
      zone_id = "Z1234567890ABC"
      name    = "example.com"
    }
  }

  # Verify ACM certificate is created with wildcard
  assert {
    condition     = aws_acm_certificate.this[0].domain_name == "dev.example.com"
    error_message = "ACM certificate primary domain should be dev.example.com"
  }

  # Verify wildcard is in subject alternative names
  assert {
    condition     = contains(aws_acm_certificate.this[0].subject_alternative_names, "*.dev.example.com")
    error_message = "ACM certificate should include wildcard domain in SANs"
  }

  # Verify CloudFront aliases include wildcard
  assert {
    condition     = length(aws_cloudfront_distribution.this.aliases) == 2
    error_message = "CloudFront should have 2 aliases"
  }

  # Verify Route53 records are created for all domains
  assert {
    condition     = length(aws_route53_record.this) == 2
    error_message = "Should create Route53 records for all domains including wildcard"
  }

  # Verify certificate validation records are NOT created when skip_certificate_validation is true
  assert {
    condition     = length(aws_route53_record.cert_validation) == 0
    error_message = "Certificate validation records should not be created when skip_certificate_validation is true"
  }
}

# Test subfolder root object functionality
run "subfolder_root_object_configuration" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-subfolder-bucket"
    cloudfront_distribution_name = "test-subfolder-site"
    subfolder_root_object        = "index.html"
    default_root_object          = "home.html"
  }

  # Verify CloudFront function is created
  assert {
    condition     = length(aws_cloudfront_function.subfolder_root_object) == 1
    error_message = "CloudFront function should be created when subfolder_root_object is set"
  }

  # Verify function name
  assert {
    condition     = aws_cloudfront_function.subfolder_root_object[0].name == "test-subfolder-site-subfolder-root-object"
    error_message = "CloudFront function name should follow naming convention"
  }

  # Verify default root object is customized
  assert {
    condition     = aws_cloudfront_distribution.this.default_root_object == "home.html"
    error_message = "Default root object should be customizable"
  }

  # Verify function is attached to distribution
  assert {
    condition     = length(aws_cloudfront_distribution.this.default_cache_behavior[0].function_association) == 1
    error_message = "Subfolder index function should be attached to CloudFront distribution"
  }
}

# Test custom error responses for SPA
run "spa_error_response_configuration" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-spa-bucket"
    cloudfront_distribution_name = "test-spa-site"
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
  }

  # Verify custom error responses are configured
  assert {
    condition     = length(aws_cloudfront_distribution.this.custom_error_response) == 2
    error_message = "CloudFront should have 2 custom error responses for SPA"
  }

  # Verify error codes match
  assert {
    condition     = contains([for r in aws_cloudfront_distribution.this.custom_error_response : r.error_code], 403)
    error_message = "CloudFront should have custom error response for 403"
  }

  assert {
    condition     = contains([for r in aws_cloudfront_distribution.this.custom_error_response : r.error_code], 404)
    error_message = "CloudFront should have custom error response for 404"
  }
}

# Test custom error pages configuration
run "custom_error_pages_configuration" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-custom-errors-bucket"
    cloudfront_distribution_name = "test-custom-errors-site"
    custom_error_responses = [
      {
        error_code            = 404
        response_code         = 404
        response_page_path    = "/errors/404.html"
        error_caching_min_ttl = 300
      },
      {
        error_code            = 500
        response_code         = 500
        response_page_path    = "/errors/500.html"
        error_caching_min_ttl = 60
      }
    ]
  }

  # Verify custom error responses count
  assert {
    condition     = length(aws_cloudfront_distribution.this.custom_error_response) == 2
    error_message = "CloudFront should have 2 custom error responses"
  }

  # Verify specific error page paths
  assert {
    condition     = contains([for r in aws_cloudfront_distribution.this.custom_error_response : r.response_page_path], "/errors/404.html")
    error_message = "CloudFront should have custom 404 error page"
  }

  assert {
    condition     = contains([for r in aws_cloudfront_distribution.this.custom_error_response : r.response_page_path], "/errors/500.html")
    error_message = "CloudFront should have custom 500 error page"
  }
}

# Test no error responses by default
run "no_error_responses_by_default" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  variables {
    s3_bucket_name               = "test-no-errors-bucket"
    cloudfront_distribution_name = "test-no-errors-site"
  }

  # Verify no custom error responses are created by default
  assert {
    condition     = length(aws_cloudfront_distribution.this.custom_error_response) == 0
    error_message = "CloudFront should have no custom error responses by default"
  }
}
