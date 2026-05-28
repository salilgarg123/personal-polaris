# Backend configuration for dev environment
terraform {
  backend "gcs" {
    bucket = "polaris-terraform-state-744386be"
    prefix = "environments/dev"
  }
}
