# ============================================================================
# MAIN CONFIGURATION & DATA SOURCES
# ============================================================================
# This file contains:
# - Local values for computed values
# - Data sources for AWS resources
# - Common tagging strategy

# ============================================================================
# LOCAL VALUES
# ============================================================================

locals {
  app_name = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Name        = local.app_name
    Project     = var.project_name
    Environment = var.environment
  }
}

# ============================================================================
# DATA SOURCES
# ============================================================================

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}
