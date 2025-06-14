# Example of using the module from GitHub
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Example: Using from GitHub (replace with your actual repository)
# module "static_site" {
#   source = "git::https://github.com/thu-san/terraform-aws-static-site.git?ref=v1.0.0"

# For testing, using local path
module "static_site" {
  source = "../../"

  s3_bucket_name               = "example-site-bucket"
  cloudfront_distribution_name = "example-site"
  domain_names                 = ["example.com", "www.example.com"]

  tags = {
    Environment = "production"
    Project     = "my-website"
  }

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

# Or using the main branch (not recommended for production)
# module "static_site" {
#   source = "git::https://github.com/thu-san/terraform-aws-static-site.git"
#   ...
# }

# Or from Terraform Registry (after publishing)
# module "static_site" {
#   source  = "thu-san/static-site/aws"
#   version = "1.0.0"
#   ...
# }
