resource "google_project_iam_member" "polaris_portal_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.polaris_portal.email}"
}

resource "google_project_iam_member" "knowledge_management_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.knowledge_management_api.email}"
}

resource "google_project_iam_member" "keycloak_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.keycloak.email}"
}

resource "google_project_iam_member" "marketplace_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.atos_ai_marketplace.email}"
}

resource "google_project_iam_member" "admin_management_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.admin_management_api.email}"
}

resource "google_project_iam_member" "agents_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.agents.email}"
}

resource "google_cloud_run_service_iam_member" "polaris_portal_access" {
  count    = length(var.iap_users)
  location = google_cloud_run_v2_service.polaris_portal.location
  project  = google_cloud_run_v2_service.polaris_portal.project
  service  = google_cloud_run_v2_service.polaris_portal.name
  role     = "roles/run.invoker"
  member   = var.iap_users[count.index]
}

resource "google_cloud_run_service_iam_member" "polaris_to_knowledge_mgmt" {
  location = google_cloud_run_v2_service.knowledge_management_api.location
  project  = google_cloud_run_v2_service.knowledge_management_api.project
  service  = google_cloud_run_v2_service.knowledge_management_api.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.polaris_portal.email}"
}

resource "google_cloud_run_service_iam_member" "polaris_to_opensearch" {
  location = google_cloud_run_v2_service.opensearch_vector_db.location
  project  = google_cloud_run_v2_service.opensearch_vector_db.project
  service  = google_cloud_run_v2_service.opensearch_vector_db.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.polaris_portal.email}"
}

resource "google_cloud_run_service_iam_member" "polaris_to_keycloak" {
  location = google_cloud_run_v2_service.keycloak.location
  project  = google_cloud_run_v2_service.keycloak.project
  service  = google_cloud_run_v2_service.keycloak.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.polaris_portal.email}"
}

resource "google_secret_manager_secret_iam_member" "marketplace_db_secret_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.marketplace_db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.polaris_portal.email}"
}

resource "google_secret_manager_secret_iam_member" "knowledge_db_secret_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.knowledge_db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.knowledge_management_api.email}"
}

resource "google_secret_manager_secret_iam_member" "keycloak_db_secret_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.keycloak_db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.keycloak.email}"
}

resource "google_secret_manager_secret_iam_member" "portal_auth_secret_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.portal_auth_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.polaris_portal.email}"
}

resource "google_secret_manager_secret_iam_member" "portal_client_secret_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.portal_client_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.polaris_portal.email}"
}

resource "google_secret_manager_secret_iam_member" "opensearch_initial_admin_password_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.opensearch_initial_admin_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.opensearch_vector_db.email}"
}

resource "google_secret_manager_secret_iam_member" "knowledge_appinsights_conn_str_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.appinsights_conn_str.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.knowledge_management_api.email}"
}

resource "google_secret_manager_secret_iam_member" "knowledge_opensearch_password_access" {
  project   = var.project_id
  secret_id = "opensearch_password"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.knowledge_management_api.email}"
}

resource "google_secret_manager_secret_iam_member" "knowledge_snowflake_password_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.snowflake_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.knowledge_management_api.email}"
}

resource "google_secret_manager_secret_iam_member" "knowledge_bing_search_agent_id_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.bing_search_agent_id.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.knowledge_management_api.email}"
}

resource "google_secret_manager_secret_iam_member" "knowledge_openweather_api_key_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.openweather_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.knowledge_management_api.email}"
}

resource "google_secret_manager_secret_iam_member" "knowledge_snow_pass_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.snow_pass.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.knowledge_management_api.email}"
}

resource "google_secret_manager_secret_iam_member" "knowledge_snowflake_cortex_secret_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.snowflake_cortex_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.knowledge_management_api.email}"
}

resource "google_secret_manager_secret_iam_member" "admin_client_secret_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.admin_client_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.admin_management_api.email}"
}

resource "google_secret_manager_secret_iam_member" "marketplace_session_secret_key_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.marketplace_session_secret_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.atos_ai_marketplace.email}"
}

resource "google_secret_manager_secret_iam_member" "marketplace_client_secret_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.marketplace_client_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.atos_ai_marketplace.email}"
}

resource "google_secret_manager_secret_iam_member" "keycloak_bootstrap_admin_password_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.kc_bootstrap_admin_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.keycloak.email}"
}

