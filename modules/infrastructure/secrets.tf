resource "google_secret_manager_secret" "opensearch_initial_admin_password" {
  secret_id = "OPENSEARCH_INITIAL_ADMIN_PASSWORD"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "opensearch_password" {
  secret_id = "opensearch_password"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "admin_client_secret" {
  secret_id = "admin-client-secret"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "agent_db_url" {
  secret_id = "agent_db_url"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "app_insights_con_str" {
  secret_id = "app_insights_con_str"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "appinsights_conn_str" {
  secret_id = "appinsights_conn_str"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "bing_search_agent_id" {
  secret_id = "bing-search-agent-id"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "client_secret" {
  secret_id = "client_secret"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "google_api_key" {
  secret_id = "google-api-key"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "knowledge_db_url" {
  secret_id = "knowledge_db_url"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "marketp_url" {
  secret_id = "marketp_url"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "marketplace_session_secret_key" {
  secret_id = "marketplace_SESSION_SECRET_KEY"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "marketplace_client_secret" {
  secret_id = "marketplace_client_secret"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "openweather_api_key" {
  secret_id = "openweather-api-key"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "portal_auth_secret" {
  secret_id = "portal-auth-secret"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "portal_client_secret" {
  secret_id = "portal-client-secret"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "postgres_admin_password_dev" {
  secret_id = "postgres-admin-password-dev"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "snow_pass" {
  secret_id = "snow-pass"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "snowflake_cortex_secret" {
  secret_id = "snowflake-cortex-secret"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "snowflake_password" {
  secret_id = "snowflake-password"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "kc_bootstrap_admin_password" {
  secret_id = "KC_BOOTSTRAP_ADMIN_PASSWORD"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "agents_client_secret" {
  secret_id = "agents-client-secret"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret" "agents_payi_api_key" {
  secret_id = "agents-payi-api-key"
  project   = var.project_id
  replication {
    auto {}
  }
  depends_on = [google_project_service.required_apis["secretmanager.googleapis.com"]]
}
