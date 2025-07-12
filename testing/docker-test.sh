#!/bin/bash

# Docker Testing Script for Native LEMP Tool
# This script provides isolated testing environments for different OS versions

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_RESULTS_DIR="$SCRIPT_DIR/results"

# Supported OS versions
declare -A SUPPORTED_OS=(
    ["ubuntu18"]="ubuntu:18.04"
    ["ubuntu20"]="ubuntu:20.04" 
    ["ubuntu22"]="ubuntu:22.04"
    ["ubuntu24"]="ubuntu:24.04"
    ["debian11"]="debian:11"
    ["debian12"]="debian:12"
)

# Default values
DEFAULT_OS="ubuntu22"
INTERACTIVE_MODE=false
CLEANUP_AFTER=true
RUN_FULL_INSTALL=false

show_help() {
    echo -e "${BLUE}Docker Testing Script for Native LEMP Tool${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS] [COMMAND]"
    echo ""
    echo -e "${YELLOW}Commands:${NC}"
    echo "  test [OS] [TYPE]    Run tests on specified OS (default: $DEFAULT_OS)"
    echo "                      TYPE can be: unit, e2e, both (default: both)"
    echo "  test-all            Run tests on all supported OS versions"
    echo "  interactive [OS]    Start interactive session on specified OS"
    echo "  build [OS]          Build Docker image for specified OS"
    echo "  build-all           Build Docker images for all OS versions"
    echo "  clean               Remove all test containers and images"
    echo "  list                List available OS versions"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  -h, --help          Show this help message"
    echo "  -i, --interactive   Run in interactive mode"
    echo "  -f, --full-install  Run full LEMP installation test"
    echo "  --no-cleanup        Don't cleanup containers after test"
    echo ""
    echo -e "${YELLOW}Supported OS versions:${NC}"
    for os in "${!SUPPORTED_OS[@]}"; do
        echo "  $os (${SUPPORTED_OS[$os]})"
    done
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

validate_os() {
    local os="$1"
    if [[ ! ${SUPPORTED_OS[$os]+_} ]]; then
        log_error "Unsupported OS: $os"
        echo "Supported OS versions: ${!SUPPORTED_OS[*]}"
        exit 1
    fi
}

build_image() {
    local os="$1"
    local dockerfile="Dockerfile.$os"
    local image_name="native-lemp-tool:$os"
    
    validate_os "$os"
    
    if [[ ! -f "$PROJECT_ROOT/$dockerfile" ]]; then
        log_error "Dockerfile not found: $dockerfile"
        exit 1
    fi
    
    log_info "Building Docker image for $os..."
    cd "$PROJECT_ROOT"
    
    if docker build -f "$dockerfile" -t "$image_name" .; then
        log_success "Successfully built image: $image_name"
    else
        log_error "Failed to build image for $os"
        exit 1
    fi
}

build_all_images() {
    log_info "Building Docker images for all supported OS versions..."
    
    for os in "${!SUPPORTED_OS[@]}"; do
        build_image "$os"
    done
    
    log_success "All images built successfully"
}

run_interactive() {
    local os="${1:-$DEFAULT_OS}"
    local image_name="native-lemp-tool:$os"
    
    validate_os "$os"
    
    # Check if image exists, build if not
    if ! docker image inspect "$image_name" >/dev/null 2>&1; then
        log_warning "Image $image_name not found. Building..."
        build_image "$os"
    fi
    
    log_info "Starting interactive session on $os..."
    docker run -it --rm \
        --name "lemptool-interactive-$os" \
        --privileged \
        -v "$PROJECT_ROOT:/opt/native-lemp-tool" \
        "$image_name" /bin/bash
}

run_test() {
    local os="${1:-$DEFAULT_OS}"
    local test_type="${2:-both}"  # unit, e2e, or both
    local image_name="native-lemp-tool:$os"
    local container_name="lemptool-test-$os-$(date +%s)"
    
    validate_os "$os"
    
    # Create results directory
    mkdir -p "$TEST_RESULTS_DIR"
    
    # Check if image exists, build if not
    if ! docker image inspect "$image_name" >/dev/null 2>&1; then
        log_warning "Image $image_name not found. Building..."
        build_image "$os"
    fi
    
    log_info "Running $test_type tests on $os..."
    
    # Determine which test scripts to run
    local test_commands=""
    case "$test_type" in
        "unit")
            test_commands="
                echo '=== Running Unit Tests ==='
                bash testing/unit-tests.sh
            "
            ;;
        "e2e")
            test_commands="
                echo '=== Running End-to-End Tests ==='
                bash testing/e2e-tests.sh
            "
            ;;
        "both")
            test_commands="
                echo '=== Running Unit Tests ==='
                bash testing/unit-tests.sh
                echo
                echo '=== Running End-to-End Tests ==='
                bash testing/e2e-tests.sh
            "
            ;;
        *)
            log_error "Invalid test type: $test_type. Use 'unit', 'e2e', or 'both'"
            return 1
            ;;
    esac
    
    # Run container with test script
    if docker run --rm \
        --name "$container_name" \
        --privileged \
        -v "$PROJECT_ROOT:/opt/native-lemp-tool" \
        "$image_name" /bin/bash -c "
            set -e
            cd /opt/native-lemp-tool
            
            echo '=== System Information ==='
            cat /etc/os-release
            echo \"Kernel: \$(uname -r)\"
            echo \"Architecture: \$(uname -m)\"
            echo
            
            echo '=== Environment Setup ==='
            # Copy files to a writable location and ensure they are executable
            cp -r /opt/native-lemp-tool /tmp/native-lemp-tool-work
            cd /tmp/native-lemp-tool-work
            
            # Make files executable in the copied location
            chmod +x testing/*.sh 2>/dev/null || {
                echo 'Warning: Could not change permissions on some test files'
                # Try individual files if batch operation fails
                for script in testing/*.sh; do
                    [ -f \"\$script\" ] && chmod +x \"\$script\" 2>/dev/null || true
                done
            }
            chmod +x lemptool lemptool_scripts 2>/dev/null || true
            
            # Initialize environment detection
            if [ -f scripts/bash_helpers/compatibility ]; then
                source scripts/bash_helpers/compatibility
                detect_environment >/dev/null 2>&1 || true
                get_os_info_enhanced >/dev/null 2>&1 || true
                echo \"Detected OS: \$CURRENT_DISTRO_NAME \$CURRENT_DISTRO_VERSION\"
                echo \"Environment: \$LEMPTOOL_ENVIRONMENT\"
            fi
            echo
            
            $test_commands
            
            echo
            echo '=== Test execution completed ==='
        "; then
        log_success "$test_type tests passed for $os"
        echo "$(date): $os - $test_type - PASSED" >> "$TEST_RESULTS_DIR/test-results.log"
        return 0
    else
        log_error "$test_type tests failed for $os"
        echo "$(date): $os - $test_type - FAILED" >> "$TEST_RESULTS_DIR/test-results.log"
        return 1
    fi
}

run_all_tests() {
    local test_type="${1:-both}"
    log_info "Running $test_type tests on all supported OS versions..."
    
    local failed_tests=()
    
    for os in "${!SUPPORTED_OS[@]}"; do
        log_info "Testing $os with $test_type tests..."
        if ! run_test "$os" "$test_type"; then
            failed_tests+=("$os")
        fi
        echo
    done
    
    if [[ ${#failed_tests[@]} -eq 0 ]]; then
        log_success "All $test_type tests passed!"
    else
        log_error "$test_type tests failed on: ${failed_tests[*]}"
        exit 1
    fi
}

cleanup() {
    log_info "Cleaning up Docker containers and images..."
    
    # Stop and remove all lemptool containers
    docker ps -a --filter "name=lemptool-*" --format "{{.Names}}" | xargs -r docker rm -f
    
    # Remove all lemptool images
    docker images --filter "reference=native-lemp-tool:*" --format "{{.Repository}}:{{.Tag}}" | xargs -r docker rmi -f
    
    log_success "Cleanup completed"
}

list_os() {
    echo -e "${BLUE}Available OS versions for testing:${NC}"
    for os in "${!SUPPORTED_OS[@]}"; do
        echo "  $os (${SUPPORTED_OS[$os]})"
    done
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--interactive)
            INTERACTIVE_MODE=true
            shift
            ;;
        -f|--full-install)
            RUN_FULL_INSTALL=true
            shift
            ;;
        --no-cleanup)
            CLEANUP_AFTER=false
            shift
            ;;
        test)
            COMMAND="test"
            shift
            [[ $# -gt 0 ]] && OS_VERSION="$1" && shift
            [[ $# -gt 0 ]] && TEST_TYPE="$1" && shift
            ;;
        test-all)
            COMMAND="test-all"
            shift
            [[ $# -gt 0 ]] && TEST_TYPE="$1" && shift
            ;;
        interactive)
            COMMAND="interactive"
            shift
            [[ $# -gt 0 ]] && OS_VERSION="$1" && shift
            ;;
        build)
            COMMAND="build"
            shift
            [[ $# -gt 0 ]] && OS_VERSION="$1" && shift
            ;;
        build-all)
            COMMAND="build-all"
            shift
            ;;
        clean)
            COMMAND="clean"
            shift
            ;;
        list)
            COMMAND="list"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Set default command if none provided
COMMAND="${COMMAND:-test}"
OS_VERSION="${OS_VERSION:-$DEFAULT_OS}"
TEST_TYPE="${TEST_TYPE:-both}"

# Execute command
case "$COMMAND" in
    test)
        run_test "$OS_VERSION" "$TEST_TYPE"
        ;;
    test-all)
        run_all_tests "$TEST_TYPE"
        ;;
    interactive)
        run_interactive "$OS_VERSION"
        ;;
    build)
        build_image "$OS_VERSION"
        ;;
    build-all)
        build_all_images
        ;;
    clean)
        cleanup
        ;;
    list)
        list_os
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac