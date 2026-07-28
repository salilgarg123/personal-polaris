variable "project_id" {
  type = string
}

variable "shared_vpc_host_project" {
  type = string
}

variable "shared_vpc_network_name" {
  type = string
}

variable "shared_vpc_subnet_name" {
  type = string
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "default_region" {
  type    = string
  default = "us-central1"
}

variable "default_zone" {
  type    = string
  default = "us-central1-a"
}

variable "private_ip_prefix_length" {
  type    = number
  default = 16
}

variable "cloudsql_instance_name" {
  type    = string
  default = null
}

variable "cloudsql_database_version" {
  type    = string
  default = "POSTGRES_15"
}

variable "cloudsql_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "cloudsql_disk_size" {
  type    = number
  default = 20
}

variable "cloudsql_disk_type" {
  type    = string
  default = "PD_SSD"
}

variable "cloudsql_backup_enabled" {
  type    = bool
  default = true
}

variable "cloudsql_backup_start_time" {
  type    = string
  default = "03:00"
}

variable "cloudsql_maintenance_window_day" {
  type    = number
  default = 7
}

variable "cloudsql_maintenance_window_hour" {
  type    = number
  default = 4
}

variable "cloudsql_deletion_protection" {
  type    = bool
  default = true
}

variable "cloudsql_authorized_networks" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "iap_users" {
  type    = list(string)
  default = []
}

variable "bastion_enabled" {
  type    = bool
  default = true
}

variable "bastion_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "bastion_disk_size" {
  type    = number
  default = 10
}

variable "bastion_disk_type" {
  type    = string
  default = "pd-standard"
}

variable "bastion_ssh_keys" {
  type    = list(string)
  default = []
}

variable "bastion_schedule_enabled" {
  type    = bool
  default = true
}

variable "bastion_stop_schedule" {
  type    = string
  default = "0 15 * * *"
}

variable "bastion_schedule_timezone" {
  type    = string
  default = "Europe/Berlin"
}

variable "container_images" {
  type = object({
    polaris_portal   = string
    knowledge_api    = string
    opensearch       = string
    keycloak         = string
    marketplace      = string
    admin_management = string
    agents           = string
  })
  default = {
    polaris_portal   = "gcr.io/cloudrun/hello"
    knowledge_api    = "gcr.io/cloudrun/hello"
    opensearch       = "docker.io/opensearchproject/opensearch:2"
    keycloak         = "us-central1-docker.pkg.dev/prj-d-bu1-sample-base-qopg/quay-remote/keycloak/keycloak:26.4.0"
    marketplace      = "gcr.io/cloudrun/hello"
    admin_management = "gcr.io/cloudrun/hello"
    agents           = "gcr.io/cloudrun/hello"
  }
}
