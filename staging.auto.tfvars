# Staging Environment Configuration
# This file contains staging-specific overrides and settings

# Staging-specific regional settings
default_region = "us-west1"
default_zone   = "us-west1-a"

# Staging-specific network settings
subnet_cidr              = "10.2.0.0/24"
private_ip_prefix_length = 16  # For Cloud SQL and other managed services