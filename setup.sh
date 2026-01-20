#!/usr/bin/env bash
#
# Multi-Agent Template System - Complete Setup Script
# For Debian 13 (Trixie) and compatible systems
#
# This script will:
#   1. Install all required system dependencies
#   2. Configure Git and SSH for GitHub
#   3. Set up the project environment
#   4. Initialize Docker services
#   5. Provide a checklist of remaining manual steps
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/REPO/main/setup.sh | bash
#   OR
#   ./setup.sh
#
# Run with SKIP_* environment variables to skip sections:
#   SKIP_SYSTEM=1 ./setup.sh    # Skip system package installation
#   SKIP_DOCKER=1 ./setup.sh    # Skip Docker installation
#   SKIP_GIT=1 ./setup.sh       # Skip Git/SSH setup

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
SCRIPT_VERSION="1.0.0"
MIN_PYTHON_VERSION="3.9"
MIN_NODE_VERSION="18"
MIN_DOCKER_VERSION="24"
REPO_URL="${REPO_URL:-git@github.com:myitscloud/aaa-test-repo1.git}"
REPO_NAME="${REPO_NAME:-aaa-test-repo1}"
PROJECT_DIR="${PROJECT_DIR:-$HOME/projects/$REPO_NAME}"

# =============================================================================
# Colors and Formatting
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# =============================================================================
# Helper Functions
# =============================================================================

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                                                                  ║"
    echo "║        Multi-Agent Template System - Setup Script v${SCRIPT_VERSION}        ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

confirm() {
    local prompt="$1"
    local default="${2:-y}"

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi

    read -p "$(echo -e "${YELLOW}?${NC} $prompt")" response
    response="${response:-$default}"

    [[ "$response" =~ ^[Yy]$ ]]
}

prompt_input() {
    local prompt="$1"
    local default="${2:-}"
    local var_name="$3"

    if [[ -n "$default" ]]; then
        read -p "$(echo -e "${YELLOW}?${NC} $prompt [$default]: ")" value
        value="${value:-$default}"
    else
        read -p "$(echo -e "${YELLOW}?${NC} $prompt: ")" value
    fi

    eval "$var_name='$value'"
}

command_exists() {
    command -v "$1" &> /dev/null
}

version_gte() {
    # Returns 0 if $1 >= $2
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Do not run this script as root. It will use sudo when needed."
        exit 1
    fi
}

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot detect OS. This script is designed for Debian-based systems."
        exit 1
    fi

    source /etc/os-release

    if [[ "$ID" != "debian" && "$ID_LIKE" != *"debian"* ]]; then
        print_warning "This script is optimized for Debian. Your OS: $ID"
        if ! confirm "Continue anyway?"; then
            exit 1
        fi
    fi

    print_success "Detected OS: $PRETTY_NAME"
}

# =============================================================================
# System Dependencies Installation
# =============================================================================

install_system_packages() {
    print_section "Step 1: System Dependencies"

    if [[ "${SKIP_SYSTEM:-}" == "1" ]]; then
        print_warning "Skipping system package installation (SKIP_SYSTEM=1)"
        return 0
    fi

    print_step "Updating package lists..."
    sudo apt-get update -qq

    print_step "Installing essential packages..."
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
        zip \
        htop \
        tree \
        vim \
        openssl \
        libssl-dev \
        libffi-dev \
        2>/dev/null

    print_success "Essential packages installed"
}

install_python() {
    print_step "Checking Python installation..."

    if command_exists python3; then
        local py_version=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
        if version_gte "$py_version" "$MIN_PYTHON_VERSION"; then
            print_success "Python $py_version is installed (minimum: $MIN_PYTHON_VERSION)"

            # Ensure pip and venv are installed
            sudo apt-get install -y -qq python3-pip python3-venv python3-dev 2>/dev/null
            return 0
        fi
    fi

    print_step "Installing Python ${MIN_PYTHON_VERSION}+..."
    sudo apt-get install -y -qq \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        2>/dev/null

    print_success "Python installed: $(python3 --version)"
}

install_node() {
    print_step "Checking Node.js installation..."

    if command_exists node; then
        local node_version=$(node --version | sed 's/v//' | cut -d'.' -f1)
        if version_gte "$node_version" "$MIN_NODE_VERSION"; then
            print_success "Node.js v$node_version is installed (minimum: v$MIN_NODE_VERSION)"
            return 0
        fi
    fi

    print_step "Installing Node.js ${MIN_NODE_VERSION}+..."

    # Install via NodeSource
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 2>/dev/null
    sudo apt-get install -y -qq nodejs 2>/dev/null

    print_success "Node.js installed: $(node --version)"
    print_success "npm installed: $(npm --version)"
}

