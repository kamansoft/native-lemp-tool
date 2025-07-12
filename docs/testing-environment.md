# Comprehensive Testing Framework Documentation

This document describes the three-tier testing framework for the Native LEMP Tool project, providing unit testing, end-to-end testing, and cross-OS compatibility validation.

## 📋 Testing Overview

The testing framework consists of three levels of comprehensive validation:

### 1. **Unit Tests** (`testing/unit-tests.sh`)
- Tests individual functions in `lemptool_scripts` 
- Validates function behavior, parameter handling, and error conditions
- Container-environment aware with appropriate mocking
- **Coverage**: 19 tests, 35 assertions per OS

### 2. **End-to-End Tests** (`testing/e2e-tests.sh`)
- Tests complete workflows and user scenarios
- Validates integration between components  
- Tests actual installations and configurations (container-safe)
- **Coverage**: 47 tests, 88 assertions per OS

### 3. **Cross-OS Compatibility** (`testing/comprehensive-test.sh`)
- Orchestrates all tests across supported operating systems
- Provides unified reporting and result aggregation
- **Support**: 6 operating systems with 100% success rate

## 🏗️ Testing Architecture

```
testing/
├── unit-tests.sh              # Individual function testing
├── e2e-tests.sh               # End-to-end workflow testing  
├── comprehensive-test.sh      # Cross-OS test orchestrator
├── docker-test.sh             # Docker-based testing infrastructure
├── README.md                  # Comprehensive testing documentation
└── results/                   # Test execution results and logs (auto-generated)
```

## 🖥️ Supported Operating Systems

The framework provides 100% test coverage across:

- **Ubuntu**: 18.04 (Bionic), 20.04 (Focal), 22.04 (Jammy), 24.04 (Noble)
- **Debian**: 11 (Bullseye), 12 (Bookworm)

Each OS version is tested in isolated Docker containers ensuring clean, reproducible environments.

## 🚀 Quick Start Guide

### 1. Run Complete Test Suite
```bash
# Test everything across all operating systems
./testing/comprehensive-test.sh

# Run only unit tests across all OS versions
./testing/comprehensive-test.sh unit

# Run only end-to-end tests across all OS versions
./testing/comprehensive-test.sh e2e
```

### 2. Test Specific Operating System
```bash
# Test specific OS version (both unit and e2e)
./testing/comprehensive-test.sh --os ubuntu22

# Test unit tests only on specific OS
./testing/comprehensive-test.sh unit --os debian12

# Test e2e tests only on specific OS  
./testing/comprehensive-test.sh e2e --os ubuntu24
```

### 3. Local Testing (Without Docker)
```bash
# Run unit tests on local system
./testing/comprehensive-test.sh local-unit

# Run e2e tests on local system
./testing/comprehensive-test.sh local-e2e
```

### 4. Direct Test Execution
```bash
# Run individual test suites directly
./testing/unit-tests.sh
./testing/e2e-tests.sh

# Use Docker for specific OS testing
./testing/docker-test.sh test ubuntu22 unit
./testing/docker-test.sh test debian12 e2e
./testing/docker-test.sh test ubuntu20 both
./testing/docker-test.sh interactive ubuntu22
```

## 🧪 Comprehensive Test Coverage

### Unit Test Coverage (19 tests per OS)
- **Environment Detection**: `detect_environment()`, `get_os_info_enhanced()`
- **Utility Functions**: `check_for_y()`, parameter processing
- **Validation Functions**: `validate_sudo()`, `validate_envsubst()`, `validate_php_version()`
- **Compatibility Functions**: `get_compatible_php_versions()`, `get_compatible_mariadb_version()`
- **Service Management**: `service_manager()`, systemctl abstraction
- **Package Management**: `packages_installer()`, `install_packages_safe()`
- **Template Processing**: FPM, Nginx, LEMP template validation

### End-to-End Test Coverage (47 tests per OS)
1. **Help System Validation** - `--help`, `-help` commands
2. **Cross-OS Compatibility** - OS detection and version compatibility
3. **Package Installation** - Basic package installation workflows
4. **Component Installation**:
   - **Nginx** (`-ng`) - Repository setup, service configuration
   - **PHP** (`-p=version`) - Version-specific installation, extensions, Composer
   - **MariaDB** (`-mdb`) - Database server installation, initialization
5. **Configuration Management**:
   - **FPM Pool Creation** (`-fmp=username`) - User validation, pool generation
   - **Nginx Server Creation** (`--fpm-ng-server-create`) - Virtual host configuration
   - **Database User Management** - User creation, permissions
6. **Complete LEMP Stack** (`-lemp=user domain password`) - Full stack creation
7. **phpMyAdmin Installation** - Complete installation workflow
8. **Complete Installation** (`-i`) - Full system installation
9. **Error Handling** - Invalid parameters, missing dependencies
10. **Performance Testing** - Command execution time, resource usage

