#!/bin/bash
# Simulate GitHub Actions CI locally

set -e

echo "=== Simulating GitHub Actions CI ==="
echo ""

# Set mock AWS credentials like in CI
export AWS_ACCESS_KEY_ID=mock_access_key
export AWS_SECRET_ACCESS_KEY=mock_secret_key
export AWS_DEFAULT_REGION=us-east-1

echo "1. Format Check..."
terraform fmt -check -recursive
echo "✓ Format check passed"
echo ""

echo "2. Initialize..."
terraform init -backend=false
echo "✓ Init passed"
echo ""

echo "3. Validate..."
terraform validate
echo "✓ Validation passed"
echo ""

echo "4. Run Tests..."
# Copy provider override
cp test/provider_override.tf provider_override.tf

# Initialize with provider override
terraform init -upgrade

# Run tests
terraform test -test-directory=test

# Clean up
rm -f provider_override.tf
echo "✓ Tests passed"
echo ""

echo "5. Validate Examples..."
for example in examples/*/; do
    echo "   Validating $example"
    cd "$example"
    terraform init -backend=false
    terraform validate
    terraform fmt -check
    cd ../..
done
echo "✓ Examples validated"
echo ""

echo "=== All CI checks passed! ==="