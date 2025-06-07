#!/bin/bash
set -e

echo "=================================="
echo "Terraform AWS Static Site - Tests"
echo "=================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        exit 1
    fi
}

# Navigate to module root
cd "$(dirname "$0")/.."

echo -e "\n1. Running Terraform Format Check..."
terraform fmt -check -recursive
print_result $? "Terraform format check"

echo -e "\n2. Running Terraform Validation..."
terraform init -upgrade
terraform validate
print_result $? "Terraform validation"

echo -e "\n3. Running Terraform Tests..."
terraform test -test-directory=test
print_result $? "Terraform tests"

echo -e "\n4. Checking Examples..."
for example in examples/*/; do
    if [ -d "$example" ]; then
        echo -e "\n   Validating example: $example"
        cd "$example"
        terraform init -upgrade > /dev/null 2>&1
        terraform validate
        print_result $? "Example: $(basename $example)"
        cd - > /dev/null
    fi
done

echo -e "\n=================================="
echo -e "${GREEN}All tests passed!${NC}"
echo "=================================="