# Native LEMP Tool

This script is a handful tool when you need a php enviroment (development or production) but with all the binaries installed natively in your operative system, no docker no vagrant, this is also a ideal tool to setup php servers on linux

lemptool is a rewrite of the the old dead [xnmp](https://github.com/lemyskaman/xnmp) bash script tool, with more reobust functionalities.

This script is compatible only for debian and ubuntu it uses [sury php repos](https://deb.sury.org/) to allow you install multiple php versions on the same machine. 

The php installation option on this package also install commons php libraries for laravel projects, and is intend for nginx with fpm usage.

## 🏗️ Architecture & Best Practices

This tool is designed around **PHP-FPM (FastCGI Process Manager)** architecture, providing better performance, security, and resource isolation compared to old traditional mod_php "bare metal" setups.

### 🔒 **Recommended Approach: One User Per Project**

For optimal security and isolation on bare metal servers, this tool follows the **one OS user per project** pattern:

- **Each project runs under its own OS user** (e.g., `project1`, `myapp`, `laravel`)
- **Dedicated PHP-FPM pool** per user/project for process isolation
- **Separate file permissions** preventing cross-project access
- **Individual Nginx virtual hosts** with proper user context
- **Database isolation** with project-specific database users

**Benefits:**
- ✅ **Security**: Projects cannot access each other's files
- ✅ **Resource Control**: Per-project resource limits via FPM pools
- ✅ **Debugging**: Easier to identify which project causes issues
- ✅ **Maintenance**: Independent updates and configurations per project
- ✅ **Scalability**: Easy to migrate individual projects to containers later

**Example Structure:**
```
/var/www/
├── project1/          # OS user: project1
│   └── domain1.com/
├── myapp/             # OS user: myapp  
│   └── myapp.local/
└── laravel/           # OS user: laravel
    └── laravel-app.com/
```

## 🚀 Usage

### Quick Start

Clone the repository and navigate to the project folder:

```bash
git clone https://github.com/kamansoft/native-lemp-tool.git 
cd native-lemp-tool
```

### 🏁 Complete LEMP Stack Installation

Install the complete LEMP stack (Linux, Nginx, MariaDB, PHP) with Laravel development tools:

```bash
# Interactive installation with confirmations
sudo ./lemptool -i

# Automated installation (skip confirmations)
sudo ./lemptool -i -y
```

**What gets installed:**
- Nginx web server
- PHP 8.3 with FPM and Laravel extensions
- MariaDB database server
- Composer package manager
- Development tools (Git, Node.js, npm)

### 📦 Individual Component Installation

#### Install Specific PHP Version
```bash
# Install PHP 8.2 with Laravel development packages
sudo ./lemptool -p=8.2

# Install PHP 8.1 
sudo ./lemptool -p=8.1

# Skip confirmations
sudo ./lemptool -p=8.3 -y
```

#### Install Nginx
```bash
sudo ./lemptool -ng
```

#### Install MariaDB
```bash
sudo ./lemptool -mdb
```

#### Install System Packages
```bash
# Install multiple packages
sudo ./lemptool -pki=htop nodejs git curl

# Install single package
sudo ./lemptool -pki=vim
```

### 🔧 Advanced Configuration

#### Create PHP-FPM Pool
```bash
# Create FPM pool for existing user
sudo ./lemptool -fpm=username

# Example: Create pool for 'developer' user
sudo ./lemptool -fpm=developer
```

#### Create Nginx Server Configuration
```bash
# Create Nginx server with FPM integration
sudo ./lemptool --fpm-ng-server-create="pool-name" "domain.local" "/var/www/project"

# Example: Laravel project setup
sudo ./lemptool --fpm-ng-server-create="myapp" "myapp.local" "/var/www/myapp/public"
```

#### Database User Management
```bash
# Create database user with dedicated database
sudo ./lemptool --mariadb-user-db-create=dbuser password localhost

# Create database superuser
sudo ./lemptool --mariadb-superuser-create=admin strongpassword localhost
```

### 🎯 Complete Development Environment

Create a full development environment for an OS user with one command:

```bash
# Creates: user directory, FPM pool, Nginx server, database, and sample files
sudo ./lemptool -lemp="developer" "myproject.local" "database_password"
```

**This command will:**
1. Create `/var/www/developer/myproject.local/` directory
2. Set up PHP-FPM pool for the user
3. Configure Nginx server for the domain
4. Create database user and database
5. Generate sample `index.php` file
6. Set proper file permissions

#### Install phpMyAdmin
```bash
# Installs phpMyAdmin with dedicated FPM pool and Nginx configuration
sudo ./lemptool --phpmyadmin-install
```

### 🛠️ Command Options

#### Global Options
- `-y` : Skip all confirmation prompts (use with any command)

#### Available Commands
| Command | Description | Example |
|---------|-------------|---------|
| `-i, --install` | Complete LEMP stack installation | `sudo ./lemptool -i` |
| `-p=, --php-install=` | Install specific PHP version | `sudo ./lemptool -p=8.2` |
| `-ng, --nginx-install` | Install Nginx web server | `sudo ./lemptool -ng` |
| `-mdb, --mariadb-install` | Install MariaDB database | `sudo ./lemptool -mdb` |
| `-pki=, --package-install=` | Install system packages | `sudo ./lemptool -pki=git nodejs` |
| `-fpm=, --php-fpm-create=` | Create PHP-FPM pool | `sudo ./lemptool -fpm=username` |
| `--fpm-ng-server-create` | Create Nginx+FPM server | `sudo ./lemptool --fpm-ng-server-create="pool" "domain" "/path"` |
| `-lemp=` | Complete dev environment | `sudo ./lemptool -lemp="user" "domain" "dbpass"` |
| `--mariadb-user-db-create` | Create DB user+database | `sudo ./lemptool --mariadb-user-db-create=user pass host` |
| `--mariadb-superuser-create` | Create DB superuser | `sudo ./lemptool --mariadb-superuser-create=user pass host` |
| `--phpmyadmin-install` | Install phpMyAdmin | `sudo ./lemptool --phpmyadmin-install` |
| `--help` | Show detailed help | `sudo ./lemptool --help` |

### 💡 Common Usage Patterns

#### Laravel Development Setup
```bash
# 1. Install complete LEMP stack
sudo ./lemptool -i -y

# 2. Create development environment for Laravel project
sudo ./lemptool -lemp="laravel" "myapp.local" "secret123"

# 3. Add domain to hosts file (manual step)
echo "127.0.0.1 myapp.local" | sudo tee -a /etc/hosts
```

#### Multiple PHP Versions
```bash
# Install multiple PHP versions for testing
sudo ./lemptool -p=8.1 -y
sudo ./lemptool -p=8.2 -y  
sudo ./lemptool -p=8.3 -y

# Create separate FPM pools for different projects
sudo ./lemptool -fpm=project81  # Uses system default PHP
sudo ./lemptool -fpm=project82  # Uses system default PHP
```

#### Production Server Setup
```bash
# Install with minimal confirmations for automated deployment
sudo ./lemptool -i -y
sudo ./lemptool -lemp="production" "example.com" "$(openssl rand -base64 32)"
```

For detailed documentation, see the [docs/](docs/) folder.

## 📚 Documentation

### Extended Documentation

- **[Compatibility Guide](docs/compatibility-guide.md)** - Cross-OS compatibility features and system requirements
- **[Testing Framework](docs/testing-environment.md)** - Comprehensive testing documentation and usage guide
- **[Testing Summary](docs/testing-summary.md)** - Quick overview of testing capabilities and setup

### Development Resources

- **[Testing README](testing/README.md)** - Complete testing framework documentation
- **[Compatibility Matrix](#-php-version-compatibility-matrix)** - PHP/MariaDB version compatibility per OS
- **[Development Guidelines](#development-guidelines)** - Code quality standards and workflow

### Command Reference

For complete command reference and help:
```bash
sudo ./lemptool --help
```

## Requirements

### System Requirements
- **OS**: Ubuntu (18.04, 20.04, 22.04, 24.04) or Debian (11, 12)
- **Architecture**: x86_64 (amd64)
- **Memory**: Minimum 2GB RAM
- **Disk Space**: At least 2GB free space
- **Network**: Internet connection for package downloads

### Prerequisites
- **Root Access**: Script must be run with `sudo`
- **Package Manager**: `apt` package manager
- **Basic Tools**: `curl` or `wget`, `lsb-release`, `gnupg`

## Comprehensive Testing Framework

This project includes a robust three-tier testing framework that validates all functionalities across multiple operating systems:

### 🧪 **Testing Levels**

1. **Unit Tests** - Test individual functions in `lemptool_scripts`
2. **End-to-End Tests** - Test complete workflows and user scenarios  
3. **Cross-OS Compatibility** - Validate across all supported operating systems

### 🖥️ **Supported Testing Platforms**

- **Ubuntu**: 18.04, 20.04, 22.04, 24.04
- **Debian**: 11, 12

### 🚀 **Quick Testing**

```bash
# Run comprehensive tests across all OS versions
./testing/comprehensive-test.sh

# Run only unit tests across all operating systems
./testing/comprehensive-test.sh unit

# Run only end-to-end tests across all operating systems  
./testing/comprehensive-test.sh e2e

# Test specific operating system
./testing/comprehensive-test.sh --os ubuntu22

# Run tests locally (without Docker)
./testing/comprehensive-test.sh local-unit
./testing/comprehensive-test.sh local-e2e
```

### 📊 **Test Coverage**

- **Unit Tests**: 19 tests covering all core functions
- **E2E Tests**: 47 tests covering complete workflows
- **Cross-OS**: 100% compatibility across 6 operating systems
- **Success Rate**: 100% (123 assertions per OS)

### 🔧 **Individual Test Scripts**

```bash
# Direct unit testing
./testing/unit-tests.sh

# Direct end-to-end testing
./testing/e2e-tests.sh

# Docker-based testing for specific OS
./testing/docker-test.sh test ubuntu22 unit
./testing/docker-test.sh test debian12 e2e
./testing/docker-test.sh interactive ubuntu20
```

For comprehensive testing documentation, see [testing/README.md](testing/README.md).

## Development Guidelines

### 🔄 **Testing Requirements**
- **Always test changes** across multiple OS versions using the testing framework
- **Unit test coverage** for all new functions in `lemptool_scripts`
- **E2E test coverage** for all new workflows and user-facing features
- **Cross-OS validation** required before merging changes

### 🛠️ **Development Workflow**
```bash
# 1. Run comprehensive tests before starting development
./testing/comprehensive-test.sh

# 2. Make your changes to the codebase
# ... edit files ...

# 3. Test specific functionality during development
./testing/unit-tests.sh                    # Test function changes
./testing/e2e-tests.sh                     # Test workflow changes

# 4. Test on specific OS if targeting specific compatibility
./testing/docker-test.sh interactive ubuntu22

# 5. Run full test suite before committing
./testing/comprehensive-test.sh all

# 6. Validate test results show 100% success rate
```

### 📋 **Code Quality Standards**
- Follow bash best practices and coding guidelines
- Ensure container-safe operations (detect environment appropriately)
- Handle errors gracefully with meaningful messages
- Maintain backward compatibility across supported OS versions
- Document new functions and workflows

### 🐛 **Debugging Guidelines**
- Use interactive Docker sessions for debugging: `./testing/docker-test.sh interactive [os]`
- Enable debug mode: `bash -x ./testing/comprehensive-test.sh`
- Check individual test outputs in `testing/` directory
- Validate cross-OS compatibility before finalizing changes

## Compatibility Improvements

This project has been enhanced for full compatibility across all supported operating systems:

### ✅ **Enhanced OS Support**
- **Ubuntu**: 18.04 (Bionic), 20.04 (Focal), 22.04 (Jammy), 24.04 (Noble)
- **Debian**: 11 (Bullseye), 12 (Bookworm)

### ✅ **Key Compatibility Features**
- **Smart OS Detection** - Automatically detects OS version and adjusts behavior
- **Version-Aware Package Installation** - Uses compatible PHP/MariaDB versions per OS
- **Container-Safe Operations** - Works in Docker containers and bare metal
- **Enhanced Service Management** - Handles systemctl variations across environments
- **Safe User Creation** - Compatible user creation across all OS versions
- **Improved Error Handling** - Graceful fallbacks and better error messages

### ✅ **Comprehensive Testing Framework**
```bash
# Run complete test suite across all operating systems
./testing/comprehensive-test.sh all

# Test individual components
./testing/unit-tests.sh                    # Function-level testing
./testing/e2e-tests.sh                     # Workflow testing
./testing/docker-test.sh test ubuntu22     # OS-specific testing
```

**Test Results**: 100% success rate across all 6 operating systems
- **Unit Tests**: 19 tests, 35 assertions per OS
- **E2E Tests**: 47 tests, 88 assertions per OS  
- **Total Coverage**: 66 tests, 123 assertions per OS version

### ✅ **PHP Version Compatibility Matrix**
| OS Version | Compatible PHP Versions |
|------------|------------------------|
| Ubuntu 18.04 | 7.2, 7.3, 7.4, 8.0, 8.1, 8.2 |
| Ubuntu 20.04 | 7.4, 8.0, 8.1, 8.2, 8.3 |
| Ubuntu 22.04 | 8.0, 8.1, 8.2, 8.3 |
| Ubuntu 24.04 | 8.0, 8.1, 8.2, 8.3 |
| Debian 11 | 7.4, 8.0, 8.1, 8.2, 8.3 |
| Debian 12 | 8.1, 8.2, 8.3 |

### ✅ **MariaDB Version Compatibility**
| OS Version | Recommended MariaDB Version |
|------------|---------------------------|
| Ubuntu 18.04 | 10.3 |
| Ubuntu 20.04 | 10.5 |
| Ubuntu 22.04 | 10.6 |
| Ubuntu 24.04 | 11.0 |
| Debian 11 | 10.5 |
| Debian 12 | 10.11 |



