#!/bin/bash

# Comprehensive Test Runner for Native LEMP Tool
# Orchestrates unit tests and e2e tests across all supported operating systems

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCKER_TEST_SCRIPT="$SCRIPT_DIR/docker-test.sh"

# Supported OS versions
SUPPORTED_OS=(
    "ubuntu18"
    "ubuntu20"
    "ubuntu22"
    "ubuntu24"
    "debian11"
    "debian12"
)

# Test results tracking
declare -A UNIT_TEST_RESULTS
declare -A E2E_TEST_RESULTS
declare -A OS_TEST_STATUS

# Logging functions
log_header() {
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN} $1 ${NC}"
    echo -e "${CYAN}================================================${NC}"
}

log_section() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_test_start() {
    echo -e "${PURPLE}[TEST START]${NC} $1"
}

log_test_end() {
    echo -e "${PURPLE}[TEST END]${NC} $1"
}

# Utility functions
check_docker_availability() {
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker is not installed or not in PATH"
        return 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running or not accessible"
        return 1
    fi
    
    return 0
}

check_test_files() {
    local missing_files=()
    
    if [[ ! -f "$SCRIPT_DIR/unit-tests.sh" ]]; then
        missing_files+=("unit-tests.sh")
    fi
    
    if [[ ! -f "$SCRIPT_DIR/e2e-tests.sh" ]]; then
        missing_files+=("e2e-tests.sh")
    fi
    
    if [[ ! -f "$DOCKER_TEST_SCRIPT" ]]; then
        missing_files+=("docker-test.sh")
    fi
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_error "Missing test files: ${missing_files[*]}"
        return 1
    fi
    
    return 0
}

# Test execution functions
run_local_tests() {
    local test_type="$1"
    log_test_start "Local $test_type tests on $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown OS')"
    
    cd "$PROJECT_ROOT"
    
    case "$test_type" in
        "unit")
            if bash "$SCRIPT_DIR/unit-tests.sh"; then
                log_success "Local unit tests passed"
                return 0
            else
                log_error "Local unit tests failed"
                return 1
            fi
            ;;
        "e2e")
            if bash "$SCRIPT_DIR/e2e-tests.sh"; then
                log_success "Local e2e tests passed"
                return 0
            else
                log_error "Local e2e tests failed"
                return 1
            fi
            ;;
        *)
            log_error "Unknown test type: $test_type"
            return 1
            ;;
    esac
}

run_docker_tests() {
    local os_version="$1"
    local test_type="$2"
    
    log_test_start "Docker $test_type tests on $os_version"
    
    cd "$SCRIPT_DIR"
    
    case "$test_type" in
        "unit")
            if bash docker-test.sh test "$os_version" unit; then
                UNIT_TEST_RESULTS["$os_version"]="PASS"
                log_success "Docker unit tests passed on $os_version"
                return 0
            else
                UNIT_TEST_RESULTS["$os_version"]="FAIL"
                log_error "Docker unit tests failed on $os_version"
                return 1
            fi
            ;;
        "e2e")
            if bash docker-test.sh test "$os_version" e2e; then
                E2E_TEST_RESULTS["$os_version"]="PASS"
                log_success "Docker e2e tests passed on $os_version"
                return 0
            else
                E2E_TEST_RESULTS["$os_version"]="FAIL"
                log_error "Docker e2e tests failed on $os_version"
                return 1
            fi
            ;;
        "both")
            local unit_result=0
            local e2e_result=0
            
            # Run unit tests
            if bash docker-test.sh test "$os_version" unit; then
                UNIT_TEST_RESULTS["$os_version"]="PASS"
                log_success "Docker unit tests passed on $os_version"
            else
                UNIT_TEST_RESULTS["$os_version"]="FAIL"
                log_error "Docker unit tests failed on $os_version"
                unit_result=1
            fi
            
            # Run e2e tests
            if bash docker-test.sh test "$os_version" e2e; then
                E2E_TEST_RESULTS["$os_version"]="PASS"
                log_success "Docker e2e tests passed on $os_version"
            else
                E2E_TEST_RESULTS["$os_version"]="FAIL"
                log_error "Docker e2e tests failed on $os_version"
                e2e_result=1
            fi
            
            if [[ $unit_result -eq 0 && $e2e_result -eq 0 ]]; then
                OS_TEST_STATUS["$os_version"]="PASS"
                return 0
            else
                OS_TEST_STATUS["$os_version"]="FAIL"
                return 1
            fi
            ;;
        *)
            log_error "Unknown test type: $test_type"
            return 1
            ;;
    esac
}

