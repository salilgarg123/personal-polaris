# Infrastructure Module Outputs

output "vpc_network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "private_ip_allocation_name" {
  description = "Name of the private IP allocation for managed services"
  value       = google_compute_global_address.private_ip_allocation.name
}

output "private_vpc_connection_network" {
  description = "Network name for the private VPC connection"
  value       = google_service_networking_connection.private_vpc_connection.network
}

output "nat_router_name" {
  description = "Name of the Cloud Router for NAT"
  value       = google_compute_router.nat_router.name
}

output "nat_gateway_name" {
  description = "Name of the Cloud NAT gateway"
  value       = google_compute_router_nat.nat_gateway.name
}

output "enabled_apis" {
  description = "List of enabled Google Cloud APIs"
  value       = local.required_apis
}

# Service Account Outputs
output "service_accounts" {
  description = "Service account information for Cloud Run services"
  value = {
    polaris_portal = {
      email = google_service_account.polaris_portal.email
      name  = google_service_account.polaris_portal.name
      id    = google_service_account.polaris_portal.id
    }
    knowledge_management_api = {
      email = google_service_account.knowledge_management_api.email
      name  = google_service_account.knowledge_management_api.name
      id    = google_service_account.knowledge_management_api.id
    }
    opensearch_vector_db = {
      email = google_service_account.opensearch_vector_db.email
      name  = google_service_account.opensearch_vector_db.name
      id    = google_service_account.opensearch_vector_db.id
    }
    keycloak = {
      email = google_service_account.keycloak.email
      name  = google_service_account.keycloak.name
      id    = google_service_account.keycloak.id
    }
  }
}

# Cloud SQL Outputs
output "cloudsql_instance" {
  description = "Cloud SQL instance information"
  value = {
    name                = google_sql_database_instance.postgres_instance.name
    connection_name     = google_sql_database_instance.postgres_instance.connection_name
    private_ip_address  = google_sql_database_instance.postgres_instance.private_ip_address
    region             = google_sql_database_instance.postgres_instance.region
    database_version   = google_sql_database_instance.postgres_instance.database_version
    authorized_networks = local.all_authorized_networks
  }
}

output "cloudsql_databases" {
  description = "Database names for each service"
  value = {
    marketplace = google_sql_database.marketplace_db.name
    knowledge   = google_sql_database.knowledge_db.name
    keycloak    = google_sql_database.keycloak_db.name
  }
}

output "cloudsql_users" {
  description = "Database user information (passwords are sensitive)"
  value = {
    marketplace = {
      username = google_sql_user.marketplace_user.name
    }
    knowledge = {
      username = google_sql_user.knowledge_user.name
    }
    keycloak = {
      username = google_sql_user.keycloak_user.name
    }
  }
}

output "cloudsql_connection_strings" {
  description = "Connection information for databases"
  value = {
    marketplace = {
      host     = google_sql_database_instance.postgres_instance.private_ip_address
      database = google_sql_database.marketplace_db.name
      username = google_sql_user.marketplace_user.name
      #password = random_password.marketplace_db_password.result
    }
    knowledge = {
      host     = google_sql_database_instance.postgres_instance.private_ip_address
      database = google_sql_database.knowledge_db.name
      username = google_sql_user.knowledge_user.name
      #password = random_password.knowledge_db_password.result
    }
    keycloak = {
      host     = google_sql_database_instance.postgres_instance.private_ip_address
      database = google_sql_database.keycloak_db.name
      username = google_sql_user.keycloak_user.name
      #password = random_password.keycloak_db_password.result
    }
  }
}

# Secret Manager outputs
output "secret_manager_secrets" {
  description = "Secret Manager secret IDs for database passwords"
  value = {
    marketplace_db_password = google_secret_manager_secret.marketplace_db_password.secret_id
    knowledge_db_password   = google_secret_manager_secret.knowledge_db_password.secret_id
    keycloak_db_password    = google_secret_manager_secret.keycloak_db_password.secret_id
  }
}

# Cloud Run Service Outputs
output "cloudrun_services" {
  description = "Cloud Run service information with access types"
  value = {
    polaris_portal = {
      name        = google_cloud_run_v2_service.polaris_portal.name
      url         = google_cloud_run_v2_service.polaris_portal.uri
      id          = google_cloud_run_v2_service.polaris_portal.id
      access_type = "external"
      description = "Main web portal - accessible from load balancers"
    }
    knowledge_management_api = {
      name        = google_cloud_run_v2_service.knowledge_management_api.name
      url         = google_cloud_run_v2_service.knowledge_management_api.uri
      id          = google_cloud_run_v2_service.knowledge_management_api.id
      access_type = "internal"
      description = "API service - VPC internal access only"
    }
    opensearch_vector_db = {
      name        = google_cloud_run_v2_service.opensearch_vector_db.name
      url         = google_cloud_run_v2_service.opensearch_vector_db.uri
      id          = google_cloud_run_v2_service.opensearch_vector_db.id
      access_type = "internal"
      description = "Vector database service - VPC internal access only"
    }
    keycloak = {
      name        = google_cloud_run_v2_service.keycloak.name
      url         = google_cloud_run_v2_service.keycloak.uri
      id          = google_cloud_run_v2_service.keycloak.id
      access_type = "internal"
      description = "Identity management service - VPC internal access only"
    }
  }
}

