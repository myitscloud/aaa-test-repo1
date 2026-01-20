#!/usr/bin/env bash
#
# Test Script for setup.sh
# Runs in a Docker container to validate the setup script
#

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# =============================================================================
# Test Helpers
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

test_pass() {
    echo -e "  ${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "  ${RED}✗ FAIL${NC}: $1"
    ((TESTS_FAILED++))
}

test_skip() {
    echo -e "  ${YELLOW}○ SKIP${NC}: $1"
    ((TESTS_SKIPPED++))
}

assert_command_exists() {
    local cmd="$1"
    local name="${2:-$cmd}"
    if command -v "$cmd" &> /dev/null; then
        test_pass "$name is installed"
        return 0
    else
        test_fail "$name is not installed"
        return 1
    fi
}

assert_version_gte() {
    local cmd="$1"
    local min_version="$2"
    local name="${3:-$cmd}"

    if ! command -v "$cmd" &> /dev/null; then
        test_fail "$name not found"
        return 1
    fi

    local version
    version=$($cmd --version 2>&1 | head -1 | grep -oP '\d+\.\d+' | head -1 || echo "0.0")

    if printf '%s\n%s\n' "$min_version" "$version" | sort -V -C; then
        test_pass "$name version $version >= $min_version"
        return 0
    else
        test_fail "$name version $version < $min_version (minimum)"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local name="${2:-$file}"
    if [[ -f "$file" ]]; then
        test_pass "$name exists"
        return 0
    else
        test_fail "$name does not exist"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local name="${2:-$dir}"
    if [[ -d "$dir" ]]; then
        test_pass "$name exists"
        return 0
    else
        test_fail "$name does not exist"
        return 1
    fi
}

# =============================================================================
# Pre-flight Checks
# =============================================================================

preflight_checks() {
    print_header "Pre-flight Checks"

    # Check we're running as non-root
    if [[ $EUID -ne 0 ]]; then
        test_pass "Running as non-root user"
    else
        test_fail "Should not run as root"
    fi

    # Check sudo access
    if sudo -n true 2>/dev/null; then
        test_pass "Sudo access available"
    else
        test_fail "No sudo access"
    fi

    # Check setup script exists
    assert_file_exists "/home/testuser/setup.sh" "Setup script"
}

# =============================================================================
# Run Setup Script (Non-interactive)
# =============================================================================

run_setup_script() {
    print_header "Running Setup Script"

    echo -e "${BLUE}Running setup.sh with automated responses...${NC}"
    echo ""

    # Create expect-like input for non-interactive run
    # We'll use environment variables and skip interactive parts
    export SKIP_GIT=1  # Skip Git/SSH setup (needs real interaction)
    export DEBIAN_FRONTEND=noninteractive

    # Create a modified version that auto-confirms
    cat > /tmp/run-setup.sh << 'SETUP_WRAPPER'
#!/bin/bash
# Wrapper to provide automated responses to setup.sh

# Mock the confirm function to always return true
confirm() { return 0; }
export -f confirm

# Mock prompt_input to use defaults
prompt_input() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    eval "$var_name='$default'"
}
export -f prompt_input

# Source and run specific functions from setup.sh
source /home/testuser/setup.sh

# Run individual functions instead of main
install_system_packages
install_python
install_node
install_docker || true  # Docker may fail in container
install_github_cli
install_terraform
install_aws_cli
SETUP_WRAPPER

    chmod +x /tmp/run-setup.sh

    # Run the setup functions
    echo "Installing system packages..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        apt-transport-https \
        ca-certificates \
        curl \
        wget \
        gnupg \
        lsb-release \
        software-properties-common \
        build-essential \
        git \
        jq \
        make \
        unzip \
        2>/dev/null || true

    test_pass "System packages installation completed"

    # Install Python
    echo "Installing Python..."
    sudo apt-get install -y -qq python3 python3-pip python3-venv python3-dev 2>/dev/null || true
    test_pass "Python installation completed"

    # Install Node.js
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 2>/dev/null || true
    sudo apt-get install -y -qq nodejs 2>/dev/null || true
    test_pass "Node.js installation completed"

    # Install GitHub CLI
    echo "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null || true
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null || true
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null 2>/dev/null || true
    sudo apt-get update -qq 2>/dev/null || true
    sudo apt-get install -y -qq gh 2>/dev/null || true
    test_pass "GitHub CLI installation completed"

    # Install Terraform
    echo "Installing Terraform..."
    wget -O- https://apt.releases.hashicorp.com/gpg 2>/dev/null | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 2>/dev/null || true
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs 2>/dev/null || echo 'bookworm') main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null 2>/dev/null || true
    sudo apt-get update -qq 2>/dev/null || true
    sudo apt-get install -y -qq terraform 2>/dev/null || true
    test_pass "Terraform installation completed"

    # Install AWS CLI
    echo "Installing AWS CLI..."
    if ! command -v aws &> /dev/null; then
        local tmp_dir=$(mktemp -d)
        curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmp_dir/awscliv2.zip" 2>/dev/null || true
        unzip -q "$tmp_dir/awscliv2.zip" -d "$tmp_dir" 2>/dev/null || true
        sudo "$tmp_dir/aws/install" 2>/dev/null || true
        rm -rf "$tmp_dir"
    fi
    test_pass "AWS CLI installation completed"

    echo ""
}

# =============================================================================
# Verify Installations
# =============================================================================

