locals {
  cloud_run_domain     = "${data.google_project.project.number}.${var.default_region}.run.app"
  keycloak_hostname    = "keycloak-${var.environment}-${local.cloud_run_domain}"
  keycloak_url         = "https://${local.keycloak_hostname}"
  portal_url           = "https://polaris-portal-${var.environment}-${local.cloud_run_domain}"
  knowledge_api_url    = "https://knowledge-mgmt-api-${var.environment}-${local.cloud_run_domain}"
  agents_url           = "https://agents-${var.environment}-${local.cloud_run_domain}"
  admin_management_url = "https://admin-management-${var.environment}-${local.cloud_run_domain}"
  marketplace_url      = "https://atos-ai-marketplace-${local.cloud_run_domain}"
}

resource "google_cloud_run_v2_service" "polaris_portal" {
  name     = "polaris-portal-${var.environment}"
  provider = google-beta
  location = var.default_region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }

  template {
    service_account                  = google_service_account.polaris_portal.email
    timeout                          = "300s"
    max_instance_request_concurrency = 80

    scaling {
      min_instance_count = 1
      max_instance_count = 3
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
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
        startup_cpu_boost = false
        limits = {
          cpu    = "2"
          memory = "4Gi"
        }
      }

      startup_probe {
        failure_threshold = 1
        period_seconds    = 10
        timeout_seconds   = 10
        tcp_socket {
          port = 3000
        }
      }

      env {
        name  = "AUTH_TRUST_HOST"
        value = "true"
      }
      env {
        name  = "AUTH_URL"
        value = "${local.portal_url}/auth"
      }
      env {
        name  = "DATABASE_URL"
        value = "postgresql://marketplace@${google_sql_database_instance.postgres_instance.private_ip_address}:5432/${google_sql_database.marketplace_db.name}"
      }
      env {
        name  = "AUTH_KEYCLOAK_ID"
        value = "portal"
      }
      env {
        name  = "AUTH_KEYCLOAK_ISSUER"
        value = "${local.keycloak_url}/iam/realms/polaris-ai"
      }
      env {
        name  = "KNOWLEDGE_BASE_URL"
        value = local.knowledge_api_url
      }
      env {
        name  = "AGENT_BASE_URL"
        value = local.agents_url
      }
      env {
        name  = "ADMIN_BASE_URL"
        value = local.admin_management_url
      }
      env {
        name  = "MARKETPLACE_BASE_URL"
        value = local.marketplace_url
      }
      env {
        name  = "NEXT_PUBLIC_MARKETPLACE_URL"
        value = local.marketplace_url
      }
      env {
        name = "AUTH_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.portal_auth_secret.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "AUTH_KEYCLOAK_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.portal_client_secret.secret_id
            version = "latest"
          }
        }
      }
    }
  }

  depends_on = [google_project_service.required_apis["run.googleapis.com"]]
}