run_all_os_tests() {
    local test_type="$1"
    local failed_os=()
    
    log_section "Running $test_type tests across all supported OS versions"
    
    for os in "${SUPPORTED_OS[@]}"; do
        log_info "Testing on $os..."
        
        if run_docker_tests "$os" "$test_type"; then
            log_success "$test_type tests passed on $os"
        else
            log_error "$test_type tests failed on $os"
            failed_os+=("$os")
        fi
        
        echo "" # Add spacing between OS tests
    done
    
    if [[ ${#failed_os[@]} -eq 0 ]]; then
        log_success "All $test_type tests passed across all OS versions"
        return 0
    else
        log_error "$test_type tests failed on: ${failed_os[*]}"
        return 1
    fi
}

run_comprehensive_tests() {
    log_section "Running comprehensive tests across all supported OS versions"
    
    local failed_os=()
    
    for os in "${SUPPORTED_OS[@]}"; do
        log_info "Running comprehensive tests on $os..."
        
        if run_docker_tests "$os" "both"; then
            log_success "All tests passed on $os"
        else
            log_error "Some tests failed on $os"
            failed_os+=("$os")
        fi
        
        echo "" # Add spacing between OS tests
    done
    
    if [[ ${#failed_os[@]} -eq 0 ]]; then
        log_success "All comprehensive tests passed across all OS versions"
        return 0
    else
        log_error "Comprehensive tests failed on: ${failed_os[*]}"
        return 1
    fi
}

# Reporting functions
generate_test_report() {
    echo ""
    log_header "COMPREHENSIVE TEST REPORT"
    echo ""
    
    # System information
    echo -e "${BLUE}System Information:${NC}"
    echo "  Host OS: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')"
    echo "  Docker: $(docker --version 2>/dev/null || echo 'Not available')"
    echo "  Date: $(date)"
    echo ""
    
    # Unit test results
    echo -e "${BLUE}Unit Test Results:${NC}"
    local unit_pass=0
    local unit_fail=0
    
    for os in "${SUPPORTED_OS[@]}"; do
        local result="${UNIT_TEST_RESULTS[$os]:-SKIPPED}"
        case "$result" in
            "PASS")
                echo -e "  $os: ${GREEN}PASSED${NC}"
                ((unit_pass++))
                ;;
            "FAIL")
                echo -e "  $os: ${RED}FAILED${NC}"
                ((unit_fail++))
                ;;
            *)
                echo -e "  $os: ${YELLOW}SKIPPED${NC}"
                ;;
        esac
    done
    echo ""
    
    # E2E test results
    echo -e "${BLUE}End-to-End Test Results:${NC}"
    local e2e_pass=0
    local e2e_fail=0
    
    for os in "${SUPPORTED_OS[@]}"; do
        local result="${E2E_TEST_RESULTS[$os]:-SKIPPED}"
        case "$result" in
            "PASS")
                echo -e "  $os: ${GREEN}PASSED${NC}"
                ((e2e_pass++))
                ;;
            "FAIL")
                echo -e "  $os: ${RED}FAILED${NC}"
                ((e2e_fail++))
                ;;
            *)
                echo -e "  $os: ${YELLOW}SKIPPED${NC}"
                ;;
        esac
    done
    echo ""
    
    # Overall status
    echo -e "${BLUE}Overall Test Status:${NC}"
    local overall_pass=0
    local overall_fail=0
    
    for os in "${SUPPORTED_OS[@]}"; do
        local result="${OS_TEST_STATUS[$os]:-SKIPPED}"
        case "$result" in
            "PASS")
                echo -e "  $os: ${GREEN}ALL TESTS PASSED${NC}"
                ((overall_pass++))
                ;;
            "FAIL")
                echo -e "  $os: ${RED}SOME TESTS FAILED${NC}"
                ((overall_fail++))
                ;;
            *)
                echo -e "  $os: ${YELLOW}TESTS SKIPPED${NC}"
                ;;
        esac
    done
    echo ""
    
    # Summary
    echo -e "${BLUE}Summary:${NC}"
    echo "  Unit Tests - Passed: $unit_pass, Failed: $unit_fail"
    echo "  E2E Tests - Passed: $e2e_pass, Failed: $e2e_fail"
    echo "  Overall - Passed: $overall_pass, Failed: $overall_fail"
    echo ""
    
    # Final status
    if [[ $overall_fail -eq 0 && $overall_pass -gt 0 ]]; then
        echo -e "${GREEN}🎉 ALL TESTS PASSED ACROSS ALL OPERATING SYSTEMS! 🎉${NC}"
        return 0
    elif [[ $overall_fail -gt 0 ]]; then
        echo -e "${RED}❌ SOME TESTS FAILED - SEE DETAILS ABOVE${NC}"
        return 1
    else
        echo -e "${YELLOW}⚠️  NO TESTS WERE EXECUTED${NC}"
        return 1
    fi
}

