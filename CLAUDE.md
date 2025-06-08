# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Testing and Validation
```bash
# Run all tests and validation
cd test && ./validate.sh

# Run Terraform native tests
terraform test -test-directory=test

# Format check
terraform fmt -check -recursive

# Validate module
terraform init
terraform validate

# Test with mock AWS credentials (for CI simulation)
cd test && ./ci-simulation.sh
```

### Development Commands
```bash
# Format all Terraform files
terraform fmt -recursive

# Plan with test values
terraform plan -var="s3_bucket_name=test-bucket" -var="cloudfront_distribution_name=test-dist"

# Validate examples
for example in examples/*/; do
    cd "$example"
    terraform init -backend=false
    terraform validate
    cd ../..
done
```

## Module Architecture

This is a Terraform module that creates a complete static website hosting solution on AWS. The module follows a multi-file structure where each AWS service has its own dedicated `.tf` file:

### Core Resource Files
- **s3.tf**: S3 bucket with versioning, ownership controls, public access blocking, and bucket policy for CloudFront access
- **cloudfront.tf**: CloudFront distribution with Origin Access Control (OAC), custom error pages, and optimized caching
- **acm.tf**: ACM certificate creation and validation (conditional - only when domain_names provided)
- **route53.tf**: DNS A and AAAA records (conditional - only when route53_zone_id provided)
- **cloudwatch.tf**: Cross-account log delivery configuration (conditional - only when log_delivery_destination_arn provided)

### Key Design Patterns
1. **Conditional Resource Creation**: Resources like ACM certificates, Route53 records, and CloudWatch logs use `count` to conditionally create based on input variables
2. **Provider Aliasing**: The module requires a `us-east-1` provider alias for ACM certificates (CloudFront requirement)
3. **Local Values**: Common configurations are stored in `locals.tf` to maintain consistency
4. **Security by Default**: S3 bucket is private with CloudFront-only access via OAC

### Testing Strategy
- **Terraform Native Tests**: Located in `test/main.tftest.hcl`, uses the `run` blocks to test various configurations
- **Provider Override**: Uses `test/provider_override.tf` during tests to avoid real AWS API calls
- **Test Coverage**: Tests basic configuration, custom domains, Route53, CloudWatch logs, tagging, and negative cases

### Variable Requirements
Two required variables must always be provided:
- `s3_bucket_name`: Name of the S3 bucket
- `cloudfront_distribution_name`: Name/comment for CloudFront distribution

Optional features are enabled by providing:
- `domain_names`: Triggers ACM certificate creation
- `route53_zone_id`: Enables DNS record creation
- `log_delivery_destination_arn`: Enables cross-account CloudWatch log delivery