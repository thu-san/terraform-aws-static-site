# Data source to get the hosted zone
data "aws_route53_zone" "main" {
  count = var.hosted_zone_name != "" ? 1 : 0
  name  = var.hosted_zone_name
}

# Route53 A Records for CloudFront
resource "aws_route53_record" "this" {
  for_each = local.create_route53_records ? toset(var.domain_names) : toset([])

  zone_id = data.aws_route53_zone.main[0].zone_id
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

  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = each.value
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}