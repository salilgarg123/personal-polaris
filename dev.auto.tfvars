# Development Environment Configuration
# This file contains dev-specific overrides and settings

# Dev Project Configuration
# For single-project setup (current): use the base project ID
project_id = "prj-sbx-polarisai-160925"
# For multi-project setup: use environment-specific project ID
# project_id = "prj-sbx-polarisai-160925-dev"

# Dev-specific regional settings (override common if needed)
# default_region = "us-west1"
# default_zone   = "us-west1-a"

# Dev-specific network settings
subnet_cidr = "10.1.0.0/24"

# Cloud SQL configuration for dev
cloudsql_tier               = "db-f1-micro"
cloudsql_disk_size          = 20
cloudsql_deletion_protection = false

# Cloud Run configuration for dev
cloudrun_cpu         = "1"
cloudrun_memory      = "512Mi"
cloudrun_min_instances = 0
cloudrun_max_instances = 3


iap_users = ["group:Alliances-Google_Sandbox-Polars_POC-RW@atos.net"]

# Bastion host configuration for dev (IAP tunnel access)
bastion_enabled      = true
bastion_machine_type = "e2-standard-2"
bastion_disk_size    = 10
# bastion_ssh_keys = [
#   "ssh-rsa AAAAB3NzaC1yc2E... your-public-key-here"
# ]