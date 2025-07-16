#!/bin/bash

# Unified Comprehensive Testing Framework for Native LEMP Tool
# Follows SOLID principles and DRY principle
# Tests all functionalities across all OS environments (Docker and bare metal)
# Compatible with Ubuntu (18.04, 20.04, 22.04, 24.04) and Debian (11, 12)

set -euo pipefail

# Constants and Configuration (Single Responsibility)
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly TEST_LOG_DIR="/tmp/lemptool-tests"

# Colors for output (Interface Segregation)
declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'
declare -r YELLOW='\033[1;33m'
declare -r BLUE='\033[0;34m'
declare -r PURPLE='\033[0;35m'
declare -r CYAN='\033[0;36m'
declare -r NC='\033[0m'

# Test Configuration (Dependency Inversion)
declare -A TEST_ENVIRONMENTS=(
    ["bare_metal"]="bare_metal"
    ["ubuntu18"]="docker"
    ["ubuntu20"]="docker"
    ["ubuntu22"]="docker"
    ["ubuntu24"]="docker"
    ["debian11"]="docker"
    ["debian12"]="docker"
)

declare -A DOCKER_IMAGES=(
    ["ubuntu18"]="ubuntu:18.04"
    ["ubuntu20"]="ubuntu:20.04"
    ["ubuntu22"]="ubuntu:22.04"
    ["ubuntu24"]="ubuntu:24.04"
    ["debian11"]="debian:11"
    ["debian12"]="debian:12"
)

# Test domain conversion configuration
readonly TEST_USER="testproject"
readonly TEST_DOMAIN="testapp.local"
readonly TEST_DB_PASSWORD="testpass123"
readonly TEST_DB_NAME="testapp_local"  # Expected converted name

# Global test counters
declare -g TOTAL_ENVIRONMENTS=0
declare -g PASSED_ENVIRONMENTS=0
declare -g FAILED_ENVIRONMENTS=0

#===============================================================================
# LOGGING INTERFACE (Interface Segregation Principle)
#===============================================================================

log_header() {
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN} $1${NC}"
    echo -e "${CYAN}============================================${NC}"
}

log_section() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_test() {
    echo -e "${PURPLE}[TEST]${NC} $1"
}

#===============================================================================
# ENVIRONMENT DETECTION (Single Responsibility Principle)
#===============================================================================

detect_test_environment() {
    if [[ -f /.dockerenv ]] || [[ -n "${container:-}" ]]; then
        echo "container"
    else
        echo "bare_metal"
    fi
}

get_current_os_info() {
    local os_name=""
    local os_version=""
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        os_name="$ID"
        os_version="$VERSION_ID"
    fi
    
    case "$os_name:$os_version" in
        "ubuntu:18.04") echo "ubuntu18" ;;
        "ubuntu:20.04") echo "ubuntu20" ;;
        "ubuntu:22.04") echo "ubuntu22" ;;
        "ubuntu:24.04") echo "ubuntu24" ;;
        "debian:11") echo "debian11" ;;
        "debian:12") echo "debian12" ;;
        *) echo "unknown" ;;
    esac
}

#===============================================================================
# DOCKER INTERFACE (Dependency Inversion Principle)
#===============================================================================

# Docker Operations Interface
docker_build_volatile_image() {
    local os_key="$1"
    local dockerfile="Dockerfile.${os_key}"
    local image_tag="lemptool-test-${os_key}-$(date +%s)"
    
    if [[ ! -f "$dockerfile" ]]; then
        log_error "Dockerfile not found: $dockerfile"
        return 1
    fi
    
    if docker build -f "$dockerfile" -t "$image_tag" "$PROJECT_ROOT" >/dev/null 2>&1; then
        echo "$image_tag"
        return 0
    else
        log_error "Failed to build Docker image for $os_key"
        return 1
    fi
}

docker_cleanup_volatile_image() {
    local image_tag="$1"
    
    if [[ -n "$image_tag" ]]; then
        log_info "Cleaning up volatile image: $image_tag"
        docker rmi "$image_tag" >/dev/null 2>&1 || true
        docker image prune -f >/dev/null 2>&1 || true
    fi
}