resource "google_cloud_run_v2_service" "knowledge_management_api" {
  name     = "knowledge-mgmt-api-${var.environment}"
  provider = google-beta
  location = var.default_region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }

  template {
    service_account                  = google_service_account.knowledge_management_api.email
    timeout                          = "300s"
    max_instance_request_concurrency = 80

    scaling {
      min_instance_count = 1
      max_instance_count = 3
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
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
        startup_cpu_boost = false
        limits = {
          cpu    = "4"
          memory = "8Gi"
        }
      }

      startup_probe {
        failure_threshold = 1
        period_seconds    = 10
        timeout_seconds   = 10
        tcp_socket {
          port = 8000
        }
      }

      env {
        name  = "SERVICE_NAME"
        value = "knowledge-management-api"
      }
      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.postgres_instance.private_ip_address
      }
      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.knowledge_db.name
      }
      env {
        name  = "DB_PASSWORD_SECRET"
        value = "knowledge-db-password-dev"
      }
      env {
        name  = "DB_USER"
        value = "knowledge"
      }
      env {
        name  = "OTEL_SERVICE_NAME"
        value = "knowledge-mgmt-api-dev"
      }
      env {
        name  = "A_AUTH_CLIENT_ID"
        value = "knowledge"
      }
      env {
        name  = "A_USER_DOC_COUNT_LIMIT"
        value = "10"
      }
      env {
        name  = "A_AI_EMBEDDING_MODEL"
        value = "models/text-embedding-004"
      }
      env {
        name  = "A_SNOWFLAKE_HOST"
        value = "WDPKUDW-ABC41107.snowflakecomputing.com"
      }
      env {
        name  = "A_SNOWFLAKE_DATABASE"
        value = "CORTEX_ANALYST_DEMO"
      }
      env {
        name  = "A_SNOWFLAKE_SCHEMA"
        value = "REVENUE_TIMESERIES"
      }
      env {
        name  = "A_SNOWFLAKE_WAREHOUSE"
        value = "CORTEX_ANALYST_WH"
      }
      env {
        name  = "A_SNOWFLAKE_ROLE"
        value = "ACCOUNTADMIN"
      }
      env {
        name  = "A_SNOWFLAKE_ACCOUNT"
        value = "ABC41107"
      }
      env {
        name  = "A_SNOWFLAKE_USER"
        value = "atosPolarisAWS"
      }
      env {
        name  = "A_SNOWFLAKE_STAGE"
        value = "RAW_DATA"
      }
      env {
        name  = "A_SNOWFLAKE_FILE"
        value = "revenue_timeseries.yaml"
      }
      env {
        name  = "A_SNOWFLAKE_SERVICEPATH"
        value = "https://wdpkudw-abc41107.snowflakecomputing.com/api/v2/cortex/analyst/message"
      }
      env {
        name  = "A_SNOWFLAKE_SERVICE_PORT"
        value = "443"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_NAME_ADVANCED"
        value = "gpt-5.4"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_NAME_BASIC"
        value = "gpt-5.4-min"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_NAME_INTERMEDIATE"
        value = "gpt-5.4-nano"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_VERSION_ADVANCED"
        value = "2024-12-01-preview"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_VERSION_BASIC"
        value = "2024-12-01-preview"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_VERSION_INTERMEDIATE"
        value = "2024-12-01-preview"
      }
      env {
        name  = "A_IMAGE_API_VERSION"
        value = "2024-02-01"
      }
      env {
        name  = "A_IMAGE_DEPLOYMENT_NAME"
        value = "gpt-image-1-mini"
      }
      env {
        name  = "A_IMAGE_SIZE"
        value = "1024x1024"
      }
      env {
        name  = "A_IMAGE_QUALITY"
        value = "standard"
      }
      env {
        name  = "A_MMDC_BASE_PATH"
        value = "mmdc"
      }
      env {
        name  = "A_SERVICE_NAME"
        value = "mermaid-tool"
      }
      env {
        name  = "A_GUARDRAILS_GENAI_MODEL"
        value = "gemini-2.5-flash"
      }
      env {
        name  = "_INNOCUOUS_ENV_VAR"
        value = "true"
      }
      env {
        name  = "A_SNOW_INSTANCE"
        value = "https://dev281067.service-now.com"
      }
      env {
        name  = "A_SNOW_TABLE"
        value = "incident"
      }
      env {
        name  = "A_SNOW_USER"
        value = "admin"
      }
      env {
        name  = "A_PROMPT_DELETION_DAYS"
        value = "100000"
      }
      env {
        name  = "A_PII_MASKING_ENABLED"
        value = "true"
      }
      env {
        name  = "A_PII_CONFIDENCE_THRESHOLD"
        value = "0.5"
      }
      env {
        name  = "A_SNOWFLAKE_ACCOUNT_CORTEX"
        value = "moodbpj-atos_aws_us_east_rd"
      }
      env {
        name  = "A_SNOWFLAKE_USER_CORTEX"
        value = "MCHOUBEY"
      }
      env {
        name  = "A_SNOWFLAKE_ROLE_CORTEX"
        value = "ACCOUNTADMIN"
      }
      env {
        name  = "A_SNOWFLAKE_WAREHOUSE_CORTEX"
        value = "CORTEX_ANALYST_WH"
      }
      env {
        name  = "A_SNOWFLAKE_DATABASE_CORTEX"
        value = "SNOWFLAKE_DOCUMENTATION"
      }
      env {
        name  = "A_SNOWFLAKE_SCHEMA_CORTEX"
        value = "SHARED"
      }
      env {
        name  = "A_GUARDRAILS_PII_CHECK_ACTIVE"
        value = "false"
      }
      env {
        name  = "A_LLM_PROVIDER"
        value = "google-gemini"
      }
      env {
        name  = "A_GOOGLE_GEMINI_CHAT_MODEL_BASIC"
        value = "gemini-3-flash-preview"
      }
      env {
        name  = "A_GOOGLE_GEMINI_CHAT_MODEL_INTERMEDIATE"
        value = "gemini-3.5-flash"
      }
      env {
        name  = "A_GOOGLE_GEMINI_CHAT_MODEL_ADVANCED"
        value = "gemini-3.1-pro-preview"
      }
      env {
        name  = "A_GOOGLE_GEMINI_EMBEDDING_MODEL"
        value = "models/gemini-embedding-2"
      }
      env {
        name  = "A_GOOGLE_GEMINI_TIMEOUT"
        value = "180"
      }
      env {
        name  = "A_GUARDRAILS_ENABLED"
        value = "true"
      }
      env {
        name  = "A_GUARDRAILS_JAILBREAK_CHECK_ACTIVE"
        value = "true"
      }
      env {
        name  = "A_GUARDRAILS_BIAS_CHECK_ACTIVE"
        value = "true"
      }
      env {
        name  = "A_GUARDRAILS_CONTENT_CHECK_ACTIVE"
        value = "true"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_NAME_LLAMA"
        value = "Llama-4-Maverick-17B-128E-Instruct-FP8"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_VERSION_LLAMA"
        value = "2024-05-01-preview"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_NAME_MISTRAL"
        value = "mistral-small-2503"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_VERSION_MISTRAL"
        value = "2024-05-01-preview"
      }
      env {
        # TODO: migrate to Secret Manager
        name  = "A_AI_API_KEY_AUTO"
        value = "PLACEHOLDER"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_NAME_AUTO"
        value = "model-router"
      }
      env {
        name  = "A_AI_GENERATION_MODEL_VERSION_AUTO"
        value = "2024-12-01-preview"
      }
      env {
        name  = "A_IMAGE_GEN_ENDPOINT"
        value = "https://ai-foundry-polaris-prod-git-gewc.cognitiveservices.azure.com/openai/deployments/gpt-image-1-mini/images/generations?api-version=2024-02-01"
      }
      env {
        # TODO: migrate to Secret Manager
        name  = "A_IMAGE_GEN_API_KEY"
        value = "PLACEHOLDER"
      }
      env {
        # TODO: migrate to Secret Manager
        name  = "A_AI_SEARCH_API_KEY"
        value = "PLACEHOLDER"
      }
      env {
        name  = "SPX_SUBSCRIPTION_ID"
        value = "b501a57e-71d5-4887-b72c-a0c961a0f281"
      }
      env {
        name  = "SPX_RESOURCE_GROUP"
        value = "polaris-solutions-rg"
      }
      env {
        name  = "SPX_DISPATCHER_JOB_NAME"
        value = "spx-dispatcher"
      }
      env {
        name  = "A_RAG_SEARCH_PROVIDER"
        value = "OPENSEARCH"
      }
      env {
        name  = "SSP_URL"
        value = "https://salesservice.myatos.net/overall/en/salesmaterial.cfm?obj="
      }
      env {
        name  = "A_VECTOR_DB_HOST"
        value = "https://opensearch-vector-${var.environment}-${local.cloud_run_domain}"
      }
      env {
        name  = "A_FILE_SERVER_URL"
        value = "${local.portal_url}/knowledge/files"
      }
      env {
        name  = "A_PUBLIC_URL"
        value = "${local.portal_url}/knowledge"
      }
      env {
        # TODO: migrate to Secret Manager
        name  = "A_DATABASE_URL"
        value = "postgresql://postgres:PLACEHOLDER@10.83.0.3:5432/knowledge"
      }
      env {
        # TODO: migrate to Secret Manager
        name  = "A_GOOGLE_GEMINI_API_KEY"
        value = "PLACEHOLDER"
      }
      env {
        name  = "A_OPENSEARCH_EMBEDDING_DIMENSION"
        value = "3072"
      }
      env {
        name = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.appinsights_conn_str.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "A_VECTOR_DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.opensearch_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "A_SNOWFLAKE_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.snowflake_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "A_SEARCH_AGENT_ID"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.bing_search_agent_id.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "A_OPENWEATHER_API_KEY_NAME"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.openweather_api_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "A_SNOW_PASS"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.snow_pass.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "A_SNOWFLAKE_PRIVATE_KEY_CORTEX"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.snowflake_cortex_secret.secret_id
            version = "latest"
          }
        }
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
  provider = google-beta
  location = var.default_region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }

  template {
    service_account                  = google_service_account.opensearch_vector_db.email
    timeout                          = "300s"
    max_instance_request_concurrency = 80

    scaling {
      min_instance_count = 1
      max_instance_count = 1
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
      network_interfaces {
        network    = data.google_compute_network.shared_vpc.id
        subnetwork = data.google_compute_subnetwork.shared_subnet.id
      }
    }

    containers {
      image = var.container_images.opensearch

      ports {
        container_port = 9200
      }

      resources {
        startup_cpu_boost = false
        limits = {
          cpu    = "4"
          memory = "16Gi"
        }
      }

      startup_probe {
        failure_threshold     = 24
        initial_delay_seconds = 120
        period_seconds        = 10
        timeout_seconds       = 10
        tcp_socket {
          port = 9200
        }
      }

      env {
        name = "OPENSEARCH_INITIAL_ADMIN_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.opensearch_initial_admin_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "OPENSEARCH_JAVA_OPTS"
        value = "-Xms2g -Xmx4g"
      }
      env {
        name  = "DISABLE_SECURITY_PLUGIN"
        value = "true"
      }
      env {
        name  = "DISABLE_SSL"
        value = "true"
      }
      env {
        name  = "network.host"
        value = "0.0.0.0"
      }
      env {
        name  = "discovery.type"
        value = "single-node"
      }

      volume_mounts {
        name       = "opensearch-data-volume"
        mount_path = "/usr/share/opensearch/data"
      }
    }

    volumes {
      name = "opensearch-data-volume"
      gcs {
        bucket    = google_storage_bucket.opensearch_data.name
        read_only = false
      }
    }
  }

  depends_on = [google_project_service.required_apis["run.googleapis.com"]]
}

