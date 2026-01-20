#!/usr/bin/env bash
#
# Create Test Repository Script
# Creates a new GitHub repository to test the full setup workflow
#
# Usage:
#   ./create-test-repo.sh                    # Interactive mode
#   ./create-test-repo.sh --name my-test     # Specify name
#   ./create-test-repo.sh --cleanup          # Delete test repos
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Git configured with user.name and user.email
#

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DEFAULT_REPO_NAME="setup-test-${TIMESTAMP}"
TEST_REPOS_PREFIX="setup-test-"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}▶${NC} $1"
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

confirm() {
    local prompt="$1"
    local default="${2:-y}"
    local response

    if [[ "$default" == "y" ]]; then
        read -p "$(echo -e "${YELLOW}?${NC} $prompt [Y/n]: ")" response
        response="${response:-y}"
    else
        read -p "$(echo -e "${YELLOW}?${NC} $prompt [y/N]: ")" response
        response="${response:-n}"
    fi

    [[ "$response" =~ ^[Yy]$ ]]
}

check_prerequisites() {
    print_step "Checking prerequisites..."

    # Check gh CLI
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed"
        echo "  Install with: sudo apt install gh"
        echo "  Or: brew install gh"
        exit 1
    fi

    # Check gh auth
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI is not authenticated"
        echo "  Run: gh auth login"
        exit 1
    fi

    # Check git
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        exit 1
    fi

    print_success "All prerequisites met"
}

get_github_username() {
    gh api user --jq '.login'
}

# =============================================================================
# Create Test Repository
# =============================================================================

create_test_repo() {
    local repo_name="$1"
    local github_user=$(get_github_username)
    local full_repo_name="${github_user}/${repo_name}"
    local temp_dir=$(mktemp -d)

    print_header "Creating Test Repository"

    echo "Repository: $full_repo_name"
    echo "Temp directory: $temp_dir"
    echo ""

    # Create the repository on GitHub
    print_step "Creating GitHub repository..."
    if gh repo create "$repo_name" --public --description "Test repository for setup script validation" --clone --add-readme; then
        print_success "Repository created: https://github.com/$full_repo_name"
    else
        print_error "Failed to create repository"
        exit 1
    fi

    cd "$repo_name"

    # Copy template files
    print_step "Copying template files..."
    cp "$PROJECT_ROOT/setup.sh" .
    cp "$PROJECT_ROOT/.env.example" . 2>/dev/null || true
    cp "$PROJECT_ROOT/docker-compose.yml" . 2>/dev/null || true
    cp "$PROJECT_ROOT/pyproject.toml" . 2>/dev/null || true
    cp "$PROJECT_ROOT/pytest.ini" . 2>/dev/null || true
    cp "$PROJECT_ROOT/jest.config.js" . 2>/dev/null || true
    cp "$PROJECT_ROOT/.pre-commit-config.yaml" . 2>/dev/null || true
    cp -r "$PROJECT_ROOT/.github" . 2>/dev/null || true
    cp -r "$PROJECT_ROOT/tests" . 2>/dev/null || true

    # Create a simple requirements.txt for testing
    echo "requests>=2.28.0" > requirements.txt

    # Create a simple package.json for testing
    cat > package.json << 'EOF'
{
  "name": "setup-test",
  "version": "1.0.0",
  "description": "Test repository for setup script",
  "scripts": {
    "test": "echo \"Tests passed\""
  },
  "dependencies": {}
}
EOF

    print_success "Template files copied"

    # Commit and push
    print_step "Committing files..."
    git add -A
    git commit -m "Initial commit: Setup script test repository"
    git push origin main

    print_success "Files pushed to repository"

    # Get repository URL
    local repo_url="https://github.com/$full_repo_name"
    local ssh_url="git@github.com:$full_repo_name.git"

    print_header "Test Repository Ready"

    echo -e "${GREEN}Repository created successfully!${NC}"
    echo ""
    echo "Repository URL: $repo_url"
    echo "SSH URL: $ssh_url"
    echo "Local path: $(pwd)"
    echo ""
    echo -e "${CYAN}To test the setup script on a fresh system:${NC}"
    echo ""
    echo "  1. On the target system, clone the repo:"
    echo "     git clone $ssh_url"
    echo "     cd $repo_name"
    echo ""
    echo "  2. Run the setup script:"
    echo "     ./setup.sh"
    echo ""
    echo "  3. Or test in Docker:"
    echo "     cd tests/integration"
    echo "     ./run-tests.sh"
    echo ""

    # Return to original directory
    cd - > /dev/null

    # Store repo name for cleanup
    echo "$repo_name" >> "$PROJECT_ROOT/.test-repos"
}

