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

# Route53 records for ACM certificate DNS validation
resource "aws_route53_record" "cert_validation" {
  for_each = local.create_certificate && var.hosted_zone_name != "" ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main[0].zone_id
}

# ACM Certificate Validation
resource "aws_acm_certificate_validation" "this" {
  count    = local.create_certificate ? 1 : 0
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = var.hosted_zone_name != "" ? [for record in aws_route53_record.cert_validation : record.fqdn] : []
}