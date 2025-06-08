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