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
  default_root_object = local.default_root_object

  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_id                = "S3-${aws_s3_bucket.this.id}"
  }

  default_cache_behavior {
    allowed_methods  = local.allowed_methods
    cached_methods   = local.cached_methods
    target_origin_id = "S3-${aws_s3_bucket.this.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = local.viewer_protocol_policy
    min_ttl                = local.min_ttl
    default_ttl            = local.default_ttl
    max_ttl                = local.max_ttl
    compress               = local.compress
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

  tags = var.tags
}