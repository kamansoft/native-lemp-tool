# Makefile for Native LEMP Tool Testing

.PHONY: help test test-all interactive build build-all clean list

# Default target
help:
	@echo "Native LEMP Tool - Testing Commands"
	@echo ""
	@echo "Available targets:"
	@echo "  test OS=ubuntu22     - Run tests on specific OS (default: ubuntu22)"
	@echo "  test-all            - Run tests on all supported OS versions"
	@echo "  interactive OS=ubuntu22 - Start interactive session (default: ubuntu22)"
	@echo "  build OS=ubuntu22   - Build Docker image for specific OS"
	@echo "  build-all           - Build all Docker images"
	@echo "  clean               - Remove all test containers and images"
	@echo "  list                - List supported OS versions"
	@echo ""
	@echo "Examples:"
	@echo "  make test OS=debian11"
	@echo "  make interactive OS=ubuntu20"
	@echo "  make test-all"

# Default OS version
OS ?= ubuntu22

# Test on specific OS
test:
	@./testing/docker-test.sh test $(OS)

# Test on all OS versions
test-all:
	@./testing/docker-test.sh test-all

# Interactive session
interactive:
	@./testing/docker-test.sh interactive $(OS)

# Build specific OS image
build:
	@./testing/docker-test.sh build $(OS)

# Build all images
build-all:
	@./testing/docker-test.sh build-all

# Cleanup
clean:
	@./testing/docker-test.sh clean

# List supported OS versions
list:
	@./testing/docker-test.sh list

# Full installation test
test-full:
	@./testing/docker-test.sh test $(OS) --full-install
