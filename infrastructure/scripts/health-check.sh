#!/usr/bin/env bash
#
# Health Check Script
# Monitors application health across environments
#
# Usage:
#   ./health-check.sh <environment>
#   ./health-check.sh staging
#   ./health-check.sh production --verbose

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh" 2>/dev/null || true

# Default configuration
ENVIRONMENT="${1:-staging}"
VERBOSE="${2:-}"
TIMEOUT=10

# Get URL based on environment
get_url() {
    case "$ENVIRONMENT" in
        staging)    echo "${STAGING_URL:-https://staging.example.com}" ;;
        production) echo "${PRODUCTION_URL:-https://example.com}" ;;
        local)      echo "http://localhost:8000" ;;
        *)          echo "$ENVIRONMENT" ;;  # Treat as direct URL
    esac
}

URL=$(get_url)

echo "=========================================="
echo "Health Check: $ENVIRONMENT"
echo "URL: $URL"
echo "=========================================="

# Health check function
check_endpoint() {
    local endpoint="$1"
    local name="$2"
    local expected_status="${3:-200}"

    local full_url="${URL}${endpoint}"

    local response
    local http_code
    local time_total

    response=$(curl -s -w "\n%{http_code}\n%{time_total}" \
        --connect-timeout "$TIMEOUT" \
        --max-time "$TIMEOUT" \
        "$full_url" 2>/dev/null || echo -e "\n000\n0")

    http_code=$(echo "$response" | tail -2 | head -1)
    time_total=$(echo "$response" | tail -1)
    body=$(echo "$response" | head -n -2)

    if [ "$http_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓${NC} $name (${time_total}s)"
        if [ "$VERBOSE" = "--verbose" ]; then
            echo "  Response: $body"
        fi
        return 0
    else
        echo -e "${RED}✗${NC} $name - HTTP $http_code (expected $expected_status)"
        if [ "$VERBOSE" = "--verbose" ]; then
            echo "  Response: $body"
        fi
        return 1
    fi
}

# Track failures
FAILURES=0

# Run health checks
echo ""
echo "Checking endpoints..."
echo "---"

check_endpoint "/health" "Health endpoint" 200 || ((FAILURES++))
check_endpoint "/" "Root endpoint" 200 || ((FAILURES++))

# Optional API checks
if check_endpoint "/api/health" "API health" 200 2>/dev/null; then
    :
fi

# Database connectivity (if endpoint exists)
if check_endpoint "/api/db/health" "Database" 200 2>/dev/null; then
    :
fi

# Redis connectivity (if endpoint exists)
if check_endpoint "/api/cache/health" "Cache" 200 2>/dev/null; then
    :
fi

echo ""
echo "=========================================="

if [ "$FAILURES" -eq 0 ]; then
    echo -e "${GREEN}All health checks passed!${NC}"
    exit 0
else
    echo -e "${RED}$FAILURES health check(s) failed${NC}"
    exit 1
fi
