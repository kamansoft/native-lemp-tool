#!/bin/bash

# Setup script for Native LEMP Tool Testing Environment
# This script prepares the testing environment and ensures Docker is properly configured

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

check_docker_installed() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first:"
        echo "  Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y docker.io"
        echo "  Or visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    log_success "Docker is installed"
}

check_docker_running() {
    if ! docker info &> /dev/null; then
        log_warning "Docker daemon is not running or you don't have permission"
        echo ""
        echo "To fix this, try one of the following:"
        echo ""
        echo "1. Start Docker daemon:"
        echo "   sudo systemctl start docker"
        echo "   sudo systemctl enable docker  # Enable auto-start"
        echo ""
        echo "2. Add your user to docker group (requires logout/login):"
        echo "   sudo usermod -aG docker \$USER"
        echo "   newgrp docker  # Or logout and login again"
        echo ""
        echo "3. Run with sudo (not recommended for regular use):"
        echo "   sudo ./testing/docker-test.sh build ubuntu22"
        echo ""
        
        # Try to start docker if running as root/sudo
        if [[ $EUID -eq 0 ]]; then
            log_info "Running as root, attempting to start Docker..."
            systemctl start docker
            systemctl enable docker
            if docker info &> /dev/null; then
                log_success "Docker started successfully"
            else
                log_error "Failed to start Docker"
                exit 1
            fi
        else
            exit 1
        fi
    else
        log_success "Docker is running and accessible"
    fi
}

check_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        log_success "Docker Compose is available"
    else
        log_warning "Docker Compose not found. Some features may be limited."
        echo "  Install with: sudo apt-get install -y docker-compose"
    fi
}

setup_test_environment() {
    log_info "Setting up testing environment..."
    
    # Make scripts executable
    chmod +x testing/docker-test.sh
    chmod +x lemptool
    
    # Create results directory
    mkdir -p testing/results
    
    log_success "Test environment setup complete"
}

run_basic_test() {
    log_info "Running basic functionality test..."
    
    if ./testing/docker-test.sh build ubuntu22; then
        log_success "Successfully built Ubuntu 22.04 test image"
        
        if ./testing/docker-test.sh test ubuntu22; then
            log_success "Basic test passed on Ubuntu 22.04"
        else
            log_warning "Basic test failed, but image was built successfully"
        fi
    else
        log_error "Failed to build test image"
        return 1
    fi
}

show_usage_examples() {
    echo ""
    echo -e "${BLUE}Testing Environment Setup Complete!${NC}"
    echo ""
    echo -e "${YELLOW}Quick Start Examples:${NC}"
    echo ""
    echo "# Test on Ubuntu 22.04:"
    echo "  ./testing/docker-test.sh test ubuntu22"
    echo ""
    echo "# Interactive session on Ubuntu 22.04:"
    echo "  ./testing/docker-test.sh interactive ubuntu22"
    echo ""
    echo "# Test on all supported OS versions:"
    echo "  ./testing/docker-test.sh test-all"
    echo ""
    echo "# Using Makefile shortcuts:"
    echo "  make test OS=ubuntu22"
    echo "  make interactive OS=debian11"
    echo "  make test-all"
    echo ""
    echo "# Full installation test:"
    echo "  ./testing/docker-test.sh test ubuntu22 --full-install"
    echo ""
    echo -e "${YELLOW}Documentation:${NC}"
    echo "  See docs/testing-environment.md for detailed instructions"
    echo ""
}

main() {
    echo -e "${BLUE}Native LEMP Tool - Testing Environment Setup${NC}"
    echo ""
    
    check_docker_installed
    check_docker_running
    check_docker_compose
    setup_test_environment
    
    if [[ "${1:-}" == "--with-test" ]]; then
        run_basic_test
    fi
    
    show_usage_examples
}

# Run main function with all arguments
main "$@"
