# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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