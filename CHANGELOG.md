# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-06-29

### Added

- Full SPA (Single Page Application) support via `custom_error_responses` variable
  - Configurable error response handling for 404 and 403 errors
  - Enables proper client-side routing for React, Vue, Angular apps
  - Customizable response codes, paths, and caching TTL
- Option to skip ACM certificate DNS validation via `skip_certificate_validation` variable
  - Useful when DNS is managed externally
  - Certificate must be validated manually when enabled
- New example: SPA with custom error handling
  - Demonstrates proper SPA configuration
  - Shows CloudFront error response setup
- New example: PR preview deployments with SPA support
  - Combines wildcard domains with SPA error handling
  - Full example for PR-based preview environments
- Japanese documentation (README-ja.md)

### Removed

- Outdated PUBLISHING.md file (superseded by release workflow)

## [1.2.0] - 2025-06-12

### Added

- CloudFront function associations support via `cloudfront_function_associations` variable
  - Allows attaching custom CloudFront functions for request/response manipulation
  - Supports both viewer-request and viewer-response event types
- Wildcard domain support with automatic ACM certificate DNS validation
  - Full support for wildcard domains (e.g., `*.dev.example.com`)
  - Automatic Route53 record creation for ACM certificate validation
  - Enables PR preview deployments and multi-tenant architectures
- Built-in subfolder root object functionality via `subfolder_root_object` variable
  - Automatically serves index files from subdirectories
  - No external CloudFront functions required
  - Allows different default files for root vs subfolders
- Customizable default root object via `default_root_object` variable
  - Previously hardcoded as "index.html"
  - Now configurable to support different root files
- New example: PR preview deployments with wildcard domains
  - Shows how to implement PR preview sites using wildcard subdomains
  - Includes CloudFront function for routing PR traffic to S3 subfolders
- New example: Subfolder root object configuration
  - Demonstrates the built-in subfolder index functionality

### Fixed

- ACM certificate validation now creates Route53 DNS records automatically
  - Previously required manual DNS record creation
  - Now handles validation automatically when `hosted_zone_name` is provided
- CloudFront function for subfolder root objects now correctly preserves the root path behavior
  - Root path (`/`) uses CloudFront's `default_root_object`
  - Subfolders use the configured `subfolder_root_object`

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