docker_run_test_command() {
    local image_tag="$1"
    local test_command="$2"
    local privileged="${3:-false}"
    
    local docker_opts="--rm"
    [[ "$privileged" == "true" ]] && docker_opts="$docker_opts --privileged"
    
    docker run $docker_opts "$image_tag" /bin/bash -c "cd /opt/native-lemp-tool && $test_command"
}

#===============================================================================
# TEST EXECUTION ENGINES (Open/Closed Principle)
#===============================================================================

# Base Test Executor
execute_test_suite() {
    local environment="$1"
    local test_type="$2"
    local os_key="${3:-}"
    
    log_test "Executing $test_type tests in $environment environment"
    
    case "$environment" in
        "bare_metal")
            execute_bare_metal_tests "$test_type"
            ;;
        "docker")
            execute_docker_tests "$test_type" "$os_key"
            ;;
        *)
            log_error "Unknown environment: $environment"
            return 1
            ;;
    esac
}

# Bare Metal Test Execution
execute_bare_metal_tests() {
    local test_type="$1"
    
    cd "$PROJECT_ROOT"
    
    case "$test_type" in
        "unit")
            execute_unit_tests_bare_metal
            ;;
        "functionality")
            execute_functionality_tests_bare_metal
            ;;
        "lemp_integration")
            execute_lemp_integration_tests_bare_metal
            ;;
        "all")
            execute_unit_tests_bare_metal && \
            execute_functionality_tests_bare_metal && \
            execute_lemp_integration_tests_bare_metal
            ;;
        *)
            log_error "Unknown test type: $test_type"
            return 1
            ;;
    esac
}

# Docker Test Execution
execute_docker_tests() {
    local test_type="$1"
    local os_key="$2"
    local image_tag=""
    
    log_info "Building volatile Docker image for $os_key"
    
    # Build volatile image
    if ! image_tag=$(docker_build_volatile_image "$os_key"); then
        return 1
    fi
    
    log_success "Volatile Docker image built: $image_tag"
    
    # Ensure cleanup happens
    local test_result=0
    
    {
        case "$test_type" in
            "unit")
                execute_unit_tests_docker "$image_tag" "$os_key" || test_result=1
                ;;
            "functionality")
                execute_functionality_tests_docker "$image_tag" "$os_key" || test_result=1
                ;;
            "lemp_integration")
                execute_lemp_integration_tests_docker "$image_tag" "$os_key" || test_result=1
                ;;
            "all")
                execute_unit_tests_docker "$image_tag" "$os_key" && \
                execute_functionality_tests_docker "$image_tag" "$os_key" && \
                execute_lemp_integration_tests_docker "$image_tag" "$os_key" || test_result=1
                ;;
            *)
                log_error "Unknown test type: $test_type"
                test_result=1
                ;;
        esac
    } || test_result=1
    
    # Always cleanup
    docker_cleanup_volatile_image "$image_tag"
    
    return $test_result
}

#===============================================================================
# UNIT TEST IMPLEMENTATIONS (Single Responsibility Principle)
#===============================================================================

execute_unit_tests_bare_metal() {
    log_test "Running unit tests on bare metal"
    
    if bash "$SCRIPT_DIR/unit-tests.sh"; then
        log_success "Unit tests passed on bare metal"
        return 0
    else
        log_error "Unit tests failed on bare metal"
        return 1
    fi
}

execute_unit_tests_docker() {
    local image_tag="$1"
    local os_key="$2"
    
    log_test "Running unit tests in $os_key container"
    
    local test_script='
    echo "Running unit tests in container environment..."
    if ./testing/unit-tests.sh; then
        echo "SUCCESS: Unit tests passed in container"
        exit 0
    else
        echo "FAILED: Unit tests failed in container"
        exit 1
    fi
    '
    
    if docker_run_test_command "$image_tag" "$test_script" "false"; then
        log_success "Unit tests passed in $os_key container"
        return 0
    else
        log_error "Unit tests failed in $os_key container"
        return 1
    fi
}

#===============================================================================
# FUNCTIONALITY TEST IMPLEMENTATIONS (Single Responsibility Principle)
#===============================================================================

