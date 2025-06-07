provider "aws" {
  region = "us-east-1"
}

module "static_site" {
  source = "../../"

  s3_bucket_name               = "example-site-bucket"
  cloudfront_distribution_name = "example-site"
  domain_names                 = ["example.com", "www.example.com"]
  route53_zone_id              = "Z1234567890ABC" # Replace with your actual Route53 zone ID

  tags = {
    Environment = "production"
    Project     = "my-website"
  }
}
