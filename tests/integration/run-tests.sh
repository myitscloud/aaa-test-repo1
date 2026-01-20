#!/usr/bin/env bash
#
# Run Integration Tests
# Builds and runs the setup script tests in Docker containers
#
# Usage:
#   ./run-tests.sh              # Run on Debian Trixie only
#   ./run-tests.sh --all        # Run on all supported distros
#   ./run-tests.sh --quick      # Quick syntax check only
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Parse arguments
RUN_ALL=false
QUICK_CHECK=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)      RUN_ALL=true ;;
        --quick)    QUICK_CHECK=true ;;
        --help)
            echo "Usage: $0 [--all] [--quick]"
            echo "  --all    Run on all supported distros"
            echo "  --quick  Quick syntax check only"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Quick syntax check
if $QUICK_CHECK; then
    print_header "Quick Syntax Check"

    echo "Checking setup.sh syntax..."
    if bash -n "$PROJECT_ROOT/setup.sh"; then
        echo -e "${GREEN}✓${NC} setup.sh syntax OK"
    else
        echo -e "${RED}✗${NC} setup.sh has syntax errors"
        exit 1
    fi

    echo "Checking test-setup.sh syntax..."
    if bash -n "$SCRIPT_DIR/test-setup.sh"; then
        echo -e "${GREEN}✓${NC} test-setup.sh syntax OK"
    else
        echo -e "${RED}✗${NC} test-setup.sh has syntax errors"
        exit 1
    fi

    # Check for common issues with shellcheck if available
    if command -v shellcheck &> /dev/null; then
        echo "Running shellcheck..."
        shellcheck -x "$PROJECT_ROOT/setup.sh" && echo -e "${GREEN}✓${NC} shellcheck passed" || echo -e "${YELLOW}⚠${NC} shellcheck warnings"
    fi

    echo ""
    echo -e "${GREEN}Quick check passed!${NC}"
    exit 0
fi

# Full Docker tests
print_header "Building Test Containers"

cd "$SCRIPT_DIR"

# Build and run Debian Trixie test
echo -e "${BLUE}Building Debian Trixie test container...${NC}"
docker compose -f docker-compose.test.yml build test-debian-trixie

print_header "Running Tests on Debian Trixie"
if docker compose -f docker-compose.test.yml run --rm test-debian-trixie; then
    echo -e "${GREEN}✓ Debian Trixie tests passed${NC}"
    TRIXIE_RESULT=0
else
    echo -e "${RED}✗ Debian Trixie tests failed${NC}"
    TRIXIE_RESULT=1
fi

# Run on other distros if --all
if $RUN_ALL; then
    print_header "Running Tests on Debian Bookworm"
    docker compose -f docker-compose.test.yml build test-debian-bookworm
    if docker compose -f docker-compose.test.yml run --rm test-debian-bookworm; then
        echo -e "${GREEN}✓ Debian Bookworm tests passed${NC}"
        BOOKWORM_RESULT=0
    else
        echo -e "${RED}✗ Debian Bookworm tests failed${NC}"
        BOOKWORM_RESULT=1
    fi

    print_header "Running Tests on Ubuntu 24.04"
    docker compose -f docker-compose.test.yml build test-ubuntu
    if docker compose -f docker-compose.test.yml run --rm test-ubuntu; then
        echo -e "${GREEN}✓ Ubuntu tests passed${NC}"
        UBUNTU_RESULT=0
    else
        echo -e "${RED}✗ Ubuntu tests failed${NC}"
        UBUNTU_RESULT=1
    fi
fi

# Cleanup
print_header "Cleanup"
docker compose -f docker-compose.test.yml down --volumes --remove-orphans 2>/dev/null || true
echo "Cleaned up test containers"

# Summary
print_header "Test Summary"

echo "Debian Trixie: $([ $TRIXIE_RESULT -eq 0 ] && echo -e "${GREEN}PASSED${NC}" || echo -e "${RED}FAILED${NC}")"

if $RUN_ALL; then
    echo "Debian Bookworm: $([ $BOOKWORM_RESULT -eq 0 ] && echo -e "${GREEN}PASSED${NC}" || echo -e "${RED}FAILED${NC}")"
    echo "Ubuntu 24.04: $([ $UBUNTU_RESULT -eq 0 ] && echo -e "${GREEN}PASSED${NC}" || echo -e "${RED}FAILED${NC}")"

    # Exit with failure if any test failed
    if [[ $TRIXIE_RESULT -ne 0 ]] || [[ $BOOKWORM_RESULT -ne 0 ]] || [[ $UBUNTU_RESULT -ne 0 ]]; then
        exit 1
    fi
else
    if [[ $TRIXIE_RESULT -ne 0 ]]; then
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}All tests passed!${NC}"