resource "google_cloud_run_v2_service" "keycloak" {
  name     = "keycloak-${var.environment}"
  provider = google-beta
  location = var.default_region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }

  template {
    service_account                  = google_service_account.keycloak.email
    timeout                          = "300s"
    max_instance_request_concurrency = 80

    scaling {
      min_instance_count = 1
      max_instance_count = 5
    }

    vpc_access {
      egress = "ALL_TRAFFIC"
      network_interfaces {
        network    = data.google_compute_network.shared_vpc.id
        subnetwork = data.google_compute_subnetwork.shared_subnet.id
      }
    }

    containers {
      image   = var.container_images.keycloak
      command = ["/opt/keycloak/bin/kc.sh"]
      args    = ["start-dev"]

      ports {
        container_port = 8080
      }

      resources {
        startup_cpu_boost = false
        limits = {
          cpu    = "2"
          memory = "4Gi"
        }
      }

      startup_probe {
        failure_threshold = 1
        period_seconds    = 10
        timeout_seconds   = 10
        tcp_socket {
          port = 8080
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
        name  = "KC_PROXY"
        value = "edge"
      }
      env {
        name  = "PROXY_ADDRESS_FORWARDING"
        value = "true"
      }
      env {
        name  = "KC_PROXY_HEADERS"
        value = "xforwarded"
      }
      env {
        name  = "KC_HTTP_RELATIVE_PATH"
        value = "/iam"
      }
      env {
        name  = "KC_BOOTSTRAP_ADMIN_USERNAME"
        value = "admin"
      }
      env {
        name = "KC_BOOTSTRAP_ADMIN_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.kc_bootstrap_admin_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "KC_HOSTNAME"
        value = "${local.keycloak_url}/iam"
      }
      env {
        name  = "KC_HOSTNAME_ADMIN"
        value = "${local.keycloak_url}/iam"
      }
      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }

      volume_mounts {
        name       = "keycloak-themes-volume"
        mount_path = "/opt/keycloak/themes"
      }
    }

    volumes {
      name = "keycloak-themes-volume"
      gcs {
        bucket    = google_storage_bucket.keycloak_providers.name
        read_only = false
      }
    }
  }

  depends_on = [
    google_project_service.required_apis["run.googleapis.com"],
    google_artifact_registry_repository.quay_remote
  ]
}

