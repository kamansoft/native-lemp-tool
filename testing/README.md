# Comprehensive Testing Framework for Native LEMP Tool

This document describes the comprehensive testing framework designed to validate all functionalities of the Native LEMP Tool across all supported operating systems.

## 📋 Testing Overview

The testing framework consists of three levels of testing:

### 1. **Unit Tests** (`testing/unit-tests.sh`)
- Tests individual functions in `lemptool_scripts`
- Validates function behavior, parameter handling, and error conditions
- Mocks external dependencies for isolated testing
- Fast execution, minimal system requirements

### 2. **End-to-End Tests** (`testing/e2e-tests.sh`)
- Tests complete workflows and user scenarios
- Validates integration between components
- Tests actual installations and configurations
- Comprehensive system validation

### 3. **Cross-OS Compatibility Tests** (`testing/comprehensive-test.sh`)
- Orchestrates all tests across supported operating systems
- Provides unified reporting and result aggregation
- Ensures compatibility across different environments

## 🏗️ Test Architecture

```
testing/
├── unit-tests.sh              # Individual function testing
├── e2e-tests.sh               # End-to-end workflow testing
├── comprehensive-test.sh      # Cross-OS test orchestrator
├── docker-test.sh             # Docker-based testing infrastructure
└── results/                   # Test execution results and logs
```

## 🖥️ Supported Operating Systems

The framework tests across 6 different operating system versions:

- **Ubuntu**: 18.04, 20.04, 22.04, 24.04
- **Debian**: 11, 12

Each OS version is tested in isolated Docker containers to ensure clean, reproducible environments.

## 🧪 Unit Test Coverage

### Core Functions Tested:
- `detect_environment()` - Environment detection (container vs bare-metal)
- `get_os_info_enhanced()` - Operating system identification
- `validate_php_version()` - PHP version validation against OS compatibility
- `check_for_y()` - Command-line flag processing
- `validate_sudo()` - Sudo access verification
- `validate_envsubst()` - Template processing validation
- `get_compatible_php_versions()` - OS-specific PHP version compatibility
- `get_compatible_mariadb_version()` - OS-specific MariaDB version compatibility
- `service_manager()` - Service management abstraction
- `packages_installer()` - Package installation functionality
- `install_packages_safe()` - Safe package installation with error handling

### Template Processing Tests:
- FPM pool template validation
- Nginx server template validation
- LEMP stack template validation
- Environment variable substitution

## 🔄 End-to-End Test Scenarios

### 1. **Help System Validation**
- Tests `--help` and `-help` commands
- Validates usage information display

### 2. **Package Installation Workflows**
- Basic package installation (`-pki=package1 package2`)
- Package availability verification
- Installation error handling

### 3. **Component Installation Tests**
- **Nginx Installation** (`-ng`)
  - Repository setup validation
  - Service configuration
  - Configuration file validation
- **PHP Installation** (`-p=version`)
  - Version-specific installation
  - Extension loading verification
  - Composer installation
  - PHP-FPM configuration
- **MariaDB Installation** (`-mdb`)
  - Database server installation
  - Service initialization
  - Connection testing

### 4. **Configuration Management Tests**
- **FPM Pool Creation** (`-fpm=username`)
  - User validation
  - Pool file generation
  - Service restart verification
- **Nginx Server Creation** (`--fpm-ng-server-create`)
  - Virtual host configuration
  - PHP-FPM integration
  - Configuration validation
- **Database User Management**
  - User creation with database
  - Superuser creation
  - Permission validation

### 5. **Complete LEMP Stack Tests**
- Full stack creation (`-lemp=user domain password`)
- Directory structure validation
- File permissions verification
- Service integration testing

### 6. **phpMyAdmin Installation**
- Complete installation workflow
- Configuration file generation
- Nginx integration
- User creation and permissions

### 7. **Complete Installation Test**
- Full system installation (`-i`)
- All components verification
- Integration validation

