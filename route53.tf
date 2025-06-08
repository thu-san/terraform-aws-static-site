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