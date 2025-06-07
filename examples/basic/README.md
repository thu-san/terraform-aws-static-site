# Basic Example

This example shows the most basic usage of the S3 CloudFront Static Site module.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## What this creates

- An S3 bucket with versioning enabled
- A CloudFront distribution using the default CloudFront certificate
- All security best practices enabled

## Outputs

After applying, you'll get:
- `s3_bucket_id` - The S3 bucket name to upload your static files
- `cloudfront_distribution_domain_name` - The CloudFront URL to access your site