install_docker() {
    print_section "Step 2: Docker Installation"

    if [[ "${SKIP_DOCKER:-}" == "1" ]]; then
        print_warning "Skipping Docker installation (SKIP_DOCKER=1)"
        return 0
    fi

    print_step "Checking Docker installation..."

    if command_exists docker; then
        local docker_version=$(docker --version | grep -oP '\d+\.\d+' | head -1)
        if version_gte "$docker_version" "$MIN_DOCKER_VERSION"; then
            print_success "Docker $docker_version is installed (minimum: $MIN_DOCKER_VERSION)"

            # Ensure user is in docker group
            if ! groups | grep -q docker; then
                print_step "Adding user to docker group..."
                sudo usermod -aG docker "$USER"
                print_warning "You may need to log out and back in for docker group to take effect"
            fi
            return 0
        fi
    fi

    print_step "Installing Docker..."

    # Remove old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
        2>/dev/null

    # Add user to docker group
    sudo usermod -aG docker "$USER"

    # Start Docker service
    sudo systemctl enable docker
    sudo systemctl start docker

    print_success "Docker installed: $(docker --version)"
    print_warning "You may need to log out and back in for docker group to take effect"
}

install_github_cli() {
    print_step "Checking GitHub CLI installation..."

    if command_exists gh; then
        print_success "GitHub CLI is installed: $(gh --version | head -1)"
        return 0
    fi

    print_step "Installing GitHub CLI..."

    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq gh 2>/dev/null

    print_success "GitHub CLI installed: $(gh --version | head -1)"
}

install_terraform() {
    print_step "Checking Terraform installation..."

    if command_exists terraform; then
        print_success "Terraform is installed: $(terraform --version | head -1)"
        return 0
    fi

    print_step "Installing Terraform..."

    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 2>/dev/null
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq terraform 2>/dev/null

    print_success "Terraform installed: $(terraform --version | head -1)"
}

install_aws_cli() {
    print_step "Checking AWS CLI installation..."

    if command_exists aws; then
        print_success "AWS CLI is installed: $(aws --version)"
        return 0
    fi

    print_step "Installing AWS CLI..."

    local tmp_dir=$(mktemp -d)
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmp_dir/awscliv2.zip"
    unzip -q "$tmp_dir/awscliv2.zip" -d "$tmp_dir"
    sudo "$tmp_dir/aws/install"
    rm -rf "$tmp_dir"

    print_success "AWS CLI installed: $(aws --version)"
}

# =============================================================================
# Git and SSH Setup
# =============================================================================

setup_git_ssh() {
    print_section "Step 3: Git & SSH Configuration"

    if [[ "${SKIP_GIT:-}" == "1" ]]; then
        print_warning "Skipping Git/SSH setup (SKIP_GIT=1)"
        return 0
    fi

    # Configure Git user
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")

    print_step "Configuring Git identity..."

    if [[ -n "$current_name" ]]; then
        print_info "Current Git name: $current_name"
        if ! confirm "Keep this name?" "y"; then
            prompt_input "Enter your full name" "" GIT_NAME
            git config --global user.name "$GIT_NAME"
        fi
    else
        prompt_input "Enter your full name for Git" "" GIT_NAME
        git config --global user.name "$GIT_NAME"
    fi

    if [[ -n "$current_email" ]]; then
        print_info "Current Git email: $current_email"
        if ! confirm "Keep this email?" "y"; then
            prompt_input "Enter your email for Git" "" GIT_EMAIL
            git config --global user.email "$GIT_EMAIL"
        fi
    else
        prompt_input "Enter your email for Git" "" GIT_EMAIL
        git config --global user.email "$GIT_EMAIL"
    fi

    # Set useful Git defaults
    print_step "Setting Git defaults..."
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor vim
    git config --global core.autocrlf input
    git config --global push.autoSetupRemote true

    print_success "Git configured"

    # SSH Key Setup
    setup_ssh_key
}

