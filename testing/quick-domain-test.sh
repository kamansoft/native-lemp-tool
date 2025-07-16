#!/bin/bash

# Quick Domain Conversion Test
# Tests just the domain conversion logic

set -uo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Quick Domain Conversion Test ===${NC}"

# Test cases
test_cases=(
    "testapp.local:testapp_local"
    "my-app.com:my_app_com" 
    "sub.domain.org:sub_domain_org"
    "app-name.test.local:app_name_test_local"
    "simple:simple"
    "test.app-name.local:test_app_name_local"
    "a.b.c.d.e:a_b_c_d_e"
)

passed=0
failed=0

for test_case in "${test_cases[@]}"; do
    domain="${test_case%:*}"
    expected="${test_case#*:}"
    
    # Apply the same conversion logic as in lemptool_scripts
    actual=$(echo "$domain" | sed 's/\./_/g' | sed 's/-/_/g')
    
    if [[ "$actual" == "$expected" ]]; then
        echo -e "${GREEN}[PASS]${NC} $domain -> $actual"
        ((passed++))
    else
        echo -e "${RED}[FAIL]${NC} $domain -> $actual (expected: $expected)"
        ((failed++))
    fi
done

echo ""
echo "Results: $passed passed, $failed failed"

if [[ $failed -eq 0 ]]; then
    echo -e "${GREEN}All domain conversion tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
