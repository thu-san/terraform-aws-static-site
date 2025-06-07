#!/bin/bash
# Script to prepare module for release

set -e

echo "🔍 Checking module..."

# Format check
echo "📐 Checking Terraform formatting..."
terraform fmt -check -recursive || (echo "❌ Please run 'terraform fmt -recursive'" && exit 1)

# Validate
echo "✅ Validating Terraform configuration..."
terraform init -backend=false
terraform validate

# Validate examples
echo "📚 Validating examples..."
for example in examples/*/; do
  if [ -f "$example/main.tf" ]; then
    echo "  Checking $example"
    (cd "$example" && terraform init -backend=false && terraform validate)
  fi
done

# Check for required files
echo "📄 Checking required files..."
required_files=("README.md" "LICENSE" "main.tf" "variables.tf" "outputs.tf" "versions.tf")
for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "❌ Missing required file: $file"
    exit 1
  fi
done

echo ""
echo "✅ Module is ready for release!"
echo ""
echo "Next steps:"
echo "1. Update CHANGELOG.md with release notes"
echo "2. Commit all changes: git add . && git commit -m 'Prepare for release v1.0.0'"
echo "3. Create tag: git tag -a v1.0.0 -m 'Release version 1.0.0'"
echo "4. Push to GitHub: git push origin main --tags"
echo "5. Create GitHub release from the tag"
echo "6. (Optional) Publish to Terraform Registry"