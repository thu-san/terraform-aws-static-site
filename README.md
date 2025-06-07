# AWS Static Site Terraform Module

[![Terraform CI](https://github.com/thu-san/terraform-aws-static-site/workflows/Terraform%20CI/badge.svg)](https://github.com/thu-san/terraform-aws-static-site/actions)
[![Terraform Registry](https://img.shields.io/badge/Terraform%20Registry-thu--san%2Fstatic--site%2Faws-blue.svg)](https://registry.terraform.io/modules/thu-san/static-site/aws)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Terraform Version](https://img.shields.io/badge/Terraform-%3E%3D%201.0-623CE4.svg)](https://www.terraform.io)

This Terraform module creates a complete static website hosting solution on AWS using S3 for storage and CloudFront for global content delivery.

## 🎯 Key Differentiator

**Cross-Account CloudFront Log Delivery** - Unlike other static site modules, this package enables you to deliver CloudFront access logs to a **different AWS account**, making it ideal for centralized logging architectures and enterprise security requirements.

## Features

- 🪣 **S3 Bucket** with versioning enabled and security best practices
- 🌐 **CloudFront Distribution** with Origin Access Control (OAC)
- 🔒 **ACM Certificate** automatically created for custom domains
- 🌍 **Route53 DNS Records** - Automatically create A and AAAA records for your domains
- 📊 **Cross-Account CloudWatch Logs** - Deliver CloudFront logs to another AWS account
- 🛡️ **Security First** - Private S3 bucket with CloudFront-only access
- ⚡ **Optimized Performance** - Compression, caching, and HTTP/2 enabled

## Usage

### From Terraform Registry (Recommended)

```hcl
module "static_site" {
  source  = "thu-san/static-site/aws"
  version = "~> 1.0"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }
}
```

### From GitHub

```hcl
module "static_site" {
  source = "git::https://github.com/thu-san/terraform-aws-static-site.git?ref=v1.0.0"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }
}
```

### With Custom Domain

```hcl
module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"
  domain_names                 = ["example.com", "www.example.com"]

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }
}
```

### With Route53 DNS Records

```hcl
module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"
  domain_names                 = ["example.com", "www.example.com"]
  route53_zone_id              = "Z1234567890ABC"  # Your Route53 hosted zone ID

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }
}
```

### With Cross-Account CloudWatch Logs

```hcl
module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"
  domain_names                 = ["example.com"]

  # Deliver logs to a centralized logging account (different from the CloudFront account)
  log_delivery_destination_arn = "arn:aws:logs:us-east-1:ACCOUNT-ID:delivery-destination:central-logs"

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }
}
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.0  |
| aws       | >= 5.0  |

## Providers

| Name          | Version |
| ------------- | ------- |
| aws           | >= 5.0  |
| aws.us_east_1 | >= 5.0  |

## Inputs

| Name                         | Description                                      | Type           | Default | Required |
| ---------------------------- | ------------------------------------------------ | -------------- | ------- | :------: |
| s3_bucket_name               | Name of the S3 bucket for static site hosting    | `string`       | n/a     |   yes    |
| cloudfront_distribution_name | Name/comment for the CloudFront distribution     | `string`       | n/a     |   yes    |
| domain_names                 | List of domain names for CloudFront distribution | `list(string)` | `[]`    |    no    |
| route53_zone_id              | Route53 hosted zone ID for creating DNS records  | `string`       | `""`    |    no    |
| log_delivery_destination_arn | ARN of the CloudWatch log delivery destination   | `string`       | `""`    |    no    |
| tags                         | Tags to apply to all resources                   | `map(string)`  | `{}`    |    no    |

## Outputs

| Name                                      | Description                                       |
| ----------------------------------------- | ------------------------------------------------- |
| bucket_id                                 | The name of the S3 bucket                         |
| bucket_arn                                | The ARN of the S3 bucket                          |
| bucket_regional_domain_name               | The regional domain name of the S3 bucket         |
| cloudfront_distribution_id                | The ID of the CloudFront distribution             |
| cloudfront_distribution_arn               | The ARN of the CloudFront distribution            |
| cloudfront_distribution_domain_name       | The domain name of the CloudFront distribution    |
| cloudfront_distribution_hosted_zone_id    | The CloudFront Route 53 zone ID                   |
| cloudfront_oac_id                         | The ID of the CloudFront Origin Access Control    |
| acm_certificate_arn                       | The ARN of the ACM certificate                    |
| acm_certificate_domain_validation_options | Domain validation options for the ACM certificate |
| route53_record_names                      | The names of the Route53 A records created        |
| route53_record_fqdns                      | The FQDNs of the Route53 A records created        |

## Architecture

This module creates the following AWS resources:

1. **S3 Bucket** - Private bucket with:

   - Versioning enabled
   - Public access blocked
   - Bucket policy allowing only CloudFront access

2. **CloudFront Distribution** with:

   - Origin Access Control (OAC) for secure S3 access
   - Custom domain support with ACM certificate
   - Optimized caching policies
   - Compression enabled
   - TLS 1.2 minimum

3. **ACM Certificate** (when domain_names provided):

   - Automatically created in us-east-1
   - DNS validation
   - Supports multiple domains/subdomains

4. **CloudWatch Logs** (when log_delivery_destination_arn provided):

   - Access logs with all available fields
   - **Cross-account delivery supported** - Send logs to a different AWS account
   - Ideal for centralized logging and compliance requirements

5. **Route53 DNS Records** (when route53_zone_id and domain_names provided):
   - Automatically creates A records (IPv4) for each domain
   - Automatically creates AAAA records (IPv6) for each domain
   - Uses alias records pointing to CloudFront distribution

## Security Considerations

- S3 bucket is completely private - no direct public access
- CloudFront uses Origin Access Control (OAC) for secure bucket access
- Minimum TLS 1.2 enforced
- All S3 public access settings are blocked
- Versioning enabled for data protection

## Testing

This module includes comprehensive tests to ensure all features work correctly.

### Running Tests

1. **Quick Validation**:

   ```bash
   cd test
   ./validate.sh
   ```

2. **Terraform Native Tests**:

   ```bash
   terraform test
   ```

3. **Manual Testing**:

   ```bash
   # Format check
   terraform fmt -check -recursive

   # Validate module
   terraform init
   terraform validate

   # Plan with test values
   terraform plan -var="s3_bucket_name=test-bucket" -var="cloudfront_distribution_name=test-dist"
   ```

### Test Coverage

The test suite covers:

- ✅ Basic S3 and CloudFront configuration
- ✅ Custom domain with ACM certificate
- ✅ Route53 DNS record creation
- ✅ Cross-account CloudWatch log delivery
- ✅ Resource tagging
- ✅ Security configurations (private bucket, OAC)
- ✅ Output validation
- ✅ Negative test cases

## Examples

See the [examples](./examples/) directory for complete examples.

## License

Apache License 2.0

## Authors

Module managed by [Thu San].
