# Common configuration shared across all environments
# This file is automatically loaded by Terraform in all environments via symlinks

# Project Configuration - Environment-specific project IDs are defined in each environment file
# project_id = "override-in-environment-files"

# Default regional settings - can be overridden per environment
default_region = "us-central1"
default_zone   = "us-central1-a"

# Network Configuration
subnet_cidr = "10.0.0.0/24"