### 8. **Error Handling Validation**
- Invalid parameter handling
- Missing dependency detection
- Graceful failure scenarios
- User input validation

### 9. **Performance Testing**
- Command execution time measurement
- Resource usage validation
- Scalability assessment

## 🚀 Usage Examples

### Run All Tests on All Operating Systems
```bash
# Run comprehensive tests across all OS versions (recommended)
./testing/comprehensive-test.sh

# Run only unit tests across all OS versions
./testing/comprehensive-test.sh unit

# Run only end-to-end tests across all OS versions
./testing/comprehensive-test.sh e2e

# Run complete test suite (unit + e2e) across all OS versions
./testing/comprehensive-test.sh all
```

### Test Specific Operating System
```bash
# Test specific OS version (both unit and e2e tests)
./testing/comprehensive-test.sh --os ubuntu22

# Test unit tests only on specific OS
./testing/comprehensive-test.sh unit --os debian12

# Test e2e tests only on specific OS
./testing/comprehensive-test.sh e2e --os ubuntu24
```

### Local Testing (Without Docker)
```bash
# Run unit tests on local system
./testing/comprehensive-test.sh local-unit

# Run e2e tests on local system  
./testing/comprehensive-test.sh local-e2e
```

### Direct Test Execution
```bash
# Run individual test suites directly
./testing/unit-tests.sh
./testing/e2e-tests.sh

# Use Docker for specific OS testing
./testing/docker-test.sh test ubuntu22 unit
./testing/docker-test.sh test debian12 e2e
./testing/docker-test.sh test ubuntu20 both

# Interactive debugging
./testing/docker-test.sh interactive ubuntu22
```

## 📊 Test Reporting

The framework provides comprehensive test reporting including:

### Test Execution Reports
- **Pass/Fail Status**: Clear indication for each test across all operating systems
- **Execution Time**: Performance measurements for all test operations
- **Error Details**: Comprehensive error reporting with context and stack traces
- **System Information**: Environment details and configuration information

### Cross-OS Compatibility Matrix
```
================================================
 COMPREHENSIVE TEST REPORT 
================================================
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
- **Test Execution Times**: Detailed timing for each test operation
- **Resource Usage Statistics**: Memory and CPU usage during testing
- **System Performance Indicators**: Performance benchmarks and comparisons
- **Cross-OS Performance Analysis**: Performance variations across different operating systems

## 🔧 Development and Debugging

### Interactive Testing
```bash
# Start interactive session for debugging
./testing/docker-test.sh interactive ubuntu22

# Build specific OS image for testing
./testing/docker-test.sh build debian12

# Clean up all test containers and images
./testing/docker-test.sh clean
```

### Test Development Guidelines
1. **Unit Tests**: Focus on individual function behavior
2. **E2E Tests**: Test complete user workflows
3. **Mock Dependencies**: Use mocks for external services in unit tests
4. **Container Compatibility**: Ensure tests work in both container and bare-metal environments
5. **Error Handling**: Test both success and failure scenarios
6. **Documentation**: Document test purpose and expected behavior

## 🛠️ Continuous Integration

The testing framework is designed for integration with CI/CD pipelines:

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
        os: [ubuntu18, ubuntu20, ubuntu22, ubuntu24, debian11, debian12]
    steps:
      - uses: actions/checkout@v2
      - name: Run ${{ matrix.test_type }} tests on ${{ matrix.os }}
        run: |
          chmod +x testing/comprehensive-test.sh
          ./testing/comprehensive-test.sh ${{ matrix.test_type }} --os ${{ matrix.os }}
      - name: Upload test results
        uses: actions/upload-artifact@v2
        if: always()
        with:
          name: test-results-${{ matrix.os }}-${{ matrix.test_type }}
          path: testing/results/
```