# Usage function
show_usage() {
    echo "Usage: $0 [OPTIONS] [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  unit                Run unit tests only"
    echo "  e2e                 Run end-to-end tests only"
    echo "  all                 Run both unit and e2e tests (default)"
    echo "  local-unit          Run unit tests on local system only"
    echo "  local-e2e           Run e2e tests on local system only"
    echo "  report              Generate test report from previous runs"
    echo ""
    echo "Options:"
    echo "  --os <version>      Run tests on specific OS version (ubuntu18, ubuntu20, etc.)"
    echo "  --skip-docker       Skip Docker-based tests"
    echo "  --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Run all tests on all OS versions"
    echo "  $0 unit             # Run unit tests only on all OS versions"
    echo "  $0 --os ubuntu22    # Run all tests on Ubuntu 22.04 only"
    echo "  $0 local-unit       # Run unit tests on local system only"
}

# Main execution
main() {
    local command="all"
    local specific_os=""
    local skip_docker=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_usage
                exit 0
                ;;
            --os)
                specific_os="$2"
                shift 2
                ;;
            --skip-docker)
                skip_docker=true
                shift
                ;;
            unit|e2e|all|local-unit|local-e2e|report)
                command="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Initial checks
    log_header "Native LEMP Tool Comprehensive Testing"
    
    if ! check_test_files; then
        exit 1
    fi
    
    # Set executable permissions
    chmod +x "$SCRIPT_DIR"/*.sh
    
    case "$command" in
        "local-unit")
            run_local_tests "unit"
            exit $?
            ;;
        "local-e2e")
            run_local_tests "e2e"
            exit $?
            ;;
        "report")
            generate_test_report
            exit $?
            ;;
        *)
            if [[ "$skip_docker" == "false" ]]; then
                if ! check_docker_availability; then
                    log_warning "Docker not available, falling back to local tests only"
                    case "$command" in
                        "unit")
                            run_local_tests "unit"
                            ;;
                        "e2e")
                            run_local_tests "e2e"
                            ;;
                        "all")
                            run_local_tests "unit" && run_local_tests "e2e"
                            ;;
                    esac
                    exit $?
                fi
            fi
            ;;
    esac
    
    # Main test execution
    local exit_code=0
    
    if [[ -n "$specific_os" ]]; then
        # Run tests on specific OS
        log_info "Running tests on specific OS: $specific_os"
        
        case "$command" in
            "unit")
                run_docker_tests "$specific_os" "unit" || exit_code=1
                ;;
            "e2e")
                run_docker_tests "$specific_os" "e2e" || exit_code=1
                ;;
            "all")
                run_docker_tests "$specific_os" "both" || exit_code=1
                ;;
        esac
    else
        # Run tests on all OS versions
        case "$command" in
            "unit")
                run_all_os_tests "unit" || exit_code=1
                ;;
            "e2e")
                run_all_os_tests "e2e" || exit_code=1
                ;;
            "all")
                run_comprehensive_tests || exit_code=1
                ;;
        esac
    fi
    
    # Generate report
    generate_test_report || exit_code=1
    
    exit $exit_code
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