### Cross-OS Results Matrix
```
Test Results Summary:
  Unit Tests - Passed: 6/6 OS versions (100%)
  E2E Tests - Passed: 6/6 OS versions (100%)
  Overall Success Rate: 100%
  
Per OS Breakdown:
  Ubuntu 18.04: 66 tests, 123 assertions ✅
  Ubuntu 20.04: 66 tests, 123 assertions ✅  
  Ubuntu 22.04: 66 tests, 123 assertions ✅
  Ubuntu 24.04: 66 tests, 123 assertions ✅
  Debian 11: 66 tests, 123 assertions ✅
  Debian 12: 66 tests, 123 assertions ✅
```

# Test on all supported OS versions
./testing/docker-test.sh test-all

# Run full LEMP installation test
./testing/docker-test.sh test ubuntu22 --full-install
```

### Interactive Testing

```bash
# Start interactive session on Ubuntu 22.04
./testing/docker-test.sh interactive ubuntu22

# Start interactive session on Debian 11
./testing/docker-test.sh interactive debian11
```

### Building Images

```bash
# Build specific OS image
./testing/docker-test.sh build ubuntu22

# Build all OS images
./testing/docker-test.sh build-all
```

### Cleanup

```bash
# Remove all test containers and images
./testing/docker-test.sh clean
```

## Docker Compose Usage

For more complex testing scenarios, you can use Docker Compose:

```bash
# Build all test environments
docker-compose -f docker-compose.test.yml build

# Start specific test environment
docker-compose -f docker-compose.test.yml up ubuntu22-test

# Start all test environments
docker-compose -f docker-compose.test.yml up

# Execute commands in running container
docker-compose -f docker-compose.test.yml exec ubuntu22-test bash

# Cleanup
docker-compose -f docker-compose.test.yml down
```

## Testing Scenarios

### 1. Basic Functionality Test
Tests basic script operations without full installation:
- Help command display
- Package installation functionality
- Script argument parsing

### 2. Full LEMP Installation Test
Tests complete LEMP stack installation:
- Nginx installation and configuration
- PHP installation with multiple versions
- MariaDB installation and setup
- Service status verification

### 3. Interactive Testing
Manual testing in isolated environment:
- Full shell access to test container
- Manual execution of lemptool commands
- Debugging and troubleshooting

## Test Results

Test results are stored in `testing/results/test-results.log` with timestamps and pass/fail status for each OS version.

## Environment Details

Each Docker container includes:
- Fresh OS installation (Ubuntu/Debian)
- sudo-enabled test user
- Basic development tools
- systemctl for service management
- All lemptool scripts and dependencies

## Supported Operating Systems

| OS Version | Container Name | Docker Image |
|------------|----------------|--------------|
| Ubuntu 18.04 | ubuntu18-test | ubuntu:18.04 |
| Ubuntu 20.04 | ubuntu20-test | ubuntu:20.04 |
| Ubuntu 22.04 | ubuntu22-test | ubuntu:22.04 |
| Ubuntu 24.04 | ubuntu24-test | ubuntu:24.04 |
| Debian 11 | debian11-test | debian:11 |
| Debian 12 | debian12-test | debian:12 |

## Best Practices

1. **Run tests before commits**: Ensure changes work across all supported OS versions
2. **Use interactive mode for debugging**: When tests fail, use interactive sessions to debug
3. **Test incrementally**: Test individual components before full installation
4. **Clean up regularly**: Remove unused containers and images to save disk space
5. **Check logs**: Review test results in the logs for patterns or recurring issues

## Troubleshooting

### Common Issues

**Permission denied errors**:
```bash
chmod +x testing/docker-test.sh
chmod +x lemptool
```

**Docker not running**:
```bash
sudo systemctl start docker
```

**Out of disk space**:
```bash
./testing/docker-test.sh clean
docker system prune -a
```

**Container startup failures**:
- Check Docker logs: `docker logs <container_name>`
- Verify Dockerfile syntax
- Ensure base images are available

### Debug Mode

For verbose output during testing:
```bash
# Enable debug mode in the test script
export DEBUG=1
./testing/docker-test.sh test ubuntu22
```

## CI/CD Integration

The testing environment can be integrated into CI/CD pipelines:

```yaml
## 📊 Test Reporting and Results

### Comprehensive Test Reports
The framework provides detailed reporting including:

```bash
================================================
 COMPREHENSIVE TEST REPORT 
================================================
System Information:
  Host OS: Ubuntu 24.04.2 LTS
  Docker: Docker version 28.3.2, build 578ccf6
  Date: Fri Jul 11 05:46:55 PM -05 2025

Unit Test Results:
  ubuntu18: PASSED
  ubuntu20: PASSED  
  ubuntu22: PASSED
  ubuntu24: PASSED
  debian11: PASSED
  debian12: PASSED

End-to-End Test Results:
  ubuntu18: PASSED
  ubuntu20: PASSED
  ubuntu22: PASSED
  ubuntu24: PASSED
  debian11: PASSED
  debian12: PASSED

Overall Test Status:
  ubuntu18: ALL TESTS PASSED
  ubuntu20: ALL TESTS PASSED
  ubuntu22: ALL TESTS PASSED
  ubuntu24: ALL TESTS PASSED
  debian11: ALL TESTS PASSED
  debian12: ALL TESTS PASSED

Summary:
  Unit Tests - Passed: 6, Failed: 0
  E2E Tests - Passed: 6, Failed: 0
  Overall - Passed: 6, Failed: 0
🎉 ALL TESTS PASSED ACROSS ALL OPERATING SYSTEMS! 🎉
```

