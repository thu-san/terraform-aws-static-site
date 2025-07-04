locals {
  bucket_name = var.s3_bucket_name

  # Create certificate if domain names are provided
  create_certificate = length(var.domain_names) > 0

  # Enable CloudWatch logs if destination ARN is provided
  enable_cloudwatch_logs = var.log_delivery_destination_arn != ""

  # Create Route53 records if hosted zone name and domain names are provided
  create_route53_records = var.hosted_zone_name != "" && length(var.domain_names) > 0

  # Create subfolder index function if subfolder root object is specified
  create_subfolder_function = var.subfolder_root_object != ""

  # Hardcoded default values
  allowed_methods          = ["GET", "HEAD", "OPTIONS"]
  cached_methods           = ["GET", "HEAD"]
  viewer_protocol_policy   = "redirect-to-https"
  geo_restriction_type     = "none"
  minimum_protocol_version = "TLSv1.2_2021"

  log_record_fields = length(var.log_record_fields) > 0 ? var.log_record_fields : [
    "timestamp",
    # "distributionid", # by default, distributionid is in the path already
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
