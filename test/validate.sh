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

echo -e "\n2. Validating Module Structure..."
# Check that required files exist
required_files=("variables.tf" "outputs.tf" "versions.tf")
missing_files=()
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -eq 0 ]; then
    # Check that we're not defining providers in the module
    if grep -l "^provider\s" *.tf 2>/dev/null; then
        echo -e "${RED}ERROR: Module should not define providers${NC}"
        exit 1
    fi
    print_result 0 "Module structure validation"
else
    echo -e "${RED}ERROR: Missing required files: ${missing_files[*]}${NC}"
    print_result 1 "Module structure validation"
fi

echo -e "\n3. Running Terraform Tests..."
# Remove any existing provider override that might conflict
if [ -f provider_override.tf ]; then
    rm -f provider_override.tf
fi

# Initialize and run tests
terraform init -upgrade > /dev/null 2>&1
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