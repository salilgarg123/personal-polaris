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
  type = string
}

variable "cloudsql_disk_size" {
  type = number
}

variable "cloudsql_deletion_protection" {
  type = bool
}

variable "cloudsql_authorized_networks" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "cloudrun_cpu" {
  type = string
}

variable "cloudrun_memory" {
  type = string
}

variable "cloudrun_min_instances" {
  type = number
}

variable "cloudrun_max_instances" {
  type = number
}

variable "iap_users" {
  type    = list(string)
  default = []
}

variable "bastion_enabled" {
  type = bool
}

variable "bastion_machine_type" {
  type = string
}

variable "bastion_disk_size" {
  type = number
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
    polaris_portal = string
    knowledge_api  = string
    opensearch     = string
    keycloak       = string
  })
  default = {
    polaris_portal = "gcr.io/cloudrun/hello"
    knowledge_api  = "gcr.io/cloudrun/hello"
    opensearch     = "gcr.io/cloudrun/hello"
    keycloak       = "us-central1-docker.pkg.dev/prj-d-bu1-sample-base-qopg/quay-remote/keycloak/keycloak:26.4.0"
  }
}
