# Development Environment Configuration

# Call the infrastructure module with dev-specific configuration
module "polaris_infrastructure" {
  source = "../../modules/infrastructure"

  # Environment-specific variables (values come from auto.tfvars files)
  project_id               = var.project_id
  environment              = "dev"
  default_region           = var.default_region
  default_zone             = var.default_zone
  subnet_cidr              = var.subnet_cidr
  private_ip_prefix_length = var.private_ip_prefix_length
  
  # Cloud SQL Configuration
  cloudsql_instance_name       = var.cloudsql_instance_name
  cloudsql_database_version    = var.cloudsql_database_version
  cloudsql_tier               = var.cloudsql_tier
  cloudsql_disk_size          = var.cloudsql_disk_size
  cloudsql_deletion_protection = var.cloudsql_deletion_protection
  cloudsql_authorized_networks = var.cloudsql_authorized_networks
  
  # Cloud Run Configuration
  cloudrun_cpu                    = var.cloudrun_cpu
  cloudrun_memory                 = var.cloudrun_memory
  cloudrun_min_instances          = var.cloudrun_min_instances
  cloudrun_max_instances          = var.cloudrun_max_instances
  
  # IAP Configuration
  iap_users = var.iap_users
  
  # Bastion Host Configuration
  bastion_enabled           = var.bastion_enabled
  bastion_machine_type      = var.bastion_machine_type
  bastion_disk_size         = var.bastion_disk_size
  bastion_disk_type         = var.bastion_disk_type
  bastion_ssh_keys          = var.bastion_ssh_keys
  bastion_schedule_enabled  = var.bastion_schedule_enabled
  bastion_stop_schedule     = var.bastion_stop_schedule
  bastion_schedule_timezone = var.bastion_schedule_timezone
}