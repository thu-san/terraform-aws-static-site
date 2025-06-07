# Provider for ACM certificates (must be in us-east-1 for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

locals {
  bucket_name = var.s3_bucket_name

  # Create certificate if domain names are provided
  create_certificate = length(var.domain_names) > 0

  # Enable CloudWatch logs if destination ARN is provided
  enable_cloudwatch_logs = var.log_delivery_destination_arn != ""

  # Create Route53 records if zone ID and domain names are provided
  create_route53_records = var.route53_zone_id != "" && length(var.domain_names) > 0

  # Hardcoded default values
  default_root_object      = "index.html"
  allowed_methods          = ["GET", "HEAD", "OPTIONS"]
  cached_methods           = ["GET", "HEAD"]
  viewer_protocol_policy   = "redirect-to-https"
  min_ttl                  = 0
  default_ttl              = 86400
  max_ttl                  = 31536000
  compress                 = true
  geo_restriction_type     = "none"
  minimum_protocol_version = "TLSv1.2_2021"

  log_record_fields = [
    "timestamp",
    "distributionid",
    "date",
    "time",
    "x-edge-location",
    "sc-bytes",
    "c-ip",
    "cs-method",
    "cs(Host)",
    "cs-uri-stem",
    "sc-status",
    "cs(Referer)",
    "cs(User-Agent)",
    "cs-uri-query",
    "cs(Cookie)",
    "x-edge-result-type",
    "x-edge-request-id",
    "x-host-header",
    "cs-protocol",
    "cs-bytes",
    "time-taken",
    "x-forwarded-for",
    "ssl-protocol",
    "ssl-cipher",
    "x-edge-response-result-type",
    "cs-protocol-version",
    "fle-status",
    "fle-encrypted-fields",
    "c-port",
    "time-to-first-byte",
    "x-edge-detailed-result-type",
    "sc-content-type",
    "sc-content-len",
    "sc-range-start",
    "sc-range-end",
    "timestamp(ms)",
    "origin-fbl",
    "origin-lbl",
    "asn",
    "distribution-tenant-id",
    "c-country",
    "cache-behavior-path-pattern",
  ]
}

# ACM Certificate (must be in us-east-1 for CloudFront)
resource "aws_acm_certificate" "this" {
  count    = local.create_certificate ? 1 : 0
  provider = aws.us_east_1

  domain_name       = var.domain_names[0]
  validation_method = "DNS"

  subject_alternative_names = length(var.domain_names) > 1 ? slice(var.domain_names, 1, length(var.domain_names)) : []

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# ACM Certificate Validation
resource "aws_acm_certificate_validation" "this" {
  count    = local.create_certificate ? 1 : 0
  provider = aws.us_east_1

  certificate_arn = aws_acm_certificate.this[0].arn
}

# S3 bucket for static site
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = var.tags
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket ACL
resource "aws_s3_bucket_acl" "this" {
  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this,
  ]

  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

# S3 bucket policy for CloudFront access
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}

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

# CloudFront Access Logs Delivery Source (must be in us-east-1)
resource "aws_cloudwatch_log_delivery_source" "this" {
  count    = local.enable_cloudwatch_logs ? 1 : 0
  provider = aws.us_east_1

  name         = "${var.cloudfront_distribution_name}-delivery-source"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.this.arn

  tags = var.tags
}

# CloudFront Access Logs Delivery Destination (must be in us-east-1)
resource "aws_cloudwatch_log_delivery" "this" {
  count                    = local.enable_cloudwatch_logs ? 1 : 0
  provider                 = aws.us_east_1
  delivery_source_name     = aws_cloudwatch_log_delivery_source.this[0].name
  delivery_destination_arn = var.log_delivery_destination_arn

  s3_delivery_configuration = [
    {
      suffix_path                 = "/{account-id}/{DistributionId}/{yyyy}/{MM}/{dd}/{HH}"
      enable_hive_compatible_path = true
    }
  ]

  record_fields = local.log_record_fields

  tags = var.tags
}

# Route53 A Records for CloudFront
resource "aws_route53_record" "this" {
  for_each = local.create_route53_records ? toset(var.domain_names) : toset([])

  zone_id = var.route53_zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

# Route53 AAAA Records for CloudFront (IPv6)
resource "aws_route53_record" "ipv6" {
  for_each = local.create_route53_records ? toset(var.domain_names) : toset([])

  zone_id = var.route53_zone_id
  name    = each.value
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
