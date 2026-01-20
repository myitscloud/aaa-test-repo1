#!/usr/bin/env bash
#
# Deployment Script
# Handles deployment to staging and production environments
#
# Usage:
#   ./deploy.sh <environment> [options]
#
# Examples:
#   ./deploy.sh staging
#   ./deploy.sh production --dry-run
#   ./deploy.sh staging --skip-tests

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${PROJECT_ROOT}/logs/deploy_${TIMESTAMP}.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# Functions
# =============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case "$level" in
        INFO)  color="$GREEN" ;;
        WARN)  color="$YELLOW" ;;
        ERROR) color="$RED" ;;
        *)     color="$NC" ;;
    esac

    echo -e "${color}[${timestamp}] [${level}] ${message}${NC}"
    echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE" 2>/dev/null || true
}

usage() {
    cat << EOF
Usage: $(basename "$0") <environment> [options]

Environments:
    staging       Deploy to staging environment
    production    Deploy to production environment

Options:
    --dry-run     Show what would be deployed without making changes
    --skip-tests  Skip running tests before deployment
    --force       Skip confirmation prompts
    --rollback    Rollback to previous version
    --version     Specify version to deploy (default: latest)
    --help        Show this help message

Examples:
    $(basename "$0") staging
    $(basename "$0") production --dry-run
    $(basename "$0") staging --version v1.2.3
    $(basename "$0") production --rollback
EOF
}

check_dependencies() {
    log INFO "Checking dependencies..."

    local deps=("docker" "aws" "jq")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        log ERROR "Missing dependencies: ${missing[*]}"
        exit 1
    fi

    log INFO "All dependencies found"
}

check_aws_credentials() {
    log INFO "Checking AWS credentials..."

    if ! aws sts get-caller-identity &> /dev/null; then
        log ERROR "AWS credentials not configured or invalid"
        exit 1
    fi

    local account_id=$(aws sts get-caller-identity --query Account --output text)
    log INFO "Using AWS account: $account_id"
}

run_tests() {
    if [ "$SKIP_TESTS" = true ]; then
        log WARN "Skipping tests (--skip-tests flag set)"
        return 0
    fi

    log INFO "Running tests..."

    if [ -f "$PROJECT_ROOT/requirements.txt" ]; then
        log INFO "Running Python tests..."
        cd "$PROJECT_ROOT"
        python -m pytest tests/ -v || {
            log ERROR "Tests failed"
            exit 1
        }
    fi

    if [ -f "$PROJECT_ROOT/package.json" ]; then
        log INFO "Running Node.js tests..."
        cd "$PROJECT_ROOT"
        npm test || {
            log ERROR "Tests failed"
            exit 1
        }
    fi

    log INFO "All tests passed"
}

build_image() {
    log INFO "Building Docker image..."

    local image_tag="${REGISTRY}/${IMAGE_NAME}:${VERSION}"

    if [ "$DRY_RUN" = true ]; then
        log INFO "[DRY RUN] Would build: $image_tag"
        return 0
    fi

    docker build \
        -t "$image_tag" \
        -t "${REGISTRY}/${IMAGE_NAME}:latest" \
        --build-arg BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --build-arg VCS_REF="$(git rev-parse --short HEAD)" \
        --build-arg VERSION="$VERSION" \
        -f "$PROJECT_ROOT/infrastructure/docker/Dockerfile.python" \
        "$PROJECT_ROOT"

    log INFO "Image built successfully: $image_tag"
}

push_image() {
    log INFO "Pushing Docker image..."

    local image_tag="${REGISTRY}/${IMAGE_NAME}:${VERSION}"

    if [ "$DRY_RUN" = true ]; then
        log INFO "[DRY RUN] Would push: $image_tag"
        return 0
    fi

    # Login to registry
    aws ecr get-login-password --region "$AWS_REGION" | \
        docker login --username AWS --password-stdin "$REGISTRY"

    docker push "$image_tag"
    docker push "${REGISTRY}/${IMAGE_NAME}:latest"

    log INFO "Image pushed successfully"
}

deploy_staging() {
    log INFO "Deploying to staging..."

    if [ "$DRY_RUN" = true ]; then
        log INFO "[DRY RUN] Would deploy to staging"
        return 0
    fi

    # Update ECS service
    aws ecs update-service \
        --cluster "${PROJECT_NAME}-staging-cluster" \
        --service "${PROJECT_NAME}-staging-service" \
        --force-new-deployment \
        --region "$AWS_REGION"

    log INFO "Waiting for deployment to stabilize..."
    aws ecs wait services-stable \
        --cluster "${PROJECT_NAME}-staging-cluster" \
        --services "${PROJECT_NAME}-staging-service" \
        --region "$AWS_REGION"

    log INFO "Staging deployment complete"
}