resource "google_cloud_run_v2_service" "admin_management" {
  name     = "admin-management-${var.environment}"
  provider = google-beta
  location = var.default_region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }

  template {
    service_account                  = google_service_account.admin_management_api.email
    timeout                          = "300s"
    max_instance_request_concurrency = 80

    scaling {
      min_instance_count = 1
      max_instance_count = 5
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
      network_interfaces {
        network    = data.google_compute_network.shared_vpc.id
        subnetwork = data.google_compute_subnetwork.shared_subnet.id
      }
    }

    containers {
      image = var.container_images.admin_management

      ports {
        container_port = 8000
      }

      resources {
        startup_cpu_boost = true
        limits = {
          cpu    = "2"
          memory = "4Gi"
        }
      }

      startup_probe {
        failure_threshold = 1
        period_seconds    = 10
        timeout_seconds   = 10
        tcp_socket {
          port = 8000
        }
      }

      env {
        name  = "A_AUTH_ISSUER"
        value = "${local.keycloak_url}/iam/realms/polaris-ai"
      }
      env {
        name  = "A_AUTH_CLIENT_ID"
        value = "polaris-admin"
      }
      env {
        name  = "OTEL_SERVICE_NAME"
        value = "admin-management-dev"
      }
      env {
        name  = "A_AUTH_ISSUER_ADMIN"
        value = "${local.keycloak_url}/iam/realms/polaris-ai"
      }
      env {
        name = "A_AUTH_CLIENT_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.admin_client_secret.secret_id
            version = "latest"
          }
        }
      }
    }
  }

  depends_on = [
    google_project_service.required_apis["run.googleapis.com"],
    google_artifact_registry_repository.ghcr_remote
  ]
}

