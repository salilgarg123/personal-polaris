resource "google_cloud_run_v2_service" "polaris_portal" {
  name        = "polaris-portal-${var.environment}"
  provider    = google-beta
  location    = var.default_region
  project     = var.project_id
  iap_enabled = true
  ingress     = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.polaris_portal.email
    scaling {
      min_instance_count = var.cloudrun_min_instances
      max_instance_count = var.cloudrun_max_instances
    }
    vpc_access {
      egress = "ALL_TRAFFIC"
      network_interfaces {
        network    = data.google_compute_network.shared_vpc.id
        subnetwork = data.google_compute_subnetwork.shared_subnet.id
      }
    }
    containers {
      image = var.container_images.polaris_portal
      ports {
        container_port = 3000
      }
      resources {
        limits = {
          cpu    = var.cloudrun_cpu
          memory = var.cloudrun_memory
        }
      }
      env {
        name  = "SERVICE_NAME"
        value = "polaris-portal"
      }
      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.postgres_instance.private_ip_address
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.marketplace_db.name
      }
      env {
        name  = "DB_USER"
        value = google_sql_user.marketplace_user.name
      }
      env {
        name  = "DB_PASSWORD_SECRET"
        value = google_secret_manager_secret.marketplace_db_password.secret_id
      }
    }
  }

  depends_on = [google_project_service.required_apis["run.googleapis.com"]]
}

resource "google_cloud_run_v2_service" "knowledge_management_api" {
  name     = "knowledge-mgmt-api-${var.environment}"
  location = var.default_region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    service_account = google_service_account.knowledge_management_api.email
    scaling {
      min_instance_count = var.cloudrun_min_instances
      max_instance_count = var.cloudrun_max_instances
    }
    vpc_access {
      egress = "ALL_TRAFFIC"
      network_interfaces {
        network    = data.google_compute_network.shared_vpc.id
        subnetwork = data.google_compute_subnetwork.shared_subnet.id
      }
    }
    containers {
      image = var.container_images.knowledge_api
      ports {
        container_port = 8000
      }
      resources {
        limits = {
          cpu    = var.cloudrun_cpu
          memory = var.cloudrun_memory
        }
      }
      env {
        name  = "SERVICE_NAME"
        value = "knowledge-management-api"
      }
      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.postgres_instance.private_ip_address
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.knowledge_db.name
      }
      env {
        name  = "DB_USER"
        value = google_sql_user.knowledge_user.name
      }
      env {
        name  = "DB_PASSWORD_SECRET"
        value = google_secret_manager_secret.knowledge_db_password.secret_id
      }
      volume_mounts {
        name       = "knowledge-data-volume"
        mount_path = "/app/data"
      }
    }
    volumes {
      name = "knowledge-data-volume"
      gcs {
        bucket    = google_storage_bucket.knowledge_data.name
        read_only = false
      }
    }
  }

  depends_on = [google_project_service.required_apis["run.googleapis.com"]]
}

resource "google_cloud_run_v2_service" "opensearch_vector_db" {
  name     = "opensearch-vector-${var.environment}"
  location = var.default_region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  lifecycle { ignore_changes = all }

  template {
    service_account = google_service_account.opensearch_vector_db.email
    scaling {
      min_instance_count = var.cloudrun_min_instances
      max_instance_count = var.cloudrun_max_instances
    }
    vpc_access {
      egress = "ALL_TRAFFIC"
      network_interfaces {
        network    = data.google_compute_network.shared_vpc.id
        subnetwork = data.google_compute_subnetwork.shared_subnet.id
      }
    }
    containers {
      image = "gcr.io/cloudrun/hello"
      ports {
        container_port = 8080
      }
      resources {
        limits = {
          cpu    = var.cloudrun_cpu
          memory = var.cloudrun_memory
        }
      }
      env {
        name  = "SERVICE_NAME"
        value = "opensearch-vector-db"
      }
      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
    }
  }

  depends_on = [google_project_service.required_apis["run.googleapis.com"]]
}

resource "google_cloud_run_v2_service" "keycloak" {
  name     = "keycloak-${var.environment}"
  location = var.default_region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    service_account = google_service_account.keycloak.email
    scaling {
      min_instance_count = var.cloudrun_min_instances
      max_instance_count = var.cloudrun_max_instances
    }
    vpc_access {
      egress = "ALL_TRAFFIC"
      network_interfaces {
        network    = data.google_compute_network.shared_vpc.id
        subnetwork = data.google_compute_subnetwork.shared_subnet.id
      }
    }
    containers {
      image = var.container_images.keycloak
      command = ["/opt/keycloak/bin/kc.sh"]
      args    = ["start-dev"]
      ports {
        container_port = 8080
      }
      resources {
        limits = {
          cpu    = "2"
          memory = "1Gi"
        }
      }
      env {
        name  = "KC_DB"
        value = "postgres"
      }
      env {
        name  = "KC_DB_URL"
        value = "jdbc:postgresql://${google_sql_database_instance.postgres_instance.private_ip_address}:5432/${google_sql_database.keycloak_db.name}"
      }
      env {
        name  = "KC_DB_USERNAME"
        value = google_sql_user.keycloak_user.name
      }
      env {
        name = "KC_DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.keycloak_db_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "KC_HEALTH_ENABLED"
        value = "true"
      }
      env {
        name  = "KC_HTTP_ENABLED"
        value = "true"
      }
      env {
        name  = "KC_HOSTNAME_STRICT"
        value = "false"
      }
      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
    }
  }

  depends_on = [
    google_project_service.required_apis["run.googleapis.com"],
    google_artifact_registry_repository.quay_remote
  ]
}
