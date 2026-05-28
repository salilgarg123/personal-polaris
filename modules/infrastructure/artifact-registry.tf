resource "google_artifact_registry_repository" "quay_remote" {
  location      = var.default_region
  repository_id = "quay-remote"
  description   = "Remote repository proxying quay.io for Keycloak"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  project       = var.project_id

  remote_repository_config {
    description = "Quay.io"
    docker_repository {
      custom_repository {
        uri = "https://quay.io"
      }
    }
  }

  depends_on = [google_project_service.required_apis["artifactregistry.googleapis.com"]]
}

resource "google_artifact_registry_repository_iam_member" "cloudrun_quay_reader" {
  location   = google_artifact_registry_repository.quay_remote.location
  repository = google_artifact_registry_repository.quay_remote.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${data.google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  project    = var.project_id
}
