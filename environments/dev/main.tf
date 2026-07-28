module "polaris_infrastructure" {
  source = "../../modules/infrastructure"

  project_id               = var.project_id
  environment              = "dev"
  default_region           = var.default_region
  default_zone             = var.default_zone
  shared_vpc_host_project  = var.shared_vpc_host_project
  shared_vpc_network_name  = var.shared_vpc_network_name
  shared_vpc_subnet_name   = var.shared_vpc_subnet_name
  private_ip_prefix_length = var.private_ip_prefix_length

  cloudsql_instance_name       = var.cloudsql_instance_name
  cloudsql_database_version    = var.cloudsql_database_version
  cloudsql_tier                = var.cloudsql_tier
  cloudsql_disk_size           = var.cloudsql_disk_size
  cloudsql_deletion_protection = var.cloudsql_deletion_protection
  cloudsql_authorized_networks = var.cloudsql_authorized_networks

  container_images = var.container_images

  iap_users = var.iap_users

  bastion_enabled           = var.bastion_enabled
  bastion_machine_type      = var.bastion_machine_type
  bastion_disk_size         = var.bastion_disk_size
  bastion_disk_type         = var.bastion_disk_type
  bastion_ssh_keys          = var.bastion_ssh_keys
  bastion_schedule_enabled  = var.bastion_schedule_enabled
  bastion_stop_schedule     = var.bastion_stop_schedule
  bastion_schedule_timezone = var.bastion_schedule_timezone
}