# Separate outputs for external and internal service URLs
output "external_service_urls" {
  description = "URLs for externally accessible services (authenticated access only)"
  value = {
    polaris_portal = google_cloud_run_v2_service.polaris_portal.uri
  }
}

output "internal_service_urls" {
  description = "URLs for VPC-internal services (accessible from within VPC)"
  value = {
    knowledge_management_api = google_cloud_run_v2_service.knowledge_management_api.uri
    opensearch_vector_db     = google_cloud_run_v2_service.opensearch_vector_db.uri
    keycloak                = google_cloud_run_v2_service.keycloak.uri
  }
}

# Bastion Host Outputs
output "bastion_host" {
  description = "Bastion host connection information (IAP tunnel access)"
  value = var.bastion_enabled ? {
    enabled     = true
    name        = google_compute_instance.bastion[0].name
    internal_ip = google_compute_instance.bastion[0].network_interface[0].network_ip
    zone        = google_compute_instance.bastion[0].zone
    access_method = "IAP tunnel"
    ssh_command = "gcloud compute ssh ${google_compute_instance.bastion[0].name} --zone=${google_compute_instance.bastion[0].zone} --project=${var.project_id}"
    cloud_sql_proxy_command = "cloud-sql-proxy --port=5432 ${google_sql_database_instance.postgres_instance.connection_name}"
    iap_tunnel_command = "gcloud compute start-iap-tunnel ${google_compute_instance.bastion[0].name} 22 --local-host-port=localhost:2222 --zone=${google_compute_instance.bastion[0].zone} --project=${var.project_id}"
  } : {
    enabled = false
  }
}

output "bastion_internal_ip" {
  description = "Internal IP address of the bastion host"
  value       = var.bastion_enabled ? google_compute_instance.bastion[0].network_interface[0].network_ip : null
}

output "bastion_iap_access_commands" {
  description = "Commands to access bastion host via IAP"
  value = var.bastion_enabled ? {
    direct_ssh = "gcloud compute ssh ${google_compute_instance.bastion[0].name} --zone=${google_compute_instance.bastion[0].zone} --project=${var.project_id}"
    tunnel_ssh = "gcloud compute start-iap-tunnel ${google_compute_instance.bastion[0].name} 22 --local-host-port=localhost:2222 --zone=${google_compute_instance.bastion[0].zone} --project=${var.project_id}"
    after_tunnel = "ssh -o ProxyCommand='gcloud compute start-iap-tunnel ${google_compute_instance.bastion[0].name} 22 --zone=${google_compute_instance.bastion[0].zone} --project=${var.project_id} --listen-on-stdin' ubuntu@${google_compute_instance.bastion[0].name}"
  } : null
}

output "bastion_schedule" {
  description = "Bastion host scheduling information"
  value = var.bastion_enabled && var.bastion_schedule_enabled ? {
    enabled = true
    schedule = var.bastion_stop_schedule
    timezone = var.bastion_schedule_timezone
    description = "Bastion host will be automatically stopped daily"
    start_command = "gcloud compute instances start ${google_compute_instance.bastion[0].name} --zone=${google_compute_instance.bastion[0].zone} --project=${var.project_id}"
  } : {
    enabled = false
  }
}

# Cloud Storage Outputs
output "storage_buckets" {
  description = "Cloud Storage bucket information for volume mounts"
  value = {
    knowledge_data = {
      name = google_storage_bucket.knowledge_data.name
      url  = google_storage_bucket.knowledge_data.url
      mount_path = "/app/data"
      service = "Knowledge Management API"
    }
    keycloak_providers = {
      name = google_storage_bucket.keycloak_providers.name
      url  = google_storage_bucket.keycloak_providers.url
      mount_path = "/opt/keycloak/providers"
      service = "Keycloak"
    }
    opensearch_data = {
      name = google_storage_bucket.opensearch_data.name
      url  = google_storage_bucket.opensearch_data.url
      mount_path = "/usr/share/opensearch/data"
      service = "OpenSearch Vector DB"
    }
  }
}