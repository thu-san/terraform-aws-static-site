#!/bin/bash

# Deploy built Next.js app to S3
# This script syncs the built files to S3 with special handling for HTML files

set -e # Exit on error

# Check if .deploy-config exists
if [ ! -f .deploy-config ]; then
    echo "❌ Error: .deploy-config not found. Run deploy-terraform.sh first."
    exit 1
fi

# Load configuration
source .deploy-config

if [ -z "$S3_BUCKET_NAME" ]; then
    echo "❌ Error: S3_BUCKET_NAME not found in .deploy-config"
    exit 1
fi

echo "🚀 Starting deployment to bucket: $S3_BUCKET_NAME"

# Build the Next.js app
echo "🔨 Building Next.js app..."
cd next-app
npm install
npm run build

# Check if out directory exists after build
if [ ! -d "out" ]; then
    echo "❌ Error: 'out' directory not found after build. Check build configuration."
    exit 1
fi

# Go back to root directory for rest of script
cd ..

# Create a temporary directory inside the app folder
echo "📁 Preparing HTML files..."
mkdir -p tmp

# Copy all HTML files from out to the temporary directory, preserving structure
rsync -a --prune-empty-dirs --include='*/' --include='*.html' --exclude='*' next-app/out/ tmp/

# Create copies of HTML files without .html extension (keep both versions)
find tmp -name "*.html" -type f -exec sh -c 'cp "$0" "${0%.html}"' {} \;

# Upload normal files first
echo "📤 Uploading static assets..."
aws s3 sync next-app/out s3://$S3_BUCKET_NAME --exclude "*.html"

# Upload html files without extension but set content-type to text/html and cache control
echo "📤 Uploading HTML files..."
aws s3 sync tmp s3://$S3_BUCKET_NAME --content-type 'text/html' --cache-control 'must-revalidate'

# Merge tmp to out folder
rsync -abviuzP tmp/ next-app/out/

# Sync again with delete flag to remove any obsolete files
echo "🧹 Cleaning up obsolete files..."
aws s3 sync next-app/out s3://$S3_BUCKET_NAME --delete

# Clean up the temporary directory
rm -rf tmp

echo "✅ S3 deployment complete!"
echo "   Website URL: https://$CLOUDFRONT_DOMAIN_NAME"

# Optional: Invalidate CloudFront cache
if [ ! -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    echo "🔄 Creating CloudFront invalidation..."
    aws cloudfront create-invalidation \
        --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
        --paths "/*" \
        --query 'Invalidation.Id' \
        --output text
    echo "✅ CloudFront invalidation created"
fi
