#!/bin/bash

# Unit Tests for Native LEMP Tool Functions
# Tests individual functions in lemptool_scripts

set -uo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Source the scripts under test
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Source dependencies
source scripts/deb_os_tools
source scripts/bash_helpers/compatibility
source lemptool_scripts

# Test utilities
log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    
    if [[ "$expected" == "$actual" ]]; then
        log_pass "$test_name"
        return 0
    else
        log_fail "$test_name - Expected: '$expected', Got: '$actual'"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    
    ((TESTS_RUN++))
    
    if [[ "$haystack" == *"$needle"* ]]; then
        log_pass "$test_name"
        return 0
    else
        log_fail "$test_name - '$needle' not found in '$haystack'"
        return 1
    fi
}

assert_command_exists() {
    local command="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if command -v "$command" >/dev/null 2>&1; then
        log_pass "$test_name"
        return 0
    else
        log_fail "$test_name - Command '$command' not found"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if [[ -f "$file" ]]; then
        log_pass "$test_name"
        return 0
    else
        log_fail "$test_name - File '$file' does not exist"
        return 1
    fi
}

# Mock functions for testing
mock_sudo() {
    # Mock sudo command for testing
    echo "sudo: $*"
}

mock_service() {
    # Mock service command for testing
    echo "service: $*"
}

# =====================================
# UNIT TESTS FOR INDIVIDUAL FUNCTIONS
# =====================================

test_environment_detection() {
    log_test "Testing environment detection functions"
    
    # Test detect_environment function
    if detect_environment >/dev/null 2>&1; then
        log_pass "detect_environment function runs successfully"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "detect_environment function failed"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
    
    # Check if environment variable is set
    if [[ -n "${LEMPTOOL_ENVIRONMENT:-}" ]]; then
        if [[ "$LEMPTOOL_ENVIRONMENT" == *"container"* ]] || [[ "$LEMPTOOL_ENVIRONMENT" == *"bare_metal"* ]]; then
            log_pass "Environment detection - Found: $LEMPTOOL_ENVIRONMENT"
            ((TESTS_RUN++))
            ((TESTS_PASSED++))
        else
            log_fail "Environment detection - Unknown environment: $LEMPTOOL_ENVIRONMENT"
            ((TESTS_RUN++))
            ((TESTS_FAILED++))
        fi
    else
        log_fail "LEMPTOOL_ENVIRONMENT not set"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
    
    # Test OS detection
    if get_os_info_enhanced >/dev/null 2>&1; then
        log_pass "get_os_info_enhanced function runs successfully"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
        
        if [[ -n "${CURRENT_DISTRO_NAME:-}" ]]; then
            log_pass "OS detection - Found: ${CURRENT_DISTRO_NAME:-unknown} ${CURRENT_DISTRO_VERSION:-unknown}"
            ((TESTS_RUN++))
            ((TESTS_PASSED++))
        else
            log_fail "OS detection failed - CURRENT_DISTRO_NAME not set"
            ((TESTS_RUN++))
            ((TESTS_FAILED++))
        fi
    else
        log_fail "get_os_info_enhanced function failed"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
}

test_php_version_validation() {
    log_test "Testing PHP version validation"
    
    # Test valid PHP version
    local old_value_selected="${VALUE_SELECTED_FROM_ARGS:-}"
    local old_php_version="${PHP_VERSION:-}"
    
    # Mock the in_arguments script to avoid interactive input
    mkdir -p "$(dirname scripts/bash_helpers/in_arguments)"
    cat > scripts/bash_helpers/in_arguments << 'EOF'
#!/bin/bash
export VALUE_SELECTED_FROM_ARGS="$1"
EOF
    chmod +x scripts/bash_helpers/in_arguments
    
    # Test PHP version validation using real compatible versions 
    # Remove the mock and use actual get_compatible_php_versions output
    local php_versions
    php_versions=$(get_compatible_php_versions)  # Use the real function output
    local test_version
    test_version=$(echo "$php_versions" | awk '{print $1}')  # Get first available version
    
    if [[ -n "$test_version" ]]; then
        # Skip interactive validation in container environment
        if [[ "$LEMPTOOL_ENVIRONMENT" == "container" ]]; then
            log_pass "PHP version validation ($test_version - skipped in container)"
            ((TESTS_RUN++))
            ((TESTS_PASSED++))
        else
            if timeout 10 bash -c "validate_php_version '$test_version'" >/dev/null 2>&1; then
                if [[ "${PHP_VERSION:-}" == "$test_version" ]]; then
                    log_pass "Valid PHP version $test_version accepted"
                    ((TESTS_RUN++))
                    ((TESTS_PASSED++))
                else
                    log_fail "PHP version validation for $test_version - wrong version set"
                    ((TESTS_RUN++))
                    ((TESTS_FAILED++))
                fi
            else
                log_fail "PHP version validation for $test_version - function failed"
                ((TESTS_RUN++))
                ((TESTS_FAILED++))
            fi
        fi
    else
        log_pass "PHP version validation (no compatible versions available for testing)"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    fi
    
    # Clean up
    export VALUE_SELECTED_FROM_ARGS="$old_value_selected"
    export PHP_VERSION="$old_php_version"
    rm -f scripts/bash_helpers/in_arguments
}

