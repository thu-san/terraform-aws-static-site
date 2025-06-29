# Single Page Application (SPA) with Error Handling Example

This example demonstrates how to configure the Terraform AWS Static Site module for hosting a Single Page Application (SPA) with proper client-side routing support.

## Overview

Single Page Applications handle routing on the client side. When users directly access routes like `/about` or `/products/123`, CloudFront will try to find these files in S3 and return 403 or 404 errors. This configuration intercepts those errors and returns the main `index.html` file instead, allowing the SPA's router to handle the route.

## Features

- S3 bucket for static file hosting
- CloudFront distribution with custom error responses
- Automatic redirection of 403/404 errors to index.html
- Support for all major SPA frameworks (React Router, Vue Router, Angular Router, etc.)

## Configuration

The key configuration for SPA support is the `custom_error_responses`:

```hcl
custom_error_responses = [
  {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  },
  {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
]
```

This configuration:
- Intercepts 403 (Forbidden) and 404 (Not Found) errors from S3
- Returns the `/index.html` file content
- Sets the HTTP response code to 200 (OK)
- Allows the SPA to handle routing client-side

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Apply the configuration:
   ```bash
   terraform apply
   ```

3. Upload your SPA files to the S3 bucket:
   ```bash
   aws s3 sync ./dist s3://$(terraform output -raw s3_bucket_name)
   ```

4. Access your SPA through the CloudFront URL:
   ```bash
   echo "https://$(terraform output -raw cloudfront_domain_name)"
   ```

## Testing Client-Side Routing

After deploying your SPA:

1. Navigate to the CloudFront URL
2. Use your SPA's navigation to go to different routes
3. Refresh the page on any route - it should load correctly
4. Try accessing a deep link directly (e.g., `https://your-domain.cloudfront.net/products/123`)

All routes should work correctly, with the SPA handling the routing after CloudFront serves the index.html.

## Customization

You can further customize error handling by:

1. Adding custom error pages:
   ```hcl
   custom_error_responses = [
     # SPA routing
     {
       error_code         = 404
       response_code      = 200
       response_page_path = "/index.html"
     },
     # Custom 500 error page
     {
       error_code         = 500
       response_code      = 500
       response_page_path = "/error.html"
       error_caching_min_ttl = 60
     }
   ]
   ```

2. Adjusting cache TTL for error responses:
   ```hcl
   {
     error_code            = 404
     response_code         = 200
     response_page_path    = "/index.html"
     error_caching_min_ttl = 300  # Cache for 5 minutes
   }
   ```

## Clean Up

To destroy the resources:
```bash
terraform destroy
```