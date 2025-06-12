# PR Preview Example

This example demonstrates how to use the static site module with wildcard domains and CloudFront functions to support PR preview deployments.

## Features

- **Wildcard Domain Support**: Uses `*.dev.example.com` to support PR subdomains
- **CloudFront Function**: Routes requests from PR subdomains to S3 subfolders
- **Automatic Cache Invalidation**: Updates are immediately visible

## How It Works

1. The module creates an S3 bucket and CloudFront distribution
2. ACM certificate is created with both the main domain and wildcard subdomain
3. Route53 records are created for all domains
4. CloudFront function intercepts requests and routes based on subdomain:
   - `dev.example.com` → serves from S3 root
   - `pr123.dev.example.com` → serves from S3 `/pr123/` folder

## Usage

1. Set up your terraform.tfvars:

```hcl
s3_bucket_name               = "my-pr-preview-bucket"
cloudfront_distribution_name = "My PR Preview Site"
main_domain                  = "dev.example.com"
hosted_zone_name            = "example.com"
```

2. Deploy:

```bash
terraform init
terraform plan
terraform apply
```

3. Upload content for different PRs:

```bash
# Main branch content
aws s3 sync ./dist s3://my-pr-preview-bucket/

# PR 123 content
aws s3 sync ./dist s3://my-pr-preview-bucket/pr123/

# PR 456 content  
aws s3 sync ./dist s3://my-pr-preview-bucket/pr456/
```

4. Access your sites:
   - Main: https://dev.example.com
   - PR 123: https://pr123.dev.example.com
   - PR 456: https://pr456.dev.example.com

## Customizing the CloudFront Function

You can modify the CloudFront function to implement different routing strategies:

- Different folder naming conventions
- Header-based routing
- Path-based routing
- Custom error handling

## CI/CD Integration

This setup works great with GitHub Actions or other CI/CD systems:

```yaml
- name: Deploy PR Preview
  run: |
    aws s3 sync ./dist s3://${{ secrets.S3_BUCKET }}/pr${{ github.event.pull_request.number }}/
    echo "Preview available at: https://pr${{ github.event.pull_request.number }}.dev.example.com"
```