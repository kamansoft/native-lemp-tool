#!/bin/bash

# Simplified Unit Tests for Native LEMP Tool Functions
# Tests individual functions in lemptool_scripts

set -euo pipefail

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

assert_function_exists() {
    local function_name="$1"
    local test_name="$2"
    
    ((TESTS_RUN++))
    
    if declare -f "$function_name" >/dev/null 2>&1; then
        log_pass "$test_name"
        return 0
    else
        log_fail "$test_name - Function '$function_name' not found"
        return 1
    fi
}

# Source scripts safely
source_scripts() {
    log_test "Sourcing required scripts"
    
    # Try to source scripts safely
    if source scripts/deb_os_tools 2>/dev/null; then
        log_pass "deb_os_tools sourced successfully"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "Failed to source deb_os_tools"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
    
    if source scripts/bash_helpers/compatibility 2>/dev/null; then
        log_pass "compatibility script sourced successfully"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "Failed to source compatibility script"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
    
    if source lemptool_scripts 2>/dev/null; then
        log_pass "lemptool_scripts sourced successfully"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "Failed to source lemptool_scripts"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
}

# Test basic environment
test_basic_environment() {
    log_test "Testing basic environment"
    
    # Test essential commands
    assert_command_exists "bash" "Bash shell available"
    assert_command_exists "cat" "Cat command available"
    assert_command_exists "echo" "Echo command available"
    
    # Test essential files
    assert_file_exists "lemptool" "Main lemptool script exists"
    assert_file_exists "lemptool_scripts" "lemptool_scripts file exists"
    assert_file_exists "scripts/deb_os_tools" "deb_os_tools script exists"
    assert_file_exists "scripts/bash_helpers/compatibility" "compatibility script exists"
}

# Test function availability
test_function_availability() {
    log_test "Testing function availability"
    
    # Test compatibility functions
    assert_function_exists "detect_environment" "detect_environment function"
    assert_function_exists "get_os_info_enhanced" "get_os_info_enhanced function"
    assert_function_exists "get_compatible_php_versions" "get_compatible_php_versions function"
    assert_function_exists "get_compatible_mariadb_version" "get_compatible_mariadb_version function"
    assert_function_exists "service_manager" "service_manager function"
    
    # Test lemptool_scripts functions
    assert_function_exists "check_for_y" "check_for_y function"
    assert_function_exists "validate_php_version" "validate_php_version function"
    assert_function_exists "install_php" "install_php function"
    assert_function_exists "install_nginx" "install_nginx function"
    assert_function_exists "install_mariadb" "install_mariadb function"
    assert_function_exists "fpm_create" "fpm_create function"
}

# Test simple function execution
test_simple_functions() {
    log_test "Testing simple function execution"
    
    # Test detect_environment
    if timeout 5 detect_environment >/dev/null 2>&1; then
        log_pass "detect_environment runs without hanging"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "detect_environment failed or timed out"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
    
    # Test check_for_y function
    if check_for_y "-y" "test" >/dev/null 2>&1; then
        log_pass "check_for_y correctly detects -y flag"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "check_for_y failed to detect -y flag"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
    
    if ! check_for_y "test" "other" >/dev/null 2>&1; then
        log_pass "check_for_y correctly rejects non -y flags"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "check_for_y incorrectly accepted non -y flags"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
}

# Test OS detection (with timeout)
test_os_detection() {
    log_test "Testing OS detection"
    
    # Test get_os_info_enhanced with timeout
    if timeout 10 bash -c 'source scripts/bash_helpers/compatibility; get_os_info_enhanced' >/dev/null 2>&1; then
        log_pass "get_os_info_enhanced runs successfully"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
        
        # Try to get OS info
        if timeout 5 bash -c 'source scripts/bash_helpers/compatibility; get_os_info_enhanced; [[ -n "$CURRENT_DISTRO_NAME" ]]' 2>/dev/null; then
            log_pass "OS detection sets CURRENT_DISTRO_NAME"
            ((TESTS_RUN++))
            ((TESTS_PASSED++))
        else
            log_fail "OS detection failed to set CURRENT_DISTRO_NAME"
            ((TESTS_RUN++))
            ((TESTS_FAILED++))
        fi
    else
        log_fail "get_os_info_enhanced failed or timed out"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
}

# Test PHP versions compatibility
test_php_versions() {
    log_test "Testing PHP version compatibility"
    
    # Test get_compatible_php_versions with timeout
    if timeout 5 bash -c 'source scripts/bash_helpers/compatibility; get_compatible_php_versions' >/dev/null 2>&1; then
        log_pass "get_compatible_php_versions runs successfully"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "get_compatible_php_versions failed or timed out"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
    
    # Test get_compatible_mariadb_version with timeout
    if timeout 5 bash -c 'source scripts/bash_helpers/compatibility; get_compatible_mariadb_version' >/dev/null 2>&1; then
        log_pass "get_compatible_mariadb_version runs successfully"
        ((TESTS_RUN++))
        ((TESTS_PASSED++))
    else
        log_fail "get_compatible_mariadb_version failed or timed out"
        ((TESTS_RUN++))
        ((TESTS_FAILED++))
    fi
}

# Test template files
test_templates() {
    log_test "Testing template files"
    
    assert_file_exists "templates/fpm_create/pool_template" "FPM pool template exists"
    assert_file_exists "templates/laravel/nginx/server/server_unit_template" "Nginx server template exists"
    assert_file_exists "templates/lemp/index.php.template" "LEMP index template exists"
    assert_file_exists "templates/phpmyadmin/config.inc.php" "phpMyAdmin config template exists"
    
    # Test envsubst command
    assert_command_exists "envsubst" "envsubst command available"
}

# =====================================
# MAIN TEST RUNNER
# =====================================

run_simplified_unit_tests() {
    echo -e "${BLUE}=== Native LEMP Tool Simplified Unit Tests ===${NC}"
    echo "Testing on: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"' || echo "Unknown OS")"
    echo "Environment: ${LEMPTOOL_ENVIRONMENT:-unknown}"
    echo ""
    
    # Run all test suites
    test_basic_environment
    source_scripts
    test_function_availability
    test_simple_functions
    test_os_detection
    test_php_versions
    test_templates
    
    # Print results
    echo ""
    echo -e "${BLUE}=== Test Results ===${NC}"
    echo "Tests Run: $TESTS_RUN"
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All simplified unit tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some simplified unit tests failed!${NC}"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_simplified_unit_tests
fi