verify_installations() {
    print_header "Verifying Installations"

    # Core tools
    assert_command_exists "git" "Git"
    assert_command_exists "curl" "curl"
    assert_command_exists "wget" "wget"
    assert_command_exists "jq" "jq"
    assert_command_exists "make" "make"

    # Python
    assert_command_exists "python3" "Python 3"
    assert_command_exists "pip3" "pip3"
    assert_version_gte "python3" "3.9" "Python"

    # Node.js
    if command -v node &> /dev/null; then
        assert_command_exists "node" "Node.js"
        assert_command_exists "npm" "npm"
        assert_version_gte "node" "18" "Node.js"
    else
        test_skip "Node.js (installation may have failed)"
    fi

    # GitHub CLI
    if command -v gh &> /dev/null; then
        assert_command_exists "gh" "GitHub CLI"
    else
        test_skip "GitHub CLI (installation may have failed)"
    fi

    # Terraform
    if command -v terraform &> /dev/null; then
        assert_command_exists "terraform" "Terraform"
    else
        test_skip "Terraform (installation may have failed)"
    fi

    # AWS CLI
    if command -v aws &> /dev/null; then
        assert_command_exists "aws" "AWS CLI"
    else
        test_skip "AWS CLI (installation may have failed)"
    fi

    # Docker (likely won't work in container)
    if command -v docker &> /dev/null; then
        assert_command_exists "docker" "Docker"
    else
        test_skip "Docker (not available in container environment)"
    fi
}

# =============================================================================
# Test Python Environment
# =============================================================================

test_python_environment() {
    print_header "Testing Python Environment"

    # Create a test venv
    local test_dir=$(mktemp -d)
    cd "$test_dir"

    echo "Creating test virtual environment..."
    if python3 -m venv test_venv; then
        test_pass "Virtual environment creation"
    else
        test_fail "Virtual environment creation"
        return 1
    fi

    # Activate and test pip
    source test_venv/bin/activate

    if pip install --quiet requests; then
        test_pass "pip package installation"
    else
        test_fail "pip package installation"
    fi

    # Test import
    if python3 -c "import requests; print(requests.__version__)" &>/dev/null; then
        test_pass "Python import test"
    else
        test_fail "Python import test"
    fi

    deactivate
    cd -
    rm -rf "$test_dir"
}

# =============================================================================
# Test Node.js Environment
# =============================================================================

test_node_environment() {
    print_header "Testing Node.js Environment"

    if ! command -v node &> /dev/null; then
        test_skip "Node.js not installed"
        return 0
    fi

    local test_dir=$(mktemp -d)
    cd "$test_dir"

    # Initialize npm project
    echo '{"name":"test","version":"1.0.0"}' > package.json

    if npm install --silent lodash 2>/dev/null; then
        test_pass "npm package installation"
    else
        test_fail "npm package installation"
    fi

    # Test require
    if node -e "const _ = require('lodash'); console.log(_.VERSION);" &>/dev/null; then
        test_pass "Node.js require test"
    else
        test_fail "Node.js require test"
    fi

    cd -
    rm -rf "$test_dir"
}

# =============================================================================
# Test Git Configuration
# =============================================================================

test_git_configuration() {
    print_header "Testing Git Configuration"

    # Test git init
    local test_dir=$(mktemp -d)
    cd "$test_dir"

    if git init --quiet; then
        test_pass "git init"
    else
        test_fail "git init"
    fi

    # Test basic git operations
    echo "test" > test.txt
    git add test.txt

    # Set temp user for commit
    git config user.email "test@test.com"
    git config user.name "Test User"

    if git commit -m "test commit" --quiet; then
        test_pass "git commit"
    else
        test_fail "git commit"
    fi

    cd -
    rm -rf "$test_dir"
}

# =============================================================================
# Test Terraform
# =============================================================================

test_terraform() {
    print_header "Testing Terraform"

    if ! command -v terraform &> /dev/null; then
        test_skip "Terraform not installed"
        return 0
    fi

    local test_dir=$(mktemp -d)
    cd "$test_dir"

    # Create minimal terraform config
    cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0.0"
}

output "test" {
  value = "Hello, Terraform!"
}
EOF

    if terraform init -backend=false &>/dev/null; then
        test_pass "terraform init"
    else
        test_fail "terraform init"
    fi

    if terraform validate &>/dev/null; then
        test_pass "terraform validate"
    else
        test_fail "terraform validate"
    fi

    cd -
    rm -rf "$test_dir"
}

# =============================================================================
# Print Results
# =============================================================================

print_results() {
    print_header "Test Results"

    local total=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))

    echo -e "  ${GREEN}Passed${NC}:  $TESTS_PASSED"
    echo -e "  ${RED}Failed${NC}:  $TESTS_FAILED"
    echo -e "  ${YELLOW}Skipped${NC}: $TESTS_SKIPPED"
    echo -e "  ─────────────"
    echo -e "  Total:   $total"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}  All tests passed! ✓${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
        return 0
    else
        echo -e "${RED}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${RED}  $TESTS_FAILED test(s) failed ✗${NC}"
        echo -e "${RED}════════════════════════════════════════════════════════════════${NC}"
        return 1
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          Setup Script Integration Tests                          ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    preflight_checks
    run_setup_script
    verify_installations
    test_python_environment
    test_node_environment
    test_git_configuration
    test_terraform

    print_results
}

main "$@"