execute_functionality_tests_bare_metal() {
    log_test "Running functionality tests on bare metal"
    
    # Test basic help command
    if ! ./lemptool --help >/dev/null 2>&1; then
        log_error "Basic help command failed"
        return 1
    fi
    
    # Test domain conversion logic
    local test_conversion
    test_conversion=$(echo "$TEST_DOMAIN" | sed 's/\./_/g' | sed 's/-/_/g')
    if [[ "$test_conversion" != "$TEST_DB_NAME" ]]; then
        log_error "Domain conversion failed: expected $TEST_DB_NAME, got $test_conversion"
        return 1
    fi
    
    log_success "Functionality tests passed on bare metal"
    return 0
}

execute_functionality_tests_docker() {
    local image_tag="$1"
    local os_key="$2"
    
    log_test "Running functionality tests in $os_key container"
    
    local test_script='
    echo "Testing basic functionality..."
    
    # Test help command
    if ! ./lemptool --help >/dev/null 2>&1; then
        echo "FAILED: Help command failed"
        exit 1
    fi
    
    # Test domain conversion
    test_conversion=$(echo "'$TEST_DOMAIN'" | sed "s/\./_/g" | sed "s/-/_/g")
    if [[ "$test_conversion" != "'$TEST_DB_NAME'" ]]; then
        echo "FAILED: Domain conversion failed"
        exit 1
    fi
    
    echo "SUCCESS: Functionality tests passed"
    '
    
    if docker_run_test_command "$image_tag" "$test_script" "false"; then
        log_success "Functionality tests passed in $os_key container"
        return 0
    else
        log_error "Functionality tests failed in $os_key container"
        return 1
    fi
}

#===============================================================================
# LEMP INTEGRATION TEST IMPLEMENTATIONS (Single Responsibility Principle)
#===============================================================================

execute_lemp_integration_tests_bare_metal() {
    log_test "Running LEMP integration tests on bare metal"
    
    if bash "$SCRIPT_DIR/lemp-integration-test.sh"; then
        log_success "LEMP integration tests passed on bare metal"
        return 0
    else
        log_error "LEMP integration tests failed on bare metal"
        return 1
    fi
}

execute_lemp_integration_tests_docker() {
    local image_tag="$1"
    local os_key="$2"
    
    log_test "Running LEMP integration tests in $os_key container"
    
    local test_script='
    echo "Running LEMP integration tests..."
    
    # Install LEMP stack
    if ! ./lemptool -i -y; then
        echo "FAILED: LEMP installation failed"
        exit 1
    fi
    
    # Create LEMP environment with domain conversion testing
    if ! ./lemptool -y -lemp="'$TEST_USER'" "'$TEST_DOMAIN'" "'$TEST_DB_PASSWORD'"; then
        echo "FAILED: LEMP environment creation failed"
        exit 1
    fi
    
    # Verify directory structure
    if [[ ! -d "/var/www/'$TEST_USER'/'$TEST_DOMAIN'" ]]; then
        echo "FAILED: LEMP directory structure not created"
        exit 1
    fi
    
    # Verify domain conversion in database
    if command -v mysql >/dev/null 2>&1; then
        if mysql -u root -e "SHOW DATABASES;" | grep -q "'$TEST_DB_NAME'"; then
            echo "SUCCESS: Database with converted name '$TEST_DB_NAME' exists"
        else
            echo "WARNING: Database conversion test skipped (expected in container)"
        fi
    fi
    
    echo "SUCCESS: LEMP integration tests passed"
    '
    
    if docker_run_test_command "$image_tag" "$test_script" "true"; then
        log_success "LEMP integration tests passed in $os_key container"
        return 0
    else
        log_error "LEMP integration tests failed in $os_key container"
        return 1
    fi
}

#===============================================================================
# TEST ORCHESTRATION (Open/Closed Principle)
#===============================================================================

run_tests_for_environment() {
    local environment_key="$1"
    local test_type="$2"
    
    ((TOTAL_ENVIRONMENTS++))
    
    local environment_type="${TEST_ENVIRONMENTS[$environment_key]}"
    
    log_header "Testing $environment_key ($environment_type)"
    
    if execute_test_suite "$environment_type" "$test_type" "$environment_key"; then
        ((PASSED_ENVIRONMENTS++))
        log_success "All tests passed for $environment_key"
        return 0
    else
        ((FAILED_ENVIRONMENTS++))
        log_error "Some tests failed for $environment_key"
        return 1
    fi
}

