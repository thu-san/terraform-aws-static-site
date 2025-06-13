# AWS Static Site Terraform Module

[English](README.md) | [日本語](README-ja.md)

[![Terraform CI](https://github.com/thu-san/terraform-aws-static-site/workflows/Terraform%20CI/badge.svg)](https://github.com/thu-san/terraform-aws-static-site/actions)
[![Terraform Registry](https://img.shields.io/badge/Terraform%20Registry-thu--san%2Fstatic--site%2Faws-blue.svg)](https://registry.terraform.io/modules/thu-san/static-site/aws)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Terraform Version](https://img.shields.io/badge/Terraform-%3E%3D%201.0-623CE4.svg)](https://www.terraform.io)

This Terraform module creates a complete static website hosting solution on AWS using S3 for storage and CloudFront for global content delivery.

## 🎯 Key Differentiators

1. **Automatic Cache Invalidation** - Built-in Lambda-based cache invalidation system that automatically updates CloudFront when S3 content changes. Unlike other static site modules that require manual invalidation or separate tools, this feature is integrated directly into the module with flexible path mapping options.

2. **Cross-Account CloudFront Log Delivery** - Enables you to deliver CloudFront access logs to a **different AWS account**, making it ideal for centralized logging architectures and enterprise security requirements.

3. **Built-in Subfolder Root Objects** - Automatically serve index files from subdirectories without writing custom CloudFront functions. Simply set `subfolder_root_object` and the module handles the rest, allowing different default files for root vs subfolders.

4. **Wildcard Domain Support** - Full support for wildcard domains with automatic ACM certificate validation, perfect for PR preview deployments and multi-tenant architectures.

## Features

- 🪣 **S3 Bucket** with versioning enabled and security best practices
- 🌐 **CloudFront Distribution** with Origin Access Control (OAC)
- 🔒 **ACM Certificate** automatically created for custom domains with DNS validation
- 🌍 **Route53 DNS Records** - Automatically create A and AAAA records for your domains
- 📊 **Cross-Account CloudWatch Logs** - Deliver CloudFront logs to another AWS account
- 🛡️ **Security First** - Private S3 bucket with CloudFront-only access
- ⚡ **Optimized Performance** - Compression, caching, and HTTP/2 enabled
- 🔄 **Automatic Cache Invalidation** - Built-in feature to invalidate CloudFront cache on S3 uploads with flexible path mapping
- 🎯 **CloudFront Function Support** - Attach custom functions for request/response manipulation
- 📁 **Subfolder Root Objects** - Built-in functionality to serve different index files for subdirectories
- 🔗 **Wildcard Domain Support** - Full support for wildcard certificates and domains

## Usage

### From Terraform Registry (Recommended)

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source  = "thu-san/static-site/aws"
  version = "~> 1.2"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### From GitHub

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "git::https://github.com/thu-san/terraform-aws-static-site.git?ref=v1.1.1"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### With Custom Domain

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"
  domain_names                 = ["example.com", "www.example.com"]

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### With Route53 DNS Records

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"
  domain_names                 = ["example.com", "www.example.com"]
  hosted_zone_name             = "example.com"  # Your Route53 hosted zone name

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### With Cross-Account CloudWatch Logs

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

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

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### With Wildcard Domains and CloudFront Functions (PR Preview)

This example shows how to use wildcard domains and CloudFront functions for PR preview deployments:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# CloudFront function for PR routing
resource "aws_cloudfront_function" "pr_router" {
  name    = "pr-router"
  runtime = "cloudfront-js-2.0"
  comment = "Routes PR subdomain requests to S3 subfolders"
  publish = true

  code = <<-EOT
    function handler(event) {
      var request = event.request;
      var host = request.headers.host.value;

      // Extract PR number from subdomain (e.g., pr123.dev.example.com)
      var prMatch = host.match(/^pr(\d+)\./);

      if (prMatch) {
        var prNumber = prMatch[1];
        // Prepend PR folder to the URI
        request.uri = '/pr' + prNumber + request.uri;
      }

      // If URI ends with '/', append 'index.html'
      if (request.uri.endsWith('/')) {
        request.uri += 'index.html';
      }

      return request;
    }
  EOT
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-pr-preview-bucket"
  cloudfront_distribution_name = "my-pr-preview-site"

  # Multiple domains including wildcard for PR previews
  domain_names = [
    "dev.example.com",
    "*.dev.example.com"  # Wildcard for pr123.dev.example.com
  ]

  hosted_zone_name = "example.com"

  # Attach CloudFront function for PR routing
  cloudfront_function_associations = [{
    event_type   = "viewer-request"
    function_arn = aws_cloudfront_function.pr_router.arn
  }]

  tags = {
    Environment = "development"
    Project     = "pr-preview"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

With this setup:

- Main branch content goes to S3 root → accessible at `dev.example.com`
- PR #123 content goes to S3 `/pr123/` folder → accessible at `pr123.dev.example.com`
- PR #456 content goes to S3 `/pr456/` folder → accessible at `pr456.dev.example.com`

### With Subfolder Root Objects

If you need CloudFront to automatically serve default objects from subfolders (e.g., `/about/` → `/about/index.html`), you can use the built-in subfolder root object functionality:

```hcl
module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-site-bucket"
  cloudfront_distribution_name = "my-site"

  # Automatically serve index.html as the default object for subfolder requests
  subfolder_root_object = "index.html"

  # Optionally use a different root object (e.g., "home.html" for root, "index.html" for subfolders)
  default_root_object = "index.html"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

This creates a CloudFront function that automatically appends the specified root object to subdirectory paths (but not the root path):

- `/` → Uses CloudFront's `default_root_object` (e.g., `/index.html`)
- `/about/` → `/about/index.html` (uses `subfolder_root_object`)
- `/products/` → `/products/index.html` (uses `subfolder_root_object`)
- `/blog/post-1/` → `/blog/post-1/index.html` (uses `subfolder_root_object`)

This allows you to have different default files for the root and subfolders if needed.

### With Automatic Cache Invalidation

The cache invalidation feature is built directly into the main module - no sub-modules required. When enabled, it automatically creates all necessary AWS resources including Lambda functions, SQS queues, and IAM roles.

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  s3_bucket_name               = "my-awesome-site-bucket"
  cloudfront_distribution_name = "my-awesome-site"

  # Enable automatic cache invalidation
  enable_cache_invalidation = true

  # Option 1: Direct mode (invalidate exact paths)
  invalidation_mode = "direct"

  # Option 2: Custom mode with regex mappings
  invalidation_mode = "custom"
  invalidation_path_mappings = [
    {
      source_pattern     = "^images/.*"
      invalidation_paths = ["/images/*"]
      description        = "Invalidate all images on any image upload"
    },
    {
      source_pattern     = "^(index\\.html|home\\.html)$"
      invalidation_paths = ["/*"]
      description        = "Invalidate root on homepage changes"
    }
  ]

  tags = {
    Environment = "production"
    Project     = "my-awesome-site"
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.0  |
| aws       | >= 5.0  |

## Providers

This module requires two AWS provider configurations:

| Name          | Version | Purpose                                                |
| ------------- | ------- | ------------------------------------------------------ |
| aws           | >= 5.0  | Primary provider for all resources                     |
| aws.us_east_1 | >= 5.0  | Required for ACM certificates (CloudFront requirement) |

**Important**: You must configure both providers when using this module:

```hcl
provider "aws" {
  region = "your-region"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "thu-san/static-site/aws"

  # ... your configuration ...

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

## Inputs

| Name                             | Description                                                                                             | Type           | Default        | Required |
| -------------------------------- | ------------------------------------------------------------------------------------------------------- | -------------- | -------------- | :------: |
| s3_bucket_name                   | Name of the S3 bucket for static site hosting                                                           | `string`       | n/a            |   yes    |
| cloudfront_distribution_name     | Name/comment for the CloudFront distribution                                                            | `string`       | n/a            |   yes    |
| domain_names                     | List of domain names for CloudFront distribution                                                        | `list(string)` | `[]`           |    no    |
| hosted_zone_name                 | Route53 hosted zone name (e.g., "example.com") for creating DNS records                                 | `string`       | `""`           |    no    |
| log_delivery_destination_arn     | ARN of the CloudWatch log delivery destination                                                          | `string`       | `""`           |    no    |
| s3_delivery_configuration        | S3 delivery configuration for CloudWatch logs                                                           | `list(object)` | See below      |    no    |
| log_record_fields                | List of CloudWatch log record fields to include                                                         | `list(string)` | `[]`           |    no    |
| enable_cache_invalidation        | Enable automatic cache invalidation on S3 uploads                                                       | `bool`         | `false`        |    no    |
| invalidation_mode                | Cache invalidation mode: 'direct' or 'custom'                                                           | `string`       | `"direct"`     |    no    |
| invalidation_path_mappings       | Custom path mappings for cache invalidation                                                             | `list(object)` | `[]`           |    no    |
| invalidation_sqs_config          | SQS configuration for batch processing                                                                  | `object`       | See below      |    no    |
| invalidation_lambda_config       | Lambda function configuration                                                                           | `object`       | See below      |    no    |
| invalidation_dlq_arn             | ARN of existing SQS queue to use as DLQ                                                                 | `string`       | `""`           |    no    |
| cloudfront_function_associations | List of CloudFront function associations for the default cache behavior                                 | `list(object)` | `[]`           |    no    |
| default_root_object              | The object that CloudFront returns when requests point to root URL                                      | `string`       | `"index.html"` |    no    |
| subfolder_root_object            | When set, creates a CloudFront function to serve this file as the default object for subfolder requests | `string`       | `""`           |    no    |
| tags                             | Tags to apply to all resources                                                                          | `map(string)`  | `{}`           |    no    |

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
| lambda_function_arn                       | ARN of the cache invalidation Lambda function     |
| lambda_log_group_arn                      | ARN of the Lambda CloudWatch Log Group            |
| sqs_queue_url                             | URL of the SQS queue for cache invalidation       |
| sqs_queue_arn                             | ARN of the SQS queue for cache invalidation       |

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
   - DNS validation with automatic Route53 record creation (when hosted_zone_name is provided)
   - Supports multiple domains/subdomains
   - **Supports wildcard domains** (e.g., `*.dev.example.com`)
   - First domain is primary, others are Subject Alternative Names (SANs)

4. **CloudWatch Logs** (when log_delivery_destination_arn provided):

   - Access logs with all available fields
   - **Cross-account delivery supported** - Send logs to a different AWS account
   - Ideal for centralized logging and compliance requirements

5. **Route53 DNS Records** (when hosted_zone_name and domain_names provided):

   - Automatically creates A records (IPv4) for each domain
   - Automatically creates AAAA records (IPv6) for each domain
   - Uses alias records pointing to CloudFront distribution

6. **Cache Invalidation** (when enable_cache_invalidation is true):
   - **SQS Queue**: Batches S3 events for efficient processing (created in `sqs_invalidation.tf`)
   - **Lambda Function**: Processes events and creates CloudFront invalidations (created in `lambda_invalidation.tf`)
   - **Lambda Code**: Python function located in `./lambda_code/cache_invalidation/index.py`
   - **Flexible Path Mapping**: Direct mode or custom regex-based mappings
   - **Cost Optimization**: Deduplicates paths and uses wildcards
   - **Monitoring**: CloudWatch Logs for debugging and DLQ support

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

## Default Values

### S3 Delivery Configuration

The default S3 delivery configuration for CloudWatch logs:

```hcl
s3_delivery_configuration = [
  {
    suffix_path                 = "/{account-id}/{DistributionId}/{yyyy}/{MM}/{dd}/{HH}"
    enable_hive_compatible_path = false
  }
]
```

This creates a folder structure like:

- `/123456789012/E1ABCD23EFGH/2024/01/15/10/` for logs from account 123456789012, distribution E1ABCD23EFGH, on January 15, 2024, at 10:00 hour

You can customize this by providing your own configuration:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  # ... other variables ...

  s3_delivery_configuration = [
    {
      suffix_path                 = "/cloudfront/{DistributionId}/{yyyy}-{MM}-{dd}"
      enable_hive_compatible_path = false
    }
  ]

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

### Cache Invalidation Configuration

The cache invalidation feature uses sensible defaults for all SQS and Lambda configurations. All attributes are optional - when not specified, the following defaults are applied:

#### SQS Configuration Defaults

```hcl
invalidation_sqs_config = {
  batch_window_seconds   = # Default: 60 seconds - Time window for batching messages
  batch_size             = # Default: 100 - Maximum number of messages to process in a batch
  message_retention_days = # Default: 4 days - How long to retain messages in the queue
  visibility_timeout     = # Default: 300 seconds - Message visibility timeout
}
```

#### Lambda Configuration Defaults

```hcl
invalidation_lambda_config = {
  memory_size          = # Default: 128 MB - Lambda memory allocation
  timeout              = # Default: 300 seconds - Lambda function timeout
  reserved_concurrency = # Default: null - No concurrency limit (uses account limit)
  log_retention_days   = # Default: 7 days - CloudWatch Logs retention
}
```

You can override specific values while keeping others at their defaults:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "static_site" {
  source = "path/to/terraform-aws-static-site"

  # ... other variables ...

  enable_cache_invalidation = true

  # Override only specific SQS settings
  invalidation_sqs_config = {
    batch_size = 50  # Process smaller batches
    # Other values use defaults
  }

  # Override only specific Lambda settings
  invalidation_lambda_config = {
    memory_size = 256  # Increase memory
    timeout     = 600  # Increase timeout
    # Other values use defaults
  }

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
```

## Examples

See the [examples](./examples/) directory for complete examples.

## License

Apache License 2.0

## Authors

Module managed by [Thu San].