resource "google_cloud_run_v2_service" "agents" {
  name     = "agents-${var.environment}"
  provider = google-beta
  location = var.default_region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }

  template {
    service_account                  = google_service_account.agents.email
    timeout                          = "300s"
    max_instance_request_concurrency = 80

    scaling {
      min_instance_count = 1
      max_instance_count = 5
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
      network_interfaces {
        network    = data.google_compute_network.shared_vpc.id
        subnetwork = data.google_compute_subnetwork.shared_subnet.id
      }
    }

    containers {
      image = var.container_images.agents

      ports {
        container_port = 8000
      }

      resources {
        startup_cpu_boost = true
        limits = {
          cpu    = "2"
          memory = "4Gi"
        }
      }

      startup_probe {
        failure_threshold = 1
        period_seconds    = 10
        timeout_seconds   = 10
        tcp_socket {
          port = 8000
        }
      }

      env {
        name  = "A_AUTH_ISSUER"
        value = "${local.keycloak_url}/iam/realms/polaris-ai"
      }
      env {
        # TODO: migrate to Secret Manager
        name  = "A_DATABASE_URL"
        value = "postgresql://postgres:PLACEHOLDER@10.83.0.3:5432/agents"
      }
      env {
        name  = "A_APP_URL"
        value = local.agents_url
      }
      env {
        name  = "A_DEFAULT_MODEL_ID"
        value = "gpt-4.1"
      }
      env {
        name  = "A_AUTH_CLIENT_ID"
        value = "agents"
      }
      env {
        # TODO: migrate to Secret Manager
        name  = "A_AUTH_CLIENT_SECRET"
        value = "PLACEHOLDER"
      }
      env {
        name  = "OTEL_SERVICE_NAME"
        value = "agents-dev"
      }
      env {
        name  = "A_KNOWLEDGE_BASE_URL"
        value = local.knowledge_api_url
      }
      env {
        name  = "A_AUTH_ISSUER_ADMIN"
        value = "${local.keycloak_url}/iam/realms/polaris-ai"
      }
      env {
        name  = "A_PAYI_BASE_URL"
        value = local.admin_management_url
      }
      env {
        # TODO: migrate to Secret Manager
        name  = "A_PAYI_API_KEY"
        value = "PLACEHOLDER"
      }
    }
  }

  depends_on = [
    google_project_service.required_apis["run.googleapis.com"],
    google_artifact_registry_repository.ghcr_remote
  ]
}