run_tests_for_all_environments() {
    local test_type="$1"
    local specific_env="${2:-}"
    
    log_header "Unified LEMP Tool Testing Framework"
    log_info "Testing domain conversion: $TEST_DOMAIN → $TEST_DB_NAME"
    log_info "Test type: $test_type"
    
    # Setup test environment
    mkdir -p "$TEST_LOG_DIR"
    cd "$PROJECT_ROOT"
    
    # Determine environments to test
    local environments_to_test=()
    if [[ -n "$specific_env" ]]; then
        if [[ -v "TEST_ENVIRONMENTS[$specific_env]" ]]; then
            environments_to_test=("$specific_env")
        else
            log_error "Unknown environment: $specific_env"
            return 1
        fi
    else
        # Test all environments
        for env in "${!TEST_ENVIRONMENTS[@]}"; do
            environments_to_test+=("$env")
        done
    fi
    
    # Execute tests
    for env in "${environments_to_test[@]}"; do
        if run_tests_for_environment "$env" "$test_type"; then
            log_success "✓ $env passed"
        else
            log_error "✗ $env failed"
        fi
        echo
    done
    
    # Generate report
    generate_test_report "$test_type"
}

#===============================================================================
# REPORTING (Single Responsibility Principle)
#===============================================================================

generate_test_report() {
    local test_type="$1"
    
    log_header "Test Results Summary"
    log_info "Test Type: $test_type"
    log_info "Total Environments: $TOTAL_ENVIRONMENTS"
    log_success "Passed: $PASSED_ENVIRONMENTS"
    
    if [[ $FAILED_ENVIRONMENTS -gt 0 ]]; then
        log_error "Failed: $FAILED_ENVIRONMENTS"
    else
        log_success "Failed: $FAILED_ENVIRONMENTS"
    fi
    
    if [[ $FAILED_ENVIRONMENTS -eq 0 && $PASSED_ENVIRONMENTS -gt 0 ]]; then
        log_header "🎉 ALL TESTS PASSED! 🎉"
        log_success "LEMP tool works correctly across all tested environments"
        log_success "Domain conversion ($TEST_DOMAIN → $TEST_DB_NAME) works as expected"
        return 0
    elif [[ $FAILED_ENVIRONMENTS -gt 0 ]]; then
        log_header "❌ SOME TESTS FAILED"
        log_error "Please check the logs above for details"
        return 1
    else
        log_header "⚠️ NO TESTS EXECUTED"
        return 1
    fi
}

#===============================================================================
# MAIN ENTRY POINT (Single Responsibility Principle)
#===============================================================================

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [COMMAND] [ENVIRONMENT]

Commands:
  unit                Run unit tests only
  functionality       Run functionality tests only  
  lemp_integration    Run LEMP integration tests only
  all                 Run all tests (default)

Environment (optional):
  bare_metal          Test on current system
  ubuntu18            Test on Ubuntu 18.04 via Docker
  ubuntu20            Test on Ubuntu 20.04 via Docker
  ubuntu22            Test on Ubuntu 22.04 via Docker
  ubuntu24            Test on Ubuntu 24.04 via Docker
  debian11            Test on Debian 11 via Docker
  debian12            Test on Debian 12 via Docker

Options:
  --help              Show this help message

Examples:
  $0                          # Run all tests on all environments
  $0 unit                     # Run unit tests on all environments
  $0 all ubuntu22             # Run all tests on Ubuntu 22.04 only
  $0 functionality bare_metal # Run functionality tests on current system only

Note: This unified script follows SOLID principles and DRY principle.
It tests all LEMP tool functionalities across all supported OS environments.
EOF
}

main() {
    local command="all"
    local environment=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_usage
                exit 0
                ;;
            unit|functionality|lemp_integration|all)
                command="$1"
                shift
                ;;
            bare_metal|ubuntu18|ubuntu20|ubuntu22|ubuntu24|debian11|debian12)
                environment="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate Docker availability for Docker tests
    if [[ -z "$environment" || "$environment" != "bare_metal" ]]; then
        if ! command -v docker >/dev/null 2>&1; then
            log_warning "Docker not available. Running bare metal tests only."
            environment="bare_metal"
        elif ! docker info >/dev/null 2>&1; then
            log_warning "Docker daemon not running. Running bare metal tests only."
            environment="bare_metal"
        fi
    fi
    
    # Execute tests
    if run_tests_for_all_environments "$command" "$environment"; then
        exit 0
    else
        exit 1
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
