# TFLint Configuration
# Terraform linter configuration
# https://github.com/terraform-linters/tflint

config {
  # Module inspection (downloads modules to check)
  module = true

  # Force to use installed plugins
  force = false
}

# =============================================================================
# Core Rules
# =============================================================================

# Disallow deprecated (0.11-style) interpolation
rule "terraform_deprecated_interpolation" {
  enabled = true
}

# Disallow legacy dot index syntax
rule "terraform_deprecated_index" {
  enabled = true
}

# Disallow variables, data sources, and locals that are declared but never used
rule "terraform_unused_declarations" {
  enabled = true
}

# Disallow // comments in favor of #
rule "terraform_comment_syntax" {
  enabled = true
}

# Disallow output declarations without description
rule "terraform_documented_outputs" {
  enabled = true
}

# Disallow variable declarations without description
rule "terraform_documented_variables" {
  enabled = true
}

# Disallow variable declarations without type
rule "terraform_typed_variables" {
  enabled = true
}

# Enforces naming conventions
rule "terraform_naming_convention" {
  enabled = true

  # Naming convention for variables
  variable {
    format = "snake_case"
  }

  # Naming convention for locals
  locals {
    format = "snake_case"
  }

  # Naming convention for outputs
  output {
    format = "snake_case"
  }

  # Naming convention for resources
  resource {
    format = "snake_case"
  }

  # Naming convention for data sources
  data {
    format = "snake_case"
  }

  # Naming convention for modules
  module {
    format = "snake_case"
  }
}

# Require terraform version constraints
rule "terraform_required_version" {
  enabled = true
}

# Require provider version constraints
rule "terraform_required_providers" {
  enabled = true
}

# Ensure that a module complies with the Terraform Standard Module Structure
rule "terraform_standard_module_structure" {
  enabled = true
}

# Disallow terraform workspace for controlling infrastructure
rule "terraform_workspace_remote" {
  enabled = true
}

# =============================================================================
# AWS Plugin Rules
# =============================================================================

plugin "aws" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Detect AWS instance types that are not valid
rule "aws_instance_invalid_type" {
  enabled = true
}

# Detect invalid AMI IDs
rule "aws_instance_invalid_ami" {
  enabled = true
}

# Disallow previous generation instance types
rule "aws_instance_previous_type" {
  enabled = true
}

# Detect invalid RDS instance classes
rule "aws_db_instance_invalid_type" {
  enabled = true
}

# Detect invalid security group rules
rule "aws_security_group_invalid_protocol" {
  enabled = true
}

# =============================================================================
# Google Cloud Plugin Rules (uncomment if using GCP)
# =============================================================================

# plugin "google" {
#   enabled = true
#   version = "0.26.0"
#   source  = "github.com/terraform-linters/tflint-ruleset-google"
# }

# =============================================================================
# Azure Plugin Rules (uncomment if using Azure)
# =============================================================================

# plugin "azurerm" {
#   enabled = true
#   version = "0.25.1"
#   source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
# }
