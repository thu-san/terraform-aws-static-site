#!/bin/bash

# Deploy Terraform infrastructure and save outputs
# This script initializes Terraform, applies the configuration, and saves the S3 bucket name

set -e # Exit on error

echo "🚀 Starting Terraform deployment..."

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Apply Terraform configuration
echo "🔧 Applying Terraform configuration..."
terraform apply -auto-approve

# Extract and save outputs
echo "💾 Saving deployment configuration..."
S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name)
CLOUDFRONT_DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
CLOUDFRONT_DOMAIN_NAME=$(terraform output -raw cloudfront_domain_name)

# Save to config file
cat >.deploy-config <<EOF
S3_BUCKET_NAME=$S3_BUCKET_NAME
CLOUDFRONT_DISTRIBUTION_ID=$CLOUDFRONT_DISTRIBUTION_ID
CLOUDFRONT_DOMAIN_NAME=$CLOUDFRONT_DOMAIN_NAME
EOF

echo "✅ Terraform deployment complete!"
echo "   S3 Bucket: $S3_BUCKET_NAME"
echo "   CloudFront Distribution: $CLOUDFRONT_DISTRIBUTION_ID"
echo "   Website URL: https://$CLOUDFRONT_DOMAIN_NAME"

cd ..
