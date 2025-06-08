# Example integration test configuration
# This shows how to test the module with real AWS resources

module "test_static_site" {
  source = "../"

  s3_bucket_name               = "my-test-static-site-${random_id.test.hex}"
  cloudfront_distribution_name = "test-static-site-${random_id.test.hex}"

  # Optional: Add domain names if you have a Route53 hosted zone
  # domain_names     = ["test.yourdomain.com"]
  # hosted_zone_name = "yourdomain.com"

  # Optional: Enable CloudWatch logs
  # log_delivery_destination_arn = "arn:aws:logs:us-east-1:ACCOUNT-ID:delivery-destination:test"

  tags = {
    Environment = "test"
    Purpose     = "integration-testing"
    ManagedBy   = "terraform"
  }
}

# Random suffix to ensure unique resource names
resource "random_id" "test" {
  byte_length = 4
}

# Outputs for verification
output "test_bucket_name" {
  value = module.test_static_site.bucket_id
}

output "test_cloudfront_url" {
  value = "https://${module.test_static_site.cloudfront_distribution_domain_name}"
}

output "test_bucket_arn" {
  value = module.test_static_site.bucket_arn
}

# Upload a test file (optional)
resource "aws_s3_object" "test_index" {
  bucket       = module.test_static_site.bucket_id
  key          = "index.html"
  content      = "<html><body><h1>Test Static Site</h1></body></html>"
  content_type = "text/html"
}