# =============================================================================
# Cleanup Test Repositories
# =============================================================================

cleanup_test_repos() {
    print_header "Cleanup Test Repositories"

    local github_user=$(get_github_username)

    # Find all test repos
    print_step "Finding test repositories..."
    local repos=$(gh repo list "$github_user" --json name --jq '.[].name' | grep "^${TEST_REPOS_PREFIX}" || true)

    if [[ -z "$repos" ]]; then
        print_success "No test repositories found"
        return 0
    fi

    echo "Found test repositories:"
    echo "$repos" | while read -r repo; do
        echo "  - $repo"
    done
    echo ""

    if ! confirm "Delete all test repositories?" "n"; then
        print_warning "Cleanup cancelled"
        return 0
    fi

    # Delete each repo
    echo "$repos" | while read -r repo; do
        if [[ -n "$repo" ]]; then
            print_step "Deleting $repo..."
            if gh repo delete "$github_user/$repo" --yes 2>/dev/null; then
                print_success "Deleted $repo"
            else
                print_warning "Could not delete $repo"
            fi
        fi
    done

    # Clean up local tracking file
    rm -f "$PROJECT_ROOT/.test-repos"

    print_success "Cleanup complete"
}

# =============================================================================
# Full Integration Test
# =============================================================================

run_full_integration_test() {
    local repo_name="$1"
    local github_user=$(get_github_username)

    print_header "Running Full Integration Test"

    echo "This will:"
    echo "  1. Create a new test repository"
    echo "  2. Build a Docker container"
    echo "  3. Clone the repo inside the container"
    echo "  4. Run the setup script"
    echo "  5. Validate the setup"
    echo "  6. Optionally delete the test repo"
    echo ""

    if ! confirm "Continue with full integration test?" "y"; then
        return 0
    fi

    # Create the repo
    create_test_repo "$repo_name"

    local full_repo_name="${github_user}/${repo_name}"
    local ssh_url="git@github.com:$full_repo_name.git"

    # Build and run Docker test
    print_header "Running Docker Integration Test"

    # Create a test Dockerfile that clones and runs setup
    local test_dir=$(mktemp -d)
    cat > "$test_dir/Dockerfile" << EOF
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

RUN apt-get update && apt-get install -y --no-install-recommends \\
    sudo ca-certificates curl git openssh-client \\
    && rm -rf /var/lib/apt/lists/* \\
    && useradd -m -s /bin/bash testuser \\
    && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Clone the test repo (using HTTPS to avoid SSH key issues)
RUN git clone https://github.com/$full_repo_name.git project

WORKDIR /home/testuser/project

# Run the setup script in non-interactive mode
ENV SKIP_GIT=1
ENV SKIP_DOCKER=1

CMD ["bash", "-c", "echo 'y' | ./setup.sh || ./tests/integration/test-setup.sh"]
EOF

    print_step "Building Docker test image..."
    docker build -t "setup-integration-test:$repo_name" "$test_dir"

    print_step "Running integration test..."
    if docker run --rm "setup-integration-test:$repo_name"; then
        print_success "Integration test passed!"
    else
        print_warning "Integration test had some failures (this may be expected in container)"
    fi

    # Cleanup
    rm -rf "$test_dir"
    docker rmi "setup-integration-test:$repo_name" 2>/dev/null || true

    # Ask about repo cleanup
    echo ""
    if confirm "Delete test repository $repo_name?" "y"; then
        gh repo delete "$full_repo_name" --yes
        print_success "Test repository deleted"
    else
        echo ""
        echo "Test repository kept at: https://github.com/$full_repo_name"
    fi
}

# =============================================================================
# Main
# =============================================================================

usage() {
    cat << EOF
Usage: $(basename "$0") [options]

Options:
    --name NAME     Specify repository name (default: setup-test-TIMESTAMP)
    --cleanup       Delete all test repositories
    --full          Run full integration test (create, test, cleanup)
    --help          Show this help message

Examples:
    $(basename "$0")                    # Create test repo interactively
    $(basename "$0") --name my-test     # Create repo with specific name
    $(basename "$0") --full             # Run full integration test
    $(basename "$0") --cleanup          # Delete all test repos
EOF
}

main() {
    local repo_name="$DEFAULT_REPO_NAME"
    local action="create"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --name)
                repo_name="$2"
                shift
                ;;
            --cleanup)
                action="cleanup"
                ;;
            --full)
                action="full"
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done

    print_header "Setup Script Test Repository Manager"

    check_prerequisites

    case "$action" in
        create)
            create_test_repo "$repo_name"
            ;;
        cleanup)
            cleanup_test_repos
            ;;
        full)
            run_full_integration_test "$repo_name"
            ;;
    esac
}

main "$@"