### Jenkins Integration
```groovy
pipeline {
    agent any
    stages {
        stage('Unit Tests') {
            parallel {
                stage('Unit Tests - All OS') {
                    steps {
                        sh 'chmod +x testing/comprehensive-test.sh'
                        sh './testing/comprehensive-test.sh unit'
                    }
                }
            }
        }
        stage('E2E Tests') {
            parallel {
                stage('E2E Tests - All OS') {
                    steps {
                        sh './testing/comprehensive-test.sh e2e'
                    }
                }
            }
        }
        stage('Complete Validation') {
            steps {
                sh './testing/comprehensive-test.sh all'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'testing/results/**/*', fingerprint: true
            publishTestResults testResultsPattern: 'testing/results/**/*.xml'
        }
    }
}
```

## 🚨 Test Requirements

### System Requirements
- Docker (for cross-OS testing)
- Bash 4.0 or later
- `bc` command (for performance calculations)
- `sudo` access (for installation tests)

### Docker Requirements
- Docker daemon running
- Sufficient disk space for multiple OS images
- Network access for package downloads

## 📝 Troubleshooting

### Common Issues
1. **Docker Permission Errors**: Ensure user is in docker group
2. **Network Issues**: Check internet connectivity for package downloads
3. **Disk Space**: Ensure sufficient space for Docker images
4. **Sudo Access**: Some tests require sudo privileges

### Debug Mode
```bash
# Enable bash debug mode for comprehensive testing
bash -x ./testing/comprehensive-test.sh

# Run individual test components with debug output
bash -x ./testing/unit-tests.sh
bash -x ./testing/e2e-tests.sh

# Test specific OS with verbose output
./testing/comprehensive-test.sh unit --os ubuntu22 --verbose

# Interactive debugging in Docker container
./testing/docker-test.sh interactive ubuntu22
```

### Test Results Location
- **Unit Test Results**: Output directly to console with structured reporting
- **E2E Test Results**: Detailed workflow validation with step-by-step results
- **Comprehensive Reports**: Full cross-OS compatibility matrices
- **Performance Data**: Execution timing and resource usage metrics

## 🔮 Future Enhancements

### Planned Improvements
- **Parallel Test Execution**: Run tests across multiple OS versions simultaneously for faster CI/CD
- **Test Result Caching**: Cache test results to speed up development workflows and avoid redundant testing
- **Custom Test Configurations**: Support for user-defined test configurations and custom test scenarios
- **Integration Testing**: Enhanced integration tests for external services and third-party dependencies
- **Security Testing**: Automated security validation tests for installation procedures and configurations
- **Load Testing**: Performance and scalability testing scenarios for high-load environments
- **Visual Test Reports**: HTML-based test result dashboards with interactive charts and drill-down capabilities
- **Test Coverage Analysis**: Detailed code coverage reports for both unit and integration tests
- **Automated Regression Testing**: Continuous regression testing against previous versions
- **Container Orchestration**: Kubernetes-based testing for cloud-native environments

### Contributing Guidelines
1. **Add Unit Tests**: Create comprehensive unit tests for any new functions in `lemptool_scripts`
2. **Add E2E Tests**: Develop end-to-end tests for new workflows and user-facing features
3. **Improve Coverage**: Identify and test edge cases, error conditions, and boundary scenarios
4. **Performance Tests**: Add benchmarks for critical operations and performance-sensitive functions
5. **Documentation**: Update test documentation and examples for new features and test scenarios
6. **Cross-OS Validation**: Ensure new tests work across all supported operating systems
7. **Container Compatibility**: Verify tests work in both container and bare-metal environments

### Test Development Best Practices
- **Isolation**: Each test should be independent and not rely on the state of other tests
- **Reproducibility**: Tests should produce consistent results across different environments
- **Clarity**: Test names and descriptions should clearly indicate what is being tested
- **Efficiency**: Tests should be optimized for speed while maintaining comprehensive coverage
- **Maintainability**: Tests should be easy to understand, modify, and extend

---

This comprehensive testing framework ensures that all Native LEMP Tool functionalities work correctly across all supported operating systems, providing confidence in the tool's reliability, compatibility, and maintainability across diverse Linux environments.