deploy_production() {
    log INFO "Deploying to production..."

    if [ "$FORCE" != true ]; then
        echo -e "${YELLOW}⚠️  You are about to deploy to PRODUCTION${NC}"
        echo "Version: $VERSION"
        echo "Image: ${REGISTRY}/${IMAGE_NAME}:${VERSION}"
        read -p "Are you sure you want to continue? (yes/no): " confirm

        if [ "$confirm" != "yes" ]; then
            log WARN "Deployment cancelled by user"
            exit 0
        fi
    fi

    if [ "$DRY_RUN" = true ]; then
        log INFO "[DRY RUN] Would deploy to production"
        return 0
    fi

    # Create deployment record
    local deployment_id=$(uuidgen)
    log INFO "Deployment ID: $deployment_id"

    # Update ECS service with rolling deployment
    aws ecs update-service \
        --cluster "${PROJECT_NAME}-production-cluster" \
        --service "${PROJECT_NAME}-production-service" \
        --force-new-deployment \
        --deployment-configuration "maximumPercent=200,minimumHealthyPercent=100" \
        --region "$AWS_REGION"

    log INFO "Waiting for deployment to stabilize..."
    aws ecs wait services-stable \
        --cluster "${PROJECT_NAME}-production-cluster" \
        --services "${PROJECT_NAME}-production-service" \
        --region "$AWS_REGION"

    log INFO "Production deployment complete"
}

rollback() {
    log WARN "Rolling back deployment..."

    local cluster="${PROJECT_NAME}-${ENVIRONMENT}-cluster"
    local service="${PROJECT_NAME}-${ENVIRONMENT}-service"

    if [ "$DRY_RUN" = true ]; then
        log INFO "[DRY RUN] Would rollback $ENVIRONMENT"
        return 0
    fi

    # Get previous task definition
    local current_td=$(aws ecs describe-services \
        --cluster "$cluster" \
        --services "$service" \
        --query 'services[0].taskDefinition' \
        --output text \
        --region "$AWS_REGION")

    local td_family=$(echo "$current_td" | sed 's/:.*$//')
    local current_revision=$(echo "$current_td" | sed 's/.*://')
    local previous_revision=$((current_revision - 1))

    if [ "$previous_revision" -lt 1 ]; then
        log ERROR "No previous revision to rollback to"
        exit 1
    fi

    local previous_td="${td_family}:${previous_revision}"
    log INFO "Rolling back to: $previous_td"

    aws ecs update-service \
        --cluster "$cluster" \
        --service "$service" \
        --task-definition "$previous_td" \
        --region "$AWS_REGION"

    aws ecs wait services-stable \
        --cluster "$cluster" \
        --services "$service" \
        --region "$AWS_REGION"

    log INFO "Rollback complete"
}

smoke_test() {
    log INFO "Running smoke tests..."

    local url
    if [ "$ENVIRONMENT" = "production" ]; then
        url="$PRODUCTION_URL"
    else
        url="$STAGING_URL"
    fi

    if [ "$DRY_RUN" = true ]; then
        log INFO "[DRY RUN] Would run smoke tests against $url"
        return 0
    fi

    # Health check
    local health_status=$(curl -s -o /dev/null -w "%{http_code}" "${url}/health" || echo "000")

    if [ "$health_status" = "200" ]; then
        log INFO "Health check passed"
    else
        log ERROR "Health check failed (HTTP $health_status)"
        return 1
    fi

    log INFO "Smoke tests passed"
}

# =============================================================================
# Main
# =============================================================================

main() {
    # Create logs directory
    mkdir -p "$(dirname "$LOG_FILE")"

    # Parse arguments
    ENVIRONMENT="${1:-}"
    shift || true

    DRY_RUN=false
    SKIP_TESTS=false
    FORCE=false
    ROLLBACK=false
    VERSION="latest"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)    DRY_RUN=true ;;
            --skip-tests) SKIP_TESTS=true ;;
            --force)      FORCE=true ;;
            --rollback)   ROLLBACK=true ;;
            --version)    VERSION="$2"; shift ;;
            --help)       usage; exit 0 ;;
            *)            log ERROR "Unknown option: $1"; usage; exit 1 ;;
        esac
        shift
    done

    # Validate environment
    if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
        log ERROR "Invalid environment: $ENVIRONMENT"
        usage
        exit 1
    fi

    # Load environment config
    source "$SCRIPT_DIR/config.sh" 2>/dev/null || {
        log WARN "No config.sh found, using defaults"
        PROJECT_NAME="${PROJECT_NAME:-multi-agent-template}"
        AWS_REGION="${AWS_REGION:-us-east-1}"
        REGISTRY="${REGISTRY:-123456789012.dkr.ecr.us-east-1.amazonaws.com}"
        IMAGE_NAME="${IMAGE_NAME:-app}"
        STAGING_URL="${STAGING_URL:-https://staging.example.com}"
        PRODUCTION_URL="${PRODUCTION_URL:-https://example.com}"
    }

    log INFO "=========================================="
    log INFO "Deployment: $ENVIRONMENT"
    log INFO "Version: $VERSION"
    log INFO "Dry Run: $DRY_RUN"
    log INFO "=========================================="

    # Execute deployment steps
    check_dependencies
    check_aws_credentials

    if [ "$ROLLBACK" = true ]; then
        rollback
    else
        run_tests
        build_image
        push_image

        if [ "$ENVIRONMENT" = "staging" ]; then
            deploy_staging
        else
            deploy_production
        fi

        smoke_test
    fi

    log INFO "=========================================="
    log INFO "Deployment completed successfully!"
    log INFO "=========================================="
}

main "$@"
