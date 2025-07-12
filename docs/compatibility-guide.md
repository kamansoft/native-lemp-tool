# Compatibility Guide

This document details the compatibility improvements made to ensure Native LEMP Tool works reliably across all supported Ubuntu and Debian versions.

## Overview of Compatibility Issues Addressed

### 1. Operating System Detection
**Problem**: Different methods needed to detect OS versions across Ubuntu/Debian releases.
**Solution**: Enhanced detection using multiple fallback methods:
- `lsb_release` (primary)
- `/etc/os-release` (fallback)
- Version name normalization

### 2. Package Management
**Problem**: Package availability varies between OS versions.
**Solution**: 
- Smart package installation with error handling
- Optional package installation (e.g., `php-xdebug`, `php-imagick`)
- Compatibility matrix for PHP/MariaDB versions

### 3. Service Management
**Problem**: `systemctl` behavior differs between bare metal and containers.
**Solution**: Universal service manager function:
```bash
service_manager start nginx
service_manager restart "php8.2-fpm"
service_manager status mariadb
```

### 4. User Creation
**Problem**: `adduser` vs `useradd` differences and Docker limitations.
**Solution**: Safe user creation function that handles:
- Interactive vs non-interactive environments
- Docker container limitations
- Group membership setup

### 5. Repository Management
**Problem**: GPG key handling and repository URLs vary.
**Solution**: Enhanced repository functions with proper error handling.

## Compatibility Functions Reference

### OS Detection
```bash
get_os_info_enhanced()
```
- Detects OS name and version using multiple methods
- Normalizes version names for consistency
- Sets `CURRENT_DISTRO_NAME` and `CURRENT_DISTRO_VERSION`

### Environment Detection
```bash
detect_environment()
```
- Detects container vs bare metal environment
- Sets `LEMPTOOL_ENVIRONMENT` variable
- Adjusts behavior accordingly

### Service Management
```bash
service_manager <action> <service>
```
Actions: `start`, `stop`, `restart`, `enable`, `disable`, `status`
- Works in containers and bare metal
- Graceful fallbacks for different init systems

### Safe User Creation
```bash
create_user_safe <username> [create_home]
```
- Creates users safely across all environments
- Handles Docker container limitations
- Sets up proper group membership

### Package Installation
```bash
install_packages_safe [-y] <packages...>
```
- Enhanced error handling
- Automatic package list updates
- Handles missing packages gracefully

### Repository Management
```bash
validate_repository_safe <repo_url>
add_gpg_key_safe <key_url> <key_path>
```
- Safe repository validation
- Secure GPG key handling

### Version Compatibility
```bash
get_compatible_php_versions()
get_compatible_mariadb_version()
```
- Returns compatible versions for current OS
- Used for automatic version selection

## OS-Specific Compatibility Notes

### Ubuntu 18.04 (Bionic)
- Limited to older PHP versions (7.2-8.2)
- MariaDB 10.3 recommended
- Legacy repository handling

### Ubuntu 20.04 (Focal)
- Good PHP version support (7.4-8.3)
- MariaDB 10.5 recommended
- Standard repository handling

### Ubuntu 22.04 (Jammy)
- Modern PHP versions (8.0-8.3)
- MariaDB 10.6 recommended
- Updated repository methods

### Ubuntu 24.04 (Noble)
- Latest PHP versions (8.0-8.3)
- MariaDB 11.0 with special repository setup
- New repository setup script required

### Debian 11 (Bullseye)
- PHP 7.4-8.3 support
- MariaDB 10.5 recommended
- Sury repository compatibility

### Debian 12 (Bookworm)
- Modern PHP versions (8.1-8.3)
- MariaDB 10.11 recommended
- Latest repository methods

## Container Environment Considerations

### Docker-Specific Adaptations
1. **Service Management**: Services may not actually start in containers
2. **User Creation**: Uses `useradd` instead of interactive `adduser`
3. **Permission Handling**: Adjusted for container security models
4. **Error Tolerance**: More lenient error handling for testing environments

### Environment Variables
- `LEMPTOOL_ENVIRONMENT`: Set to "container" or "bare_metal"
- `DOCKER_CONTAINER`: Detected automatically
- `CURRENT_DISTRO_NAME`: Normalized OS name
- `CURRENT_DISTRO_VERSION`: Normalized version

## Testing Compatibility

### Basic Compatibility Test
```bash
# Test on specific OS
./testing/compatibility-test.sh functions ubuntu22

# Test improved scripts
./testing/compatibility-test.sh scripts debian11
```

### Comprehensive Testing
```bash
# Test all OS versions
./testing/compatibility-test.sh all
```

### Manual Testing
```bash
# Interactive session for manual testing
./testing/docker-test.sh interactive ubuntu18
```

## Troubleshooting Compatibility Issues

### Common Issues and Solutions

1. **Package Not Found**
   - Check OS compatibility matrix
   - Use optional package installation
   - Verify repository setup

2. **Service Start Failures**
   - Check if running in container
   - Verify service manager compatibility
   - Check for missing dependencies

3. **User Creation Failures**
   - Use `create_user_safe` function
   - Check container environment
   - Verify permissions

4. **Repository Issues**
   - Use enhanced repository functions
   - Check GPG key installation
   - Verify network connectivity

### Debug Mode
Enable debug output for troubleshooting:
```bash
export DEBUG=1
./lemptool -i -y
```

## Best Practices for Compatibility

1. **Always test on target OS** before deployment
2. **Use compatibility functions** instead of direct system calls
3. **Handle errors gracefully** with appropriate fallbacks
4. **Check environment** before performing system operations
5. **Use version-appropriate packages** based on OS detection

## Future Compatibility Considerations

When adding new features:
1. Test on all supported OS versions
2. Use compatibility helper functions
3. Add proper error handling
4. Update compatibility matrices
5. Document OS-specific requirements

This compatibility system ensures Native LEMP Tool works reliably across all supported environments while maintaining the flexibility to adapt to new OS versions and environments.