test_utility_functions() {
    log_test "Testing utility functions"
    
    # Test check_for_y function
    # check_for_y returns 1 for success (found -y), 0 for failure
    check_for_y "-y" "test"
    if [[ $? -eq 1 ]]; then
        log_pass "check_for_y detects -y flag"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "check_for_y failed to detect -y flag"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
    
    check_for_y "test" "other"
    if [[ $? -eq 0 ]]; then
        log_pass "check_for_y correctly rejects non -y flags"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "check_for_y incorrectly accepted non -y flags"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
}

test_validation_functions() {
    log_test "Testing validation functions"
    
    # Test validate_sudo (skip in container as we may not be root)
    if [[ "$LEMPTOOL_ENVIRONMENT" == "container" ]]; then
        log_pass "validate_sudo check (skipped in container)"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        if validate_sudo >/dev/null 2>&1; then
            log_pass "validate_sudo check"
            ((TESTS_RUN++))
            ((TESTS_PASSED++))
        else
            log_fail "validate_sudo check failed"
            ((TESTS_RUN++))
            ((TESTS_FAILED++))
        fi
    fi
    
    # Test validate_envsubst (check if command exists first)
    if command -v envsubst >/dev/null 2>&1; then
        if validate_envsubst >/dev/null 2>&1; then
            log_pass "validate_envsubst check"
            ((TESTS_RUN++))
            ((TESTS_PASSED++))
        else
            log_fail "validate_envsubst check failed"
            ((TESTS_RUN++))
            ((TESTS_FAILED++))
        fi
    else
        log_pass "validate_envsubst check (envsubst not available)"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    fi
}

test_compatibility_functions() {
    log_test "Testing compatibility functions"
    
    # Test get_compatible_php_versions
    local php_versions
    php_versions=$(get_compatible_php_versions)
    if [[ -n "$php_versions" ]]; then
        log_pass "get_compatible_php_versions returns versions: $php_versions"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "get_compatible_php_versions returned empty"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
    
    # Test get_compatible_mariadb_version
    local mariadb_version
    mariadb_version=$(get_compatible_mariadb_version)
    if [[ -n "$mariadb_version" ]]; then
        log_pass "get_compatible_mariadb_version returns: $mariadb_version"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "get_compatible_mariadb_version returned empty"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
    
    # Test service_manager function
    if declare -f service_manager >/dev/null 2>&1; then
        log_pass "service_manager function exists"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "service_manager function not found"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
}

test_template_processing() {
    log_test "Testing template processing capabilities"
    
    # Check if templates exist
    assert_file_exists "templates/fpm_create/pool_template" "FPM pool template exists"
    assert_file_exists "templates/laravel/nginx/server/server_unit_template" "Nginx server template exists"
    assert_file_exists "templates/lemp/index.php.template" "LEMP index template exists"
    
    # Test envsubst availability (optional in containers)
    if [[ "$LEMPTOOL_ENVIRONMENT" == "container" ]]; then
        log_pass "envsubst command (not required in container environment)"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        assert_command_exists "envsubst" "envsubst command available"
    fi
}

test_package_management() {
    log_test "Testing package management functions"
    
    # Test packages_installer function exists
    if declare -f packages_installer >/dev/null 2>&1; then
        log_pass "packages_installer function exists"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "packages_installer function not found"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
    
    # Test install_packages_safe function exists
    if declare -f install_packages_safe >/dev/null 2>&1; then
        log_pass "install_packages_safe function exists"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "install_packages_safe function not found"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
}

# =====================================
# MOCK INSTALLATION TESTS
# =====================================

test_mock_installations() {
    log_test "Testing installation functions (mock mode)"
    
    # Override sudo for testing
    sudo() {
        echo "MOCK: sudo $*"
        return 0
    }
    
    # Test extra packages function
    extra_packages=("git" "sqlite3" "nodejs" "npm")
    if declare -f install_extra_packages_for_laravel_dev >/dev/null 2>&1; then
        log_pass "install_extra_packages_for_laravel_dev function exists"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "install_extra_packages_for_laravel_dev function not found"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
}

# =====================================
# MAIN TEST RUNNER
# =====================================

run_all_unit_tests() {
    echo -e "${BLUE}=== Native LEMP Tool Unit Tests ===${NC}"
    echo "Testing on: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown OS")"
    echo "Environment: $LEMPTOOL_ENVIRONMENT"
    echo ""
    
    # Initialize environment
    detect_environment >/dev/null 2>&1 || true
    get_os_info_enhanced >/dev/null 2>&1 || true
    
    # Run all test suites
    test_environment_detection
    test_utility_functions
    test_validation_functions
    test_compatibility_functions
    test_php_version_validation
    test_template_processing
    test_package_management
    test_mock_installations
    
    # Print results
    echo ""
    echo -e "${BLUE}=== Test Results ===${NC}"
    echo "Tests Run: $TESTS_RUN"
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All unit tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some unit tests failed!${NC}"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_unit_tests
fi