setup_ssh_key() {
    print_step "Checking SSH key..."

    local ssh_key="$HOME/.ssh/id_ed25519"
    local ssh_pub="$HOME/.ssh/id_ed25519.pub"

    if [[ -f "$ssh_key" ]]; then
        print_success "SSH key exists: $ssh_key"
        if ! confirm "Generate a new key?" "n"; then
            display_ssh_key "$ssh_pub"
            return 0
        fi
    fi

    print_step "Generating new SSH key..."

    local email=$(git config --global user.email)

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    ssh-keygen -t ed25519 -C "$email" -f "$ssh_key" -N ""

    print_success "SSH key generated"

    # Start ssh-agent and add key
    print_step "Adding key to ssh-agent..."
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add "$ssh_key" 2>/dev/null

    # Configure SSH for GitHub
    local ssh_config="$HOME/.ssh/config"
    if ! grep -q "github.com" "$ssh_config" 2>/dev/null; then
        cat >> "$ssh_config" << EOF

Host github.com
    HostName github.com
    User git
    IdentityFile $ssh_key
    AddKeysToAgent yes
EOF
        chmod 600 "$ssh_config"
        print_success "SSH config updated for GitHub"
    fi

    display_ssh_key "$ssh_pub"
}

display_ssh_key() {
    local ssh_pub="$1"

    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${YELLOW}  ACTION REQUIRED: Add this SSH key to GitHub${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Your public key:${NC}"
    echo ""
    cat "$ssh_pub"
    echo ""
    echo -e "${CYAN}Steps:${NC}"
    echo "  1. Go to: https://github.com/settings/keys"
    echo "  2. Click 'New SSH key'"
    echo "  3. Paste the key above"
    echo "  4. Click 'Add SSH key'"
    echo ""

    # Copy to clipboard if xclip is available
    if command_exists xclip; then
        cat "$ssh_pub" | xclip -selection clipboard
        print_success "Key copied to clipboard!"
    elif command_exists xsel; then
        cat "$ssh_pub" | xsel --clipboard
        print_success "Key copied to clipboard!"
    fi

    echo ""
    read -p "$(echo -e "${YELLOW}?${NC} Press Enter after adding the key to GitHub...")"

    # Test connection
    print_step "Testing GitHub SSH connection..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        print_success "GitHub SSH connection successful!"
    else
        print_warning "Could not verify GitHub connection. You may need to add the key manually."
    fi
}

# =============================================================================
# Project Setup
# =============================================================================

setup_project() {
    print_section "Step 4: Project Setup"

    print_step "Setting up project directory..."

    # Ask for project location
    prompt_input "Project directory" "$PROJECT_DIR" PROJECT_DIR

    # Create parent directory if needed
    mkdir -p "$(dirname "$PROJECT_DIR")"

    if [[ -d "$PROJECT_DIR" ]]; then
        print_info "Directory already exists: $PROJECT_DIR"
        if confirm "Use existing directory?" "y"; then
            cd "$PROJECT_DIR"
        else
            print_error "Setup cancelled"
            exit 1
        fi
    else
        # Clone or initialize
        if confirm "Clone from GitHub?" "y"; then
            prompt_input "Repository URL" "$REPO_URL" REPO_URL
            print_step "Cloning repository..."
            git clone "$REPO_URL" "$PROJECT_DIR"
            cd "$PROJECT_DIR"
            print_success "Repository cloned"
        else
            mkdir -p "$PROJECT_DIR"
            cd "$PROJECT_DIR"
            git init
            print_success "Initialized new repository"
        fi
    fi

    # Setup Python environment
    setup_python_env

    # Setup Node environment
    setup_node_env

    # Setup environment file
    setup_env_file

    # Setup pre-commit
    setup_precommit
}

setup_python_env() {
    print_step "Setting up Python environment..."

    if [[ ! -f "requirements.txt" ]] && [[ ! -f "pyproject.toml" ]]; then
        print_info "No Python requirements found, skipping"
        return 0
    fi

    if [[ ! -d "venv" ]]; then
        python3 -m venv venv
        print_success "Created virtual environment"
    fi

    # Activate and install
    source venv/bin/activate
    pip install --upgrade pip -q

    if [[ -f "requirements.txt" ]]; then
        pip install -r requirements.txt -q
        print_success "Installed Python dependencies from requirements.txt"
    fi

    if [[ -f "requirements-dev.txt" ]]; then
        pip install -r requirements-dev.txt -q
        print_success "Installed Python dev dependencies"
    fi

    if [[ -f "pyproject.toml" ]]; then
        pip install -e ".[dev]" -q 2>/dev/null || pip install -e . -q 2>/dev/null || true
        print_success "Installed package from pyproject.toml"
    fi

    deactivate
}

setup_node_env() {
    print_step "Setting up Node.js environment..."

    if [[ ! -f "package.json" ]]; then
        print_info "No package.json found, skipping"
        return 0
    fi

    npm install
    print_success "Installed Node.js dependencies"
}

setup_env_file() {
    print_step "Setting up environment file..."

    if [[ -f ".env" ]]; then
        print_info ".env file already exists"
        return 0
    fi

    if [[ -f ".env.example" ]]; then
        cp .env.example .env
        print_success "Created .env from .env.example"
        print_warning "Remember to update .env with your actual values"
    else
        print_info "No .env.example found, skipping"
    fi
}

setup_precommit() {
    print_step "Setting up pre-commit hooks..."

    if [[ ! -f ".pre-commit-config.yaml" ]]; then
        print_info "No pre-commit config found, skipping"
        return 0
    fi

    if command_exists pre-commit; then
        pre-commit install
        print_success "Pre-commit hooks installed"
    else
        if [[ -d "venv" ]]; then
            source venv/bin/activate
            pip install pre-commit -q
            pre-commit install
            deactivate
            print_success "Pre-commit hooks installed"
        else
            print_warning "pre-commit not available, skipping hooks setup"
        fi
    fi
}

# =============================================================================
# Docker Services
# =============================================================================

setup_docker_services() {
    print_section "Step 5: Docker Services"

    if [[ ! -f "docker-compose.yml" ]]; then
        print_info "No docker-compose.yml found, skipping"
        return 0
    fi

    if ! command_exists docker; then
        print_warning "Docker not installed, skipping"
        return 0
    fi

    # Check if docker is accessible
    if ! docker info &>/dev/null; then
        print_warning "Docker daemon not accessible. You may need to:"
        echo "  1. Log out and back in (for group changes)"
        echo "  2. Or run: newgrp docker"
        echo "  3. Or run: sudo systemctl start docker"
        return 0
    fi

    if confirm "Start Docker services now?" "y"; then
        print_step "Starting Docker services..."
        docker compose up -d db redis 2>/dev/null || docker-compose up -d db redis 2>/dev/null || true
        print_success "Docker services started"

        print_step "Waiting for services to be healthy..."
        sleep 5
        docker compose ps 2>/dev/null || docker-compose ps 2>/dev/null || true
    else
        print_info "Skipping Docker services startup"
        echo ""
        echo "  To start services later, run:"
        echo "    cd $PROJECT_DIR"
        echo "    docker compose up -d"
    fi
}

# =============================================================================
# GitHub CLI Authentication
# =============================================================================

setup_github_cli_auth() {
    print_section "Step 6: GitHub CLI Authentication"

    if ! command_exists gh; then
        print_warning "GitHub CLI not installed, skipping"
        return 0
    fi

    if gh auth status &>/dev/null; then
        print_success "GitHub CLI already authenticated"
        return 0
    fi

    if confirm "Authenticate GitHub CLI now?" "y"; then
        print_step "Starting GitHub CLI authentication..."
        gh auth login
        print_success "GitHub CLI authenticated"
    else
        print_info "Skipping GitHub CLI authentication"
        echo ""
        echo "  To authenticate later, run:"
        echo "    gh auth login"
    fi
}

# =============================================================================
# Verification
# =============================================================================

verify_installation() {
    print_section "Step 7: Verification"

    echo ""
    echo -e "${BOLD}Installed Tools:${NC}"
    echo ""

    local all_good=true

    # Check each tool
    for cmd in git python3 pip3 node npm docker terraform aws gh; do
        if command_exists "$cmd"; then
            local version=$($cmd --version 2>&1 | head -1)
            printf "  ${GREEN}✓${NC} %-12s %s\n" "$cmd" "$version"
        else
            printf "  ${RED}✗${NC} %-12s %s\n" "$cmd" "not installed"
            all_good=false
        fi
    done

    echo ""

    # Check Docker Compose
    if docker compose version &>/dev/null; then
        printf "  ${GREEN}✓${NC} %-12s %s\n" "compose" "$(docker compose version --short)"
    elif docker-compose --version &>/dev/null; then
        printf "  ${GREEN}✓${NC} %-12s %s\n" "compose" "$(docker-compose --version | cut -d' ' -f3)"
    else
        printf "  ${RED}✗${NC} %-12s %s\n" "compose" "not installed"
    fi

    echo ""

    if $all_good; then
        print_success "All tools installed successfully!"
    else
        print_warning "Some tools are missing. Review the list above."
    fi
}

# =============================================================================
# Final Checklist
# =============================================================================

print_final_checklist() {
    print_section "Setup Complete - Remaining Manual Steps"

    echo -e "${BOLD}${CYAN}Required Manual Configuration:${NC}"
    echo ""
    echo "  ${YELLOW}□${NC} 1. Add SSH key to GitHub (if not done)"
    echo "      https://github.com/settings/keys"
    echo ""
    echo "  ${YELLOW}□${NC} 2. Configure AWS credentials"
    echo "      Run: aws configure"
    echo "      Or set environment variables:"
    echo "        export AWS_ACCESS_KEY_ID=your_key"
    echo "        export AWS_SECRET_ACCESS_KEY=your_secret"
    echo "        export AWS_DEFAULT_REGION=us-east-1"
    echo ""
    echo "  ${YELLOW}□${NC} 3. Update .env file with your values"
    echo "      Edit: $PROJECT_DIR/.env"
    echo ""
    echo "  ${YELLOW}□${NC} 4. Configure GitHub repository secrets (for CI/CD)"
    echo "      Go to: https://github.com/YOUR_ORG/REPO/settings/secrets/actions"
    echo "      Add secrets:"
    echo "        - AWS_ACCESS_KEY_ID"
    echo "        - AWS_SECRET_ACCESS_KEY"
    echo "        - (any other secrets your app needs)"
    echo ""

    echo -e "${BOLD}${CYAN}For Production Deployment:${NC}"
    echo ""
    echo "  ${YELLOW}□${NC} 5. Create AWS resources"
    echo "      cd $PROJECT_DIR/infrastructure/terraform/environments/staging"
    echo "      cp terraform.tfvars.example terraform.tfvars"
    echo "      # Edit terraform.tfvars with your values"
    echo "      terraform init"
    echo "      terraform plan"
    echo "      terraform apply"
    echo ""
    echo "  ${YELLOW}□${NC} 6. Set up domain and SSL certificate"
    echo "      - Register domain or use existing"
    echo "      - Create ACM certificate in AWS"
    echo "      - Update Terraform with certificate ARN"
    echo ""
    echo "  ${YELLOW}□${NC} 7. Configure monitoring alerts"
    echo "      - Set up SNS topic for alerts"
    echo "      - Configure Slack/PagerDuty integration"
    echo "      - Update Terraform with SNS topic ARN"
    echo ""
    echo "  ${YELLOW}□${NC} 8. Set up container registry"
    echo "      - Create ECR repository in AWS"
    echo "      - Or use GitHub Container Registry (ghcr.io)"
    echo "      - Update deployment scripts with registry URL"
    echo ""

    echo -e "${BOLD}${CYAN}Quick Start Commands:${NC}"
    echo ""
    echo "  # Navigate to project"
    echo "  cd $PROJECT_DIR"
    echo ""
    echo "  # Activate Python environment"
    echo "  source venv/bin/activate"
    echo ""
    echo "  # Start all services"
    echo "  docker compose up -d"
    echo ""
    echo "  # View logs"
    echo "  docker compose logs -f"
    echo ""
    echo "  # Run tests"
    echo "  pytest tests/ -v"
    echo ""
    echo "  # Stop services"
    echo "  docker compose down"
    echo ""

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${GREEN}  Setup complete! Happy coding! 🚀${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_banner

    check_root
    check_os

    echo ""
    echo -e "${BOLD}This script will set up your development environment.${NC}"
    echo ""
    echo "It will install: Git, Python, Node.js, Docker, Terraform, AWS CLI, GitHub CLI"
    echo "It will configure: Git identity, SSH keys, project dependencies"
    echo ""

    if ! confirm "Continue with setup?" "y"; then
        echo "Setup cancelled."
        exit 0
    fi

    # Run setup steps
    install_system_packages
    install_python
    install_node
    install_docker
    install_github_cli
    install_terraform
    install_aws_cli

    setup_git_ssh
    setup_github_cli_auth
    setup_project
    setup_docker_services

    verify_installation
    print_final_checklist
}

# Run main function
main "$@"
