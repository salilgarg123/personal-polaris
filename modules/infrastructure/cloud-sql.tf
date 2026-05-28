locals {
  cloudsql_instance_name  = var.cloudsql_instance_name != null ? var.cloudsql_instance_name : "polaris-${var.environment}-postgres"
  all_authorized_networks = var.cloudsql_authorized_networks
}

resource "google_sql_database_instance" "postgres_instance" {
  name             = local.cloudsql_instance_name
  database_version = var.cloudsql_database_version
  region           = var.default_region
  project          = var.project_id

  deletion_protection = var.cloudsql_deletion_protection

  settings {
    tier                  = var.cloudsql_tier
    availability_type     = var.environment == "prod" ? "REGIONAL" : "ZONAL"
    disk_size             = var.cloudsql_disk_size
    disk_type             = var.cloudsql_disk_type
    disk_autoresize       = true
    disk_autoresize_limit = var.cloudsql_disk_size * 3

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = data.google_compute_network.shared_vpc.id
      enable_private_path_for_google_cloud_services = true

      dynamic "authorized_networks" {
        for_each = local.all_authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    backup_configuration {
      enabled                        = var.cloudsql_backup_enabled
      start_time                     = var.cloudsql_backup_start_time
      location                       = var.default_region
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = var.environment == "prod" ? 30 : 7
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = var.cloudsql_maintenance_window_day
      hour         = var.cloudsql_maintenance_window_hour
      update_track = "stable"
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "log_statement"
      value = "ddl"
    }
  }

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_project_service.required_apis["sqladmin.googleapis.com"]
  ]
}

resource "google_sql_database" "marketplace_db" {
  name     = "marketplace"
  instance = google_sql_database_instance.postgres_instance.name
  project  = var.project_id
}

resource "google_sql_database" "knowledge_db" {
  name     = "knowledge"
  instance = google_sql_database_instance.postgres_instance.name
  project  = var.project_id
}

resource "google_sql_database" "keycloak_db" {
  name     = "keycloak"
  instance = google_sql_database_instance.postgres_instance.name
  project  = var.project_id
}

resource "random_password" "marketplace_db_password" {
  length  = 32
  special = true
}

resource "google_secret_manager_secret" "marketplace_db_password" {
  secret_id = "marketplace-db-password-${var.environment}"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "marketplace_db_password" {
  secret      = google_secret_manager_secret.marketplace_db_password.id
  secret_data = random_password.marketplace_db_password.result
}

resource "google_sql_user" "marketplace_user" {
  name     = "marketplace"
  instance = google_sql_database_instance.postgres_instance.name
  password = random_password.marketplace_db_password.result
  project  = var.project_id
}

resource "random_password" "knowledge_db_password" {
  length  = 32
  special = true
}

resource "google_secret_manager_secret" "knowledge_db_password" {
  secret_id = "knowledge-db-password-${var.environment}"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "knowledge_db_password" {
  secret      = google_secret_manager_secret.knowledge_db_password.id
  secret_data = random_password.knowledge_db_password.result
}

resource "google_sql_user" "knowledge_user" {
  name     = "knowledge"
  instance = google_sql_database_instance.postgres_instance.name
  password = random_password.knowledge_db_password.result
  project  = var.project_id
}

resource "random_password" "keycloak_db_password" {
  length  = 32
  special = true
}

resource "google_secret_manager_secret" "keycloak_db_password" {
  secret_id = "keycloak-db-password-${var.environment}"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "keycloak_db_password" {
  secret      = google_secret_manager_secret.keycloak_db_password.id
  secret_data = random_password.keycloak_db_password.result
}

resource "google_sql_user" "keycloak_user" {
  name     = "keycloak"
  instance = google_sql_database_instance.postgres_instance.name
  password = random_password.keycloak_db_password.result
  project  = var.project_id
}
