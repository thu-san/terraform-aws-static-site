# From GitHub Example

This example shows how to use the AWS Static Site module from a GitHub repository.

## Usage

```hcl
module "static_site" {
  source = "git::https://github.com/YOUR-USERNAME/terraform-aws-static-site.git?ref=v1.0.0"

  s3_bucket_name               = "my-site-bucket"
  cloudfront_distribution_name = "my-site"
  domain_names                 = ["example.com", "www.example.com"]

  tags = {
    Environment = "production"
    Project     = "my-website"
  }
}
```

## Notes

- Replace `YOUR-USERNAME` with your actual GitHub username
- Use specific version tags (e.g., `?ref=v1.0.0`) for production deployments
- The module can also be sourced from Terraform Registry after publishing

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- Valid AWS credentials configured