# Cloud Run Services Configuration
# This file contains all Cloud Run service definitions

# Polaris Portal Cloud Run Service (IAP Protected)
resource "google_cloud_run_v2_service" "polaris_portal" {
  name     = "polaris-portal-${var.environment}"
  provider = google-beta
  location = var.default_region
  project  = var.project_id
  iap_enabled = true

  # Allow external traffic but require authentication via IAP
  ingress = "INGRESS_TRAFFIC_ALL"

  lifecycle {
    ignore_changes = [
      template.0.containers.0.image
    ]
  }

  template {
    service_account = google_service_account.polaris_portal.email
    
    # Enable IAP - no anonymous access
    annotations = {
      "run.googleapis.com/ingress" = "all"
    }
    
    scaling {
      min_instance_count = var.cloudrun_min_instances
      max_instance_count = var.cloudrun_max_instances
    }

    # VPC Access Configuration
    vpc_access {
      egress = "ALL_TRAFFIC"
      network_interfaces {
        network    = google_compute_network.vpc_network.id
        subnetwork = google_compute_subnetwork.subnet.id
      }
    }

    containers {
      image = "gcr.io/cloudrun/hello"
      
      ports {
        container_port = var.cloudrun_port
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
        name = "DB_PASSWORD_SECRET"
        value = google_secret_manager_secret.marketplace_db_password.secret_id
      }
    }
  }

  depends_on = [
    google_project_service.required_apis["run.googleapis.com"]
  ]
}

# Knowledge Management API Cloud Run Service (Internal VPC Only)
resource "google_cloud_run_v2_service" "knowledge_management_api" {
  name     = "knowledge-mgmt-api-${var.environment}"
  location = var.default_region
  project  = var.project_id
  
  # Internal VPC access only
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  lifecycle {
    ignore_changes = [
      template.0.containers.0.image
    ]
  }

  template {
    service_account = google_service_account.knowledge_management_api.email
    
    scaling {
      min_instance_count = var.cloudrun_min_instances
      max_instance_count = var.cloudrun_max_instances
    }

    # VPC Access Configuration
    vpc_access {
      egress = "ALL_TRAFFIC"
      network_interfaces {
        network    = google_compute_network.vpc_network.id
        subnetwork = google_compute_subnetwork.subnet.id
      }
    }

    containers {
      image = "gcr.io/cloudrun/hello"
      
      ports {
        container_port = var.cloudrun_port
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
        name = "DB_PASSWORD_SECRET"
        value = google_secret_manager_secret.knowledge_db_password.secret_id
      }

      # Mount Cloud Storage volume for data storage
      volume_mounts {
        name       = "knowledge-data-volume"
        mount_path = "/app/data"
      }
    }

    # Cloud Storage volume for knowledge data
    volumes {
      name = "knowledge-data-volume"
      gcs {
        bucket    = google_storage_bucket.knowledge_data.name
        read_only = false
      }
    }
  }

  depends_on = [
    google_project_service.required_apis["run.googleapis.com"]
  ]
}

# OpenSearch Vector DB Cloud Run Service (Internal VPC Only)
resource "google_cloud_run_v2_service" "opensearch_vector_db" {
  name     = "opensearch-vector-${var.environment}"
  location = var.default_region
  project  = var.project_id
  
  # Internal VPC access only
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  lifecycle {
    ignore_changes = [
      template.0.containers.0.image
    ]
  }

  template {
    service_account = google_service_account.opensearch_vector_db.email
    
    scaling {
      min_instance_count = var.cloudrun_min_instances
      max_instance_count = var.cloudrun_max_instances
    }

    # VPC Access Configuration
    vpc_access {
      egress = "ALL_TRAFFIC"
      network_interfaces {
        network    = google_compute_network.vpc_network.id
        subnetwork = google_compute_subnetwork.subnet.id
      }
    }

    containers {
      image = "gcr.io/cloudrun/hello"
      
      ports {
        container_port = var.cloudrun_port
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

      # Mount Cloud Storage volume for vector data storage
      volume_mounts {
        name       = "opensearch-data-volume"
        mount_path = "/usr/share/opensearch/data"
      }
    }

    # Cloud Storage volume for opensearch vector data
    volumes {
      name = "opensearch-data-volume"
      gcs {
        bucket    = google_storage_bucket.opensearch_data.name
        read_only = false
      }
    }
  }

  depends_on = [
    google_project_service.required_apis["run.googleapis.com"]
  ]
}

# Keycloak Cloud Run Service (Internal VPC Only)
resource "google_cloud_run_v2_service" "keycloak" {
  name     = "keycloak-${var.environment}"
  location = var.default_region
  project  = var.project_id
  
  # Internal VPC access only
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  lifecycle {
    ignore_changes = [
      template.0.containers.0.image
    ]
  }

  template {
    service_account = google_service_account.keycloak.email
    
    scaling {
      min_instance_count = var.cloudrun_min_instances
      max_instance_count = var.cloudrun_max_instances
    }

    # VPC Access Configuration
    vpc_access {
      egress = "ALL_TRAFFIC"
      network_interfaces {
        network    = google_compute_network.vpc_network.id
        subnetwork = google_compute_subnetwork.subnet.id
      }
    }

    containers {
      image = "gcr.io/cloudrun/hello"
      
      ports {
        container_port = var.cloudrun_port
      }

      resources {
        limits = {
          cpu    = var.cloudrun_cpu
          memory = var.cloudrun_memory
        }
      }

      env {
        name  = "SERVICE_NAME"
        value = "keycloak"
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
        value = google_sql_database.keycloak_db.name
      }

      env {
        name  = "DB_USER"
        value = google_sql_user.keycloak_user.name
      }

      env {
        name = "DB_PASSWORD_SECRET"
        value = google_secret_manager_secret.keycloak_db_password.secret_id
      }

      # Mount Cloud Storage volume for providers/themes
      volume_mounts {
        name       = "keycloak-providers-volume"
        mount_path = "/opt/keycloak/providers"
      }
    }

    # Cloud Storage volume for keycloak providers and themes
    volumes {
      name = "keycloak-providers-volume"
      gcs {
        bucket    = google_storage_bucket.keycloak_providers.name
        read_only = false
      }
    }
  }

  depends_on = [
    google_project_service.required_apis["run.googleapis.com"]
  ]
}

# IAP Configuration for Polaris Portal Cloud Run Service
# IAP is enabled via annotation above and IAM permissions in iam.tf
# Users in var.iap_users get roles/run.invoker access to authenticate