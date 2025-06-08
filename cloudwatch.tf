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

  s3_delivery_configuration = var.s3_delivery_configuration

  record_fields = local.log_record_fields

  tags = var.tags
}