### Performance Metrics
- Test execution times per OS
- Resource usage statistics  
- Performance benchmarks for critical operations
- Cross-OS performance comparison

## 🔧 Development and Debugging

### Interactive Development
```bash
# Start interactive debugging session
./testing/docker-test.sh interactive ubuntu22

# Enable debug mode for comprehensive testing
bash -x ./testing/comprehensive-test.sh

# Test specific functions during development
./testing/unit-tests.sh

# Test specific workflows during development  
./testing/e2e-tests.sh
```

### Test Development Guidelines
1. **Unit Tests**: Focus on individual function behavior and edge cases
2. **E2E Tests**: Test complete user workflows and real-world scenarios
3. **Container Compatibility**: Ensure tests work in both container and bare-metal environments
4. **Mock Dependencies**: Use appropriate mocking for external services in unit tests
5. **Error Handling**: Test both success and failure scenarios comprehensively
6. **Documentation**: Document test purpose, expected behavior, and any special requirements

## 🚀 Continuous Integration Integration

### GitHub Actions Integration
```yaml
name: Comprehensive LEMP Tool Testing
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test_type: [unit, e2e, all]
    steps:
      - uses: actions/checkout@v2
      - name: Run ${{ matrix.test_type }} tests
        run: ./testing/comprehensive-test.sh ${{ matrix.test_type }}
```

### Jenkins Integration
```groovy
pipeline {
    agent any
    stages {
        stage('Unit Tests') {
            steps {
                sh './testing/comprehensive-test.sh unit'
            }
        }
        stage('E2E Tests') {
            steps {
                sh './testing/comprehensive-test.sh e2e'
            }
        }
        stage('Cross-OS Validation') {
            steps {
                sh './testing/comprehensive-test.sh all'
            }
        }
    }
}
```

## 🛠️ Prerequisites and Requirements

### System Requirements
- **Docker**: Installed and running (for cross-OS testing)
- **Bash**: Version 4.0 or later
- **Basic Tools**: `bc` command (for performance calculations)
- **Permissions**: Docker group membership (for container testing)
- **Disk Space**: Sufficient space for Docker images (~2GB per OS)

### Testing Requirements  
- **Network Access**: Internet connectivity for package downloads in containers
- **Sudo Access**: Required for some installation tests (when not in container)
- **Memory**: Minimum 2GB RAM for concurrent testing

### Optional Tools
- **Docker Compose**: For orchestrated testing (not required)
- **Git**: For version control and CI/CD integration

## 📝 Troubleshooting

### Common Issues and Solutions

#### Docker Permission Errors
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Logout and login again, or run:
newgrp docker
```

#### Container Build Failures
```bash
# Clean Docker cache and rebuild
./testing/docker-test.sh clean
docker system prune -f
./testing/comprehensive-test.sh --os ubuntu22
```

#### Network Issues in Containers
```bash
# Check Docker daemon status
sudo systemctl status docker

# Restart Docker if needed
sudo systemctl restart docker
```

#### Test Failures
```bash
# Run with debug mode for detailed output
bash -x ./testing/comprehensive-test.sh unit

# Test specific OS to isolate issues
./testing/comprehensive-test.sh unit --os ubuntu22

# Run individual test components
./testing/unit-tests.sh
./testing/e2e-tests.sh
```

#### Disk Space Issues
```bash
# Clean up Docker images and containers
./testing/docker-test.sh clean
docker system df  # Check disk usage
docker system prune -a  # Remove unused images
```

## 🔮 Future Enhancements

### Planned Improvements
- **Parallel Test Execution**: Run tests across multiple OS versions simultaneously
- **Test Result Caching**: Cache results to speed up development workflows  
- **Custom Test Configurations**: Support for user-defined test configurations
- **Integration Testing**: Enhanced integration tests for external services
- **Security Testing**: Automated security validation tests
- **Load Testing**: Performance and scalability testing scenarios
- **Visual Test Reports**: HTML-based test result dashboards

### Contributing to Tests
1. **Add Unit Tests**: For new functions in `lemptool_scripts`
2. **Add E2E Tests**: For new workflows and user features
3. **Improve Coverage**: Identify and test edge cases
4. **Performance Tests**: Add benchmarks for critical operations
5. **Documentation**: Update test documentation for new features

---

This comprehensive testing framework ensures that all Native LEMP Tool functionalities work correctly across all supported operating systems, providing confidence in reliability, compatibility, and maintainability.
