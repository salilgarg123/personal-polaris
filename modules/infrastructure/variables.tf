# Infrastructure Module Variables

variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "default_region" {
  description = "Default Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "default_zone" {
  description = "Default Google Cloud zone"
  type        = string
  default     = "us-central1-a"
}

# Network configuration
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_ip_prefix_length" {
  description = "Prefix length for private IP allocation for managed services"
  type        = number
  default     = 16
}

# Cloud SQL Configuration
variable "cloudsql_instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
  default     = null
}

variable "cloudsql_database_version" {
  description = "PostgreSQL version for Cloud SQL instance"
  type        = string
  default     = "POSTGRES_15"
}

variable "cloudsql_tier" {
  description = "Machine type for Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "cloudsql_disk_size" {
  description = "Disk size in GB for Cloud SQL instance"
  type        = number
  default     = 20
}

variable "cloudsql_disk_type" {
  description = "Disk type for Cloud SQL instance"
  type        = string
  default     = "PD_SSD"
}

variable "cloudsql_backup_enabled" {
  description = "Enable automated backups for Cloud SQL"
  type        = bool
  default     = true
}

variable "cloudsql_backup_start_time" {
  description = "Start time for automated backups (HH:MM format)"
  type        = string
  default     = "03:00"
}

variable "cloudsql_maintenance_window_day" {
  description = "Day of week for maintenance window (1-7, 1=Monday)"
  type        = number
  default     = 7
}

variable "cloudsql_maintenance_window_hour" {
  description = "Hour for maintenance window (0-23)"
  type        = number
  default     = 4
}

variable "cloudsql_deletion_protection" {
  description = "Enable deletion protection for Cloud SQL instance"
  type        = bool
  default     = true
}

variable "cloudsql_authorized_networks" {
  description = "List of authorized networks for Cloud SQL access"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Cloud Run Configuration
variable "cloudrun_cpu" {
  description = "CPU allocation for Cloud Run services"
  type        = string
  default     = "1"
}

variable "cloudrun_memory" {
  description = "Memory allocation for Cloud Run services"
  type        = string
  default     = "512Mi"
}

variable "cloudrun_min_instances" {
  description = "Minimum number of instances for Cloud Run services"
  type        = number
  default     = 0
}

variable "cloudrun_max_instances" {
  description = "Maximum number of instances for Cloud Run services"
  type        = number
  default     = 1
}

variable "cloudrun_port" {
  description = "Container port for Cloud Run services"
  type        = number
  default     = 8080
}

# Authenticated access configuration
variable "iap_users" {
  description = "List of users/groups that can access the portal (format: user:email@domain.com or group:group@domain.com)"
  type        = list(string)
  default     = []
}

# Bastion host configuration
variable "bastion_enabled" {
  description = "Enable bastion host for secure access to VPC resources"
  type        = bool
  default     = true
}

variable "bastion_machine_type" {
  description = "Machine type for the bastion host"
  type        = string
  default     = "e2-micro"
}

variable "bastion_disk_size" {
  description = "Boot disk size in GB for the bastion host"
  type        = number
  default     = 10
}

variable "bastion_disk_type" {
  description = "Boot disk type for the bastion host"
  type        = string
  default     = "pd-standard"
}

variable "bastion_ssh_keys" {
  description = "List of SSH public keys for bastion host access"
  type        = list(string)
  default     = []
}

variable "bastion_schedule_enabled" {
  description = "Enable automatic scheduling for bastion host (stop daily)"
  type        = bool
  default     = true
}

variable "bastion_stop_schedule" {
  description = "Cron schedule for stopping bastion host (in CET timezone)"
  type        = string
  default     = "0 15 * * *"  # 15:00 UTC = 16:00 CET
}

variable "bastion_schedule_timezone" {
  description = "Timezone for bastion host scheduling"
  type        = string
  default     = "Europe/Berlin"
}

# Note: bastion_allowed_cidr_blocks not needed for IAP tunnel access

