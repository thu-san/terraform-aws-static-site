# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.cloudfront_distribution_name}-oac"
  description                       = "Origin Access Control for ${var.cloudfront_distribution_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cloudfront_distribution_name
  default_root_object = var.default_root_object

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_id                = "S3-${aws_s3_bucket.this.id}"
  }

  default_cache_behavior {
    allowed_methods  = local.allowed_methods
    cached_methods   = local.cached_methods
    target_origin_id = "S3-${aws_s3_bucket.this.id}"

    # Use managed policies for cache, origin request, and response headers
    # Default to CachingOptimized if cache_policy_id is null
    cache_policy_id            = var.cache_policy_id != null ? var.cache_policy_id : data.aws_cloudfront_cache_policy.caching_optimized.id
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id

    viewer_protocol_policy = local.viewer_protocol_policy

    dynamic "function_association" {
      for_each = concat(
        var.cloudfront_function_associations,
        local.create_subfolder_function ? [{
          event_type   = "viewer-request"
          function_arn = aws_cloudfront_function.subfolder_root_object[0].arn
        }] : []
      )
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = local.geo_restriction_type
      locations        = []
    }
  }

  aliases = var.domain_names

  dynamic "viewer_certificate" {
    for_each = local.create_certificate ? [1] : []
    content {
      acm_certificate_arn      = aws_acm_certificate_validation.this[0].certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = local.minimum_protocol_version
    }
  }

  dynamic "viewer_certificate" {
    for_each = local.create_certificate ? [] : [1]
    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  tags = var.tags
}