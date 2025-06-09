# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.1] - 2025-06-09

### Added

- Automatic cache invalidation feature with Lambda and SQS
  - Lambda function for processing S3 events and creating CloudFront invalidations
  - SQS queue for batching S3 upload/delete events
  - Support for direct and custom path mapping modes
  - Configurable batch processing with SQS
  - Dead letter queue support for failed invalidations
- All configuration attributes for cache invalidation are now optional with sensible defaults

### Changed

- Updated README to highlight automatic cache invalidation as a key differentiator
- Lambda reserved concurrent executions now defaults to `null` (no limit) instead of 1
- **BREAKING**: Changed from `route53_zone_id` to `hosted_zone_name` variable
  - Now accepts domain names (e.g., "example.com") instead of zone IDs
  - Automatically looks up the zone ID using a data source
- **BREAKING**: Module now requires provider configuration aliases to be passed explicitly
  - Removed internal provider configuration
  - Users must define and pass both `aws` and `aws.us_east_1` providers
- Simplified provider configuration in examples (removed redundant `aws = aws`)

### Fixed

- Fixed null value error when cache invalidation config variables are not provided using `coalesce` function
- Lambda code archive now uses `path.module` instead of `path.root` for correct path resolution when used as a module

## [1.0.0] - 2025-01-08

### Added

- Initial release of the AWS Static Site module
- S3 bucket with versioning and security best practices
- CloudFront distribution with Origin Access Control (OAC)
- Automatic ACM certificate creation for custom domains
- Route53 DNS record management (A and AAAA records)
- Cross-account CloudWatch logs delivery
- Comprehensive test suite with 9 test scenarios
- Four example configurations (basic, custom domain, logging, GitHub source)
- Support for multiple domain names
- Hardcoded sensible defaults for production use

### Security

- S3 bucket is completely private with no public access
- CloudFront uses Origin Access Control for secure S3 access
- Minimum TLS 1.2 enforced
- All S3 public access settings blocked
