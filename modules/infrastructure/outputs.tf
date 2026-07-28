output "vpc_network_id" {
  value = data.google_compute_network.shared_vpc.id
}

output "subnet_id" {
  value = data.google_compute_subnetwork.shared_subnet.id
}

output "private_ip_allocation_name" {
  value = google_compute_global_address.private_ip_allocation.name
}

output "private_vpc_connection_network" {
  value = google_service_networking_connection.private_vpc_connection.network
}

output "enabled_apis" {
  value = local.required_apis
}

output "service_accounts" {
  value = {
    polaris_portal           = { email = google_service_account.polaris_portal.email, name = google_service_account.polaris_portal.name, id = google_service_account.polaris_portal.id }
    knowledge_management_api = { email = google_service_account.knowledge_management_api.email, name = google_service_account.knowledge_management_api.name, id = google_service_account.knowledge_management_api.id }
    opensearch_vector_db     = { email = google_service_account.opensearch_vector_db.email, name = google_service_account.opensearch_vector_db.name, id = google_service_account.opensearch_vector_db.id }
    keycloak                 = { email = google_service_account.keycloak.email, name = google_service_account.keycloak.name, id = google_service_account.keycloak.id }
  }
}

output "cloudsql_instance" {
  value = {
    name               = google_sql_database_instance.postgres_instance.name
    connection_name    = google_sql_database_instance.postgres_instance.connection_name
    private_ip_address = google_sql_database_instance.postgres_instance.private_ip_address
    region             = google_sql_database_instance.postgres_instance.region
    database_version   = google_sql_database_instance.postgres_instance.database_version
  }
}

output "cloudsql_databases" {
  value = {
    marketplace = google_sql_database.marketplace_db.name
    knowledge   = google_sql_database.knowledge_db.name
    keycloak    = google_sql_database.keycloak_db.name
  }
}

output "secret_manager_secrets" {
  value = {
    marketplace_db_password = google_secret_manager_secret.marketplace_db_password.secret_id
    knowledge_db_password   = google_secret_manager_secret.knowledge_db_password.secret_id
    keycloak_db_password    = google_secret_manager_secret.keycloak_db_password.secret_id
  }
}

output "cloudrun_services" {
  value = {
    polaris_portal           = { name = google_cloud_run_v2_service.polaris_portal.name, url = google_cloud_run_v2_service.polaris_portal.uri, access_type = "external" }
    knowledge_management_api = { name = google_cloud_run_v2_service.knowledge_management_api.name, url = google_cloud_run_v2_service.knowledge_management_api.uri, access_type = "internal" }
    opensearch_vector_db     = { name = google_cloud_run_v2_service.opensearch_vector_db.name, url = google_cloud_run_v2_service.opensearch_vector_db.uri, access_type = "internal" }
    keycloak                 = { name = google_cloud_run_v2_service.keycloak.name, url = google_cloud_run_v2_service.keycloak.uri, access_type = "internal" }
  }
}

output "external_service_urls" {
  value = { polaris_portal = google_cloud_run_v2_service.polaris_portal.uri }
}

output "internal_service_urls" {
  value = {
    knowledge_management_api = google_cloud_run_v2_service.knowledge_management_api.uri
    opensearch_vector_db     = google_cloud_run_v2_service.opensearch_vector_db.uri
    keycloak                 = google_cloud_run_v2_service.keycloak.uri
  }
}

output "bastion_host" {
  value = var.bastion_enabled ? {
    name                    = google_compute_instance.bastion[0].name
    internal_ip             = google_compute_instance.bastion[0].network_interface[0].network_ip
    zone                    = google_compute_instance.bastion[0].zone
    ssh_command             = "gcloud compute ssh ${google_compute_instance.bastion[0].name} --zone=${google_compute_instance.bastion[0].zone} --project=${var.project_id}"
    cloud_sql_proxy_command = "cloud-sql-proxy --port=5432 ${google_sql_database_instance.postgres_instance.connection_name}"
  } : null
}

output "storage_buckets" {
  value = {
    knowledge_data     = { name = google_storage_bucket.knowledge_data.name, url = google_storage_bucket.knowledge_data.url }
    keycloak_providers = { name = google_storage_bucket.keycloak_providers.name, url = google_storage_bucket.keycloak_providers.url }
    opensearch_data    = { name = google_storage_bucket.opensearch_data.name, url = google_storage_bucket.opensearch_data.url }
  }
}
