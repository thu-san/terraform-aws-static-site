#!/bin/bash

# Complete deployment script for Next.js SPA to AWS
# This script runs Terraform and then builds/deploys to S3

set -e # Exit on error

echo "🎯 Starting complete deployment process..."
echo ""

# Step 1: Deploy infrastructure with Terraform
echo "==== Step 1: Terraform Deployment ===="
./deploy-terraform.sh
echo ""

# Step 2: Build and Deploy to S3
echo "==== Step 2: Build and S3 Deployment ===="
./deploy-s3.sh
echo ""

echo "🎉 Deployment complete!"
echo ""

# Load config to show final URL
if [ -f .deploy-config ]; then
    source .deploy-config
    echo "🌐 Your website is live at: https://$CLOUDFRONT_DOMAIN_NAME"
    echo ""
    echo "📝 Test the following routes:"
    echo "   - https://$CLOUDFRONT_DOMAIN_NAME/"
    echo "   - https://$CLOUDFRONT_DOMAIN_NAME/trailing-slash/"
    echo "   - https://$CLOUDFRONT_DOMAIN_NAME/trailing-slash-query/?test=123"
    echo "   - https://$CLOUDFRONT_DOMAIN_NAME/nested/no-trailing-slash"
    echo "   - https://$CLOUDFRONT_DOMAIN_NAME/nested/no-trailing-slash-query?test=456"
    echo "   - https://$CLOUDFRONT_DOMAIN_NAME/non-existent-page (404 test)"
fi
