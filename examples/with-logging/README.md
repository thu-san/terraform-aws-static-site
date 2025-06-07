# CloudWatch Logging Example

This example demonstrates how to configure the AWS Static Site module with CloudWatch logging enabled, including cross-account log delivery.

## Usage

```hcl
module "static_site" {
  source = "../../"

  s3_bucket_name               = "my-site-bucket"
  cloudfront_distribution_name = "my-site"
  domain_names                 = ["example.com", "www.example.com"]
  route53_zone_id              = "Z1234567890ABC"
  
  # Enable cross-account CloudWatch log delivery
  log_delivery_destination_arn = "arn:aws:logs:us-east-1:ACCOUNT-ID:delivery-destination:central-logs"

  tags = {
    Environment = "production"
    Project     = "my-website"
  }
}
```

## Prerequisites

1. **CloudWatch Log Delivery Destination**: You need to have a CloudWatch log delivery destination already created in the target account. This can be in the same account or a different account for centralized logging.

2. **Cross-Account Permissions**: If using cross-account delivery, ensure the destination has the appropriate resource policy to allow CloudFront to deliver logs.

## Features

- Delivers CloudFront access logs to CloudWatch Logs
- Supports cross-account log delivery
- Includes all available CloudFront log fields
- Uses Hive-compatible path structure for easy querying

## Log Fields

The module captures all available CloudFront access log fields including:
- Request details (timestamp, method, URI, status)
- Performance metrics (bytes, time-taken)
- Client information (IP, user-agent, country)
- Security details (SSL protocol, cipher)
- Edge location information

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- Valid AWS credentials
- Pre-configured CloudWatch log delivery destination