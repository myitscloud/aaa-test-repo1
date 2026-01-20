#!/usr/bin/env bash
#
# Local Development Setup Script
# Sets up the local development environment
#
# Usage:
#   ./setup-local.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Local Development Setup${NC}"
echo -e "${BLUE}========================================${NC}"

# -----------------------------------------------------------------------------
# Check prerequisites
# -----------------------------------------------------------------------------
echo -e "\n${GREEN}Checking prerequisites...${NC}"

check_command() {
    if command -v "$1" &> /dev/null; then
        echo "  ✓ $1 found"
        return 0
    else
        echo "  ✗ $1 not found"
        return 1
    fi
}

MISSING=0
check_command "docker" || MISSING=1
check_command "docker-compose" || check_command "docker" || MISSING=1
check_command "git" || MISSING=1

if [ "$MISSING" -eq 1 ]; then
    echo -e "\n${YELLOW}Please install missing dependencies and try again.${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# Setup environment files
# -----------------------------------------------------------------------------
echo -e "\n${GREEN}Setting up environment files...${NC}"

if [ ! -f "$PROJECT_ROOT/.env" ]; then
    if [ -f "$PROJECT_ROOT/.env.example" ]; then
        cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
        echo "  ✓ Created .env from .env.example"
    else
        cat > "$PROJECT_ROOT/.env" << 'EOF'
# Local Development Environment
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=debug

# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=app
DATABASE_URL=postgresql://postgres:postgres@db:5432/app

# Redis
REDIS_URL=redis://redis:6379/0

# Application
SECRET_KEY=local-development-secret-key-change-in-production
API_PORT=8000
WEB_PORT=3000

# Build settings
BUILD_TARGET=development
EOF
        echo "  ✓ Created default .env file"
    fi
else
    echo "  ✓ .env file already exists"
fi

# -----------------------------------------------------------------------------
# Setup Git hooks
# -----------------------------------------------------------------------------
echo -e "\n${GREEN}Setting up Git hooks...${NC}"

HOOKS_DIR="$PROJECT_ROOT/.git/hooks"
if [ -d "$HOOKS_DIR" ]; then
    # Pre-commit hook
    cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook

echo "Running pre-commit checks..."

# Check for secrets
if git diff --cached --name-only | xargs grep -l -E "(password|secret|api_key|token).*=" 2>/dev/null | grep -v ".example" | grep -v ".md"; then
    echo "⚠️  Warning: Possible secrets detected in staged files"
    echo "Please review before committing."
    read -p "Continue anyway? (y/N): " confirm
    if [ "$confirm" != "y" ]; then
        exit 1
    fi
fi

# Run linters if available
if [ -f "requirements.txt" ] && command -v black &> /dev/null; then
    black --check . 2>/dev/null || echo "Consider running 'black .' to format code"
fi

if [ -f "package.json" ] && [ -f "node_modules/.bin/eslint" ]; then
    npm run lint 2>/dev/null || echo "Consider running 'npm run lint' to check code"
fi

exit 0
EOF
    chmod +x "$HOOKS_DIR/pre-commit"
    echo "  ✓ Installed pre-commit hook"
fi

# -----------------------------------------------------------------------------
# Create required directories
# -----------------------------------------------------------------------------
echo -e "\n${GREEN}Creating required directories...${NC}"

mkdir -p "$PROJECT_ROOT/logs"
mkdir -p "$PROJECT_ROOT/.ai-logs/sessions"
echo "  ✓ Created logs directories"

# -----------------------------------------------------------------------------
# Setup Python environment (if applicable)
# -----------------------------------------------------------------------------
if [ -f "$PROJECT_ROOT/requirements.txt" ]; then
    echo -e "\n${GREEN}Setting up Python environment...${NC}"

    if [ ! -d "$PROJECT_ROOT/venv" ]; then
        python3 -m venv "$PROJECT_ROOT/venv"
        echo "  ✓ Created virtual environment"
    fi

    echo "  To activate: source venv/bin/activate"
    echo "  Then install: pip install -r requirements.txt"
fi

# -----------------------------------------------------------------------------
# Setup Node.js environment (if applicable)
# -----------------------------------------------------------------------------
if [ -f "$PROJECT_ROOT/package.json" ]; then
    echo -e "\n${GREEN}Setting up Node.js environment...${NC}"
    echo "  Run 'npm install' to install dependencies"
fi

# -----------------------------------------------------------------------------
# Start services
# -----------------------------------------------------------------------------
echo -e "\n${GREEN}Ready to start services!${NC}"
echo ""
echo "Available commands:"
echo "  docker-compose up -d              # Start all services"
echo "  docker-compose up -d db redis     # Start only database and cache"
echo "  docker-compose logs -f            # View logs"
echo "  docker-compose down               # Stop all services"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Setup complete!${NC}"
echo -e "${BLUE}========================================${NC}"
