# Next.js SPA Example

This example demonstrates how to deploy a Next.js Single Page Application (SPA) to AWS using the Terraform AWS Static Site module. It includes comprehensive routing tests to ensure CloudFront properly handles various URL patterns.

## Overview

This example creates:

- S3 bucket for hosting the static Next.js export
- CloudFront distribution with custom error handling for SPA routing
- Test pages for various routing scenarios

## Features Tested

- **Home page** (`/`)
- **Trailing slash routes** (`/trailing-slash/`)
- **Non-trailing slash routes** (`/no-trailing-slash`)
- **Nested routes** (`/no-trailing-slash/nested`, `/no-trailing-slash/nested/deep`)
- **Query parameters** on all route types
- **Custom error page** (`/error`)
- **Direct URL access** (refresh/deep linking)
- **Client-side navigation**

## Prerequisites

- Node.js 18+ and npm
- Terraform >= 1.0
- AWS CLI configured with appropriate credentials

## Project Structure

```text
examples/nextjs-spa/
├── next-app/             # Next.js application
│   ├── src/
│   ├── public/
│   └── ...
├── terraform/            # Infrastructure code
├── deploy-s3.sh         # S3 deployment script
├── deploy-terraform.sh  # Terraform deployment script
└── deploy.sh           # Complete deployment script
```

## Setup Instructions

### 1. Create the Next.js Application

```bash
cd next-app
npx create-next-app@latest . --typescript --app --tailwind --no-src-dir --import-alias "@/*"
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Next.js for Static Export

Update `next.config.js`:

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  trailingSlash: false, // Important for testing both trailing and non-trailing slash behavior
}

module.exports = nextConfig
```

### 4. Create Test Pages

The application includes the following pages:

- `next-app/app/page.tsx` - Home page
- `next-app/app/trailing-slash/page.tsx` - Trailing slash test
- `next-app/app/no-trailing-slash/page.tsx` - Non-trailing slash test
- `next-app/app/no-trailing-slash/nested/page.tsx` - Nested route
- `next-app/app/no-trailing-slash/nested/deep/page.tsx` - Deeply nested route
- `next-app/app/error/page.tsx` - Error page

## Deployment

### Automated Deployment (Recommended)

The easiest way to deploy is using the provided scripts:

```bash
# Deploy everything (Terraform + Next.js app)
./deploy.sh
```

Or run the scripts separately:

```bash
# 1. Deploy infrastructure
./deploy-terraform.sh

# 2. Build and deploy Next.js app to S3
./deploy-s3.sh
```

### Manual Deployment

If you prefer to deploy manually:

#### 1. Build the Next.js Application

```bash
cd next-app
npm run build
```

This creates an `out` directory with the static export.

#### 2. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

#### 3. Upload Files to S3

```bash
# From the terraform directory
aws s3 sync ../next-app/out s3://$(terraform output -raw s3_bucket_name) --delete
```

#### 4. Access the Application

```bash
# From the terraform directory
echo "Application URL: $(terraform output -raw website_url)"
```

## Testing Scenarios

### 1. Direct URL Access

Test that each URL works when accessed directly (simulating bookmarks or shared links):

- `https://[cloudfront-domain]/`
- `https://[cloudfront-domain]/trailing-slash/`
- `https://[cloudfront-domain]/no-trailing-slash`
- `https://[cloudfront-domain]/no-trailing-slash/nested`
- `https://[cloudfront-domain]/no-trailing-slash/nested/deep`
- `https://[cloudfront-domain]/error`

### 2. Query Parameters

Test that query parameters are preserved:

- `https://[cloudfront-domain]/?param=value`
- `https://[cloudfront-domain]/trailing-slash/?search=test&page=1`
- `https://[cloudfront-domain]/no-trailing-slash?id=123`
- `https://[cloudfront-domain]/no-trailing-slash/nested?filter=active`

### 3. Client-Side Navigation

1. Navigate to the home page
2. Use the navigation menu to visit each route
3. Verify the browser URL updates correctly
4. Check that query parameters are displayed on each page

### 4. Browser Refresh

1. Navigate to any nested route
2. Refresh the browser (F5 or Cmd+R)
3. Verify the page loads correctly (not 404)

### 5. Browser Back/Forward

1. Navigate through multiple pages
2. Use browser back/forward buttons
3. Verify navigation works correctly

## Expected Behavior

- **403/404 Errors**: CloudFront intercepts these and serves `index.html` with 200 status
- **Trailing Slashes**: Routes work with and without trailing slashes
- **Query Parameters**: Preserved through navigation and direct access
- **Deep Links**: All routes accessible via direct URL

## Troubleshooting

### Page shows 404 after deployment

1. Verify the custom error responses in CloudFront:

   ```bash
   aws cloudfront get-distribution --id $(terraform output -raw cloudfront_distribution_id) --query 'Distribution.DistributionConfig.CustomErrorResponses'
   ```

2. Ensure files were uploaded to S3:

   ```bash
   aws s3 ls s3://$(terraform output -raw s3_bucket_name)/
   ```

### CloudFront not updating

Clear the CloudFront cache:

```bash
aws cloudfront create-invalidation --distribution-id $(terraform output -raw cloudfront_distribution_id) --paths "/*"
```

### Next.js Build Issues

- Ensure `output: 'export'` is set in `next.config.ts`
- Check for any dynamic routes or server-side features (not supported in static export)
- Run `npm run build` locally to see detailed error messages

## Clean Up

```bash
# Empty the S3 bucket first
aws s3 rm s3://$(terraform output -raw s3_bucket_name) --recursive

# Destroy infrastructure
terraform destroy
```

## Notes

- The S3 bucket name must be globally unique. Modify in `main.tf` if needed.
- CloudFront distributions take 15-20 minutes to fully deploy.
- Static export doesn't support Next.js features like API routes, ISR, or middleware.
