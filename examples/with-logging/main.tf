provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "../../"

  s3_bucket_name               = "example-site-bucket"
  cloudfront_distribution_name = "example-site"
  domain_names                 = ["example.com", "www.example.com"]
  hosted_zone_name             = "example.com" # Replace with your actual hosted zone domain name
  log_delivery_destination_arn = "arn:aws:logs:us-east-1:ACCOUNT-ID:delivery-destination:cloudfront-delivery-destination"


  tags = {
    Environment = "production"
    Project     = "my-website"
  }

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}
