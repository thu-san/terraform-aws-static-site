terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "../.."

  s3_bucket_name               = var.s3_bucket_name
  cloudfront_distribution_name = var.cloudfront_distribution_name

  # Enable automatic index.html serving for subfolders
  subfolder_root_object = "test.html"

  # Optionally customize the root object
  default_root_object = var.default_root_object

  tags = var.tags

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
