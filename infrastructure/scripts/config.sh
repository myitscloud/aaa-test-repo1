#!/usr/bin/env bash
#
# Deployment Configuration
# Set environment-specific variables here
#

# =============================================================================
# Project Settings
# =============================================================================
export PROJECT_NAME="multi-agent-template"

# =============================================================================
# AWS Settings
# =============================================================================
export AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-}"

# =============================================================================
# Container Registry
# =============================================================================
# AWS ECR
export REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export IMAGE_NAME="${PROJECT_NAME}"

# GitHub Container Registry (alternative)
# export REGISTRY="ghcr.io"
# export IMAGE_NAME="your-org/${PROJECT_NAME}"

# =============================================================================
# Environment URLs
# =============================================================================
export STAGING_URL="${STAGING_URL:-https://staging.example.com}"
export PRODUCTION_URL="${PRODUCTION_URL:-https://example.com}"

# =============================================================================
# Notification Settings
# =============================================================================
export SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
export PAGERDUTY_KEY="${PAGERDUTY_KEY:-}"

# =============================================================================
# Feature Flags
# =============================================================================
export ENABLE_CANARY_DEPLOYMENT="${ENABLE_CANARY_DEPLOYMENT:-false}"
export CANARY_PERCENTAGE="${CANARY_PERCENTAGE:-10}"