resource "google_cloud_run_service_iam_member" "connectivity_test_to_knowledge_mgmt" {
  location = google_cloud_run_v2_service.knowledge_management_api.location
  project  = google_cloud_run_v2_service.knowledge_management_api.project
  service  = google_cloud_run_v2_service.knowledge_management_api.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.connectivity_test.email}"
}

resource "google_cloud_run_service_iam_member" "connectivity_test_to_opensearch" {
  location = google_cloud_run_v2_service.opensearch_vector_db.location
  project  = google_cloud_run_v2_service.opensearch_vector_db.project
  service  = google_cloud_run_v2_service.opensearch_vector_db.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.connectivity_test.email}"
}

resource "google_cloud_run_service_iam_member" "connectivity_test_to_keycloak" {
  location = google_cloud_run_v2_service.keycloak.location
  project  = google_cloud_run_v2_service.keycloak.project
  service  = google_cloud_run_v2_service.keycloak.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.connectivity_test.email}"
}

resource "google_cloud_run_service_iam_member" "bastion_to_knowledge_mgmt" {
  count    = var.bastion_enabled ? 1 : 0
  location = google_cloud_run_v2_service.knowledge_management_api.location
  project  = google_cloud_run_v2_service.knowledge_management_api.project
  service  = google_cloud_run_v2_service.knowledge_management_api.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.bastion[0].email}"
}

resource "google_cloud_run_service_iam_member" "bastion_to_opensearch" {
  count    = var.bastion_enabled ? 1 : 0
  location = google_cloud_run_v2_service.opensearch_vector_db.location
  project  = google_cloud_run_v2_service.opensearch_vector_db.project
  service  = google_cloud_run_v2_service.opensearch_vector_db.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.bastion[0].email}"
}

resource "google_cloud_run_service_iam_member" "bastion_to_keycloak" {
  count    = var.bastion_enabled ? 1 : 0
  location = google_cloud_run_v2_service.keycloak.location
  project  = google_cloud_run_v2_service.keycloak.project
  service  = google_cloud_run_v2_service.keycloak.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.bastion[0].email}"
}

resource "google_secret_manager_secret_iam_member" "connectivity_test_knowledge_secret_access" {
  secret_id = google_secret_manager_secret.knowledge_db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.connectivity_test.email}"
}

resource "google_secret_manager_secret_iam_member" "connectivity_test_marketplace_secret_access" {
  secret_id = google_secret_manager_secret.marketplace_db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.connectivity_test.email}"
}

resource "google_secret_manager_secret_iam_member" "connectivity_test_keycloak_secret_access" {
  secret_id = google_secret_manager_secret.keycloak_db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.connectivity_test.email}"
}

resource "google_storage_bucket_iam_member" "knowledge_data_storage_admin" {
  bucket = google_storage_bucket.knowledge_data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.knowledge_management_api.email}"
}

resource "google_storage_bucket_iam_member" "keycloak_providers_storage_admin" {
  bucket = google_storage_bucket.keycloak_providers.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.keycloak.email}"
}

resource "google_storage_bucket_iam_member" "opensearch_data_storage_admin" {
  bucket = google_storage_bucket.opensearch_data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.opensearch_vector_db.email}"
}

resource "google_storage_bucket_iam_member" "marketplace_data_storage_admin" {
  bucket = google_storage_bucket.marketplace_data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.atos_ai_marketplace.email}"
}

resource "google_secret_manager_secret_iam_member" "keycloak_db_password_accessor" {
  secret_id = google_secret_manager_secret.keycloak_db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.keycloak.email}"
  project   = var.project_id
}

# Allow unauthenticated (public) access to all Cloud Run services
resource "google_cloud_run_service_iam_member" "polaris_portal_public" {
  location = google_cloud_run_v2_service.polaris_portal.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.polaris_portal.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "knowledge_mgmt_public" {
  location = google_cloud_run_v2_service.knowledge_management_api.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.knowledge_management_api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "opensearch_public" {
  location = google_cloud_run_v2_service.opensearch_vector_db.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.opensearch_vector_db.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "keycloak_public" {
  location = google_cloud_run_v2_service.keycloak.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.keycloak.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "admin_management_public" {
  location = google_cloud_run_v2_service.admin_management.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.admin_management.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "agents_public" {
  location = google_cloud_run_v2_service.agents.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.agents.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "marketplace_public" {
  location = google_cloud_run_v2_service.marketplace.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.marketplace.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
