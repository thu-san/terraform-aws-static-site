# Provider override for testing without real AWS credentials
# This file is used during CI/CD testing

provider "aws" {
  region = "us-east-1"

  skip_credentials_validation = true
  skip_region_validation      = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  access_key = "test"
  secret_key = "test"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  skip_credentials_validation = true
  skip_region_validation      = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  access_key = "test"
  secret_key = "test"
}
