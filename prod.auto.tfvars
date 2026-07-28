# Production Environment Configuration
# This file contains prod-specific overrides and settings

# Production-specific regional settings
default_region = "us-east1"
default_zone   = "us-east1-a"

# Production-specific network settings
subnet_cidr              = "10.3.0.0/24"
private_ip_prefix_length = 16  # For Cloud SQL and other managed services