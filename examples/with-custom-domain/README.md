# Custom Domain Example

This example shows how to use the module with custom domain names.

## Prerequisites

- You own the domain names you want to use
- You have access to manage DNS records for the domain

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## DNS Setup

After applying:

1. The module will output `acm_certificate_domain_validation_options`
2. Create the required DNS CNAME records in your domain's DNS settings
3. Wait for the certificate to be validated (usually takes a few minutes)
4. Create an A record (alias) pointing your domain to the CloudFront distribution

Example DNS records:
```
# For certificate validation
_abc123.example.com. CNAME _def456.acm-validations.aws.
_ghi789.www.example.com. CNAME _jkl012.acm-validations.aws.

# For the actual site (after certificate validation)
example.com. A ALIAS d1234567890.cloudfront.net.
www.example.com. A ALIAS d1234567890.cloudfront.net.
```

## What this creates

- An S3 bucket with versioning enabled
- An ACM certificate for your domains (with automatic renewal)
- A CloudFront distribution configured with your custom domains
- All security best practices enabled