resource "google_cloud_run_v2_service" "marketplace" {
  name     = "atos-ai-marketplace"
  provider = google-beta
  location = var.default_region
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }

  template {
    service_account                  = google_service_account.atos_ai_marketplace.email
    timeout                          = "300s"
    max_instance_request_concurrency = 80

    scaling {
      min_instance_count = 1
      max_instance_count = 5
    }

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
      network_interfaces {
        network    = data.google_compute_network.shared_vpc.id
        subnetwork = data.google_compute_subnetwork.shared_subnet.id
      }
    }

    containers {
      image = var.container_images.marketplace

      ports {
        container_port = 8000
      }

      resources {
        startup_cpu_boost = true
        limits = {
          cpu    = "2"
          memory = "4Gi"
        }
      }

      startup_probe {
        failure_threshold = 1
        period_seconds    = 10
        timeout_seconds   = 10
        tcp_socket {
          port = 8000
        }
      }

      env {
        name  = "A_AUTH_ISSUER"
        value = "${local.keycloak_url}/iam/realms/polaris-ai"
      }
      env {
        name  = "A_AUTH_CLIENT_ID"
        value = "portal"
      }
      env {
        name  = "OTEL_SERVICE_NAME"
        value = "atos-ai-marketplace"
      }
      env {
        name  = "A_APP_URL"
        value = local.marketplace_url
      }
      env {
        name  = "A_DATABASE_URL"
        value = "postgresql://marketplace@${google_sql_database_instance.postgres_instance.private_ip_address}:5432/${google_sql_database.marketplace_db.name}"
      }
      env {
        name = "A_SESSION_SECRET_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.marketplace_session_secret_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "A_AUTH_CLIENT_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.marketplace_client_secret.secret_id
            version = "latest"
          }
        }
      }

      volume_mounts {
        name       = "marketplace-www-volume"
        mount_path = "/app/www"
      }
      volume_mounts {
        name       = "marketplace-assets-volume"
        mount_path = "/app/assets"
      }
    }

    volumes {
      name = "marketplace-www-volume"
      gcs {
        bucket    = google_storage_bucket.marketplace_data.name
        read_only = false
      }
    }
    # Intentional: exported Cloud Run config mounts the same bucket twice so the app gets separate /app/www and /app/assets paths.
    volumes {
      name = "marketplace-assets-volume"
      gcs {
        bucket    = google_storage_bucket.marketplace_data.name
        read_only = false
      }
    }
  }

  depends_on = [
    google_project_service.required_apis["run.googleapis.com"],
    google_artifact_registry_repository.ghcr_remote
  ]
}
