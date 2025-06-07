provider "aws" {
  region = "us-east-1"
}

module "static_site" {
  source = "../../"

  s3_bucket_name               = "example-site-bucket"
  cloudfront_distribution_name = "example-site"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}