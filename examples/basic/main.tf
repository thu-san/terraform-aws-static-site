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

  tags = {
    Environment = "dev"
    Project     = "example"
  }

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}