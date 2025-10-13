# Backend configuration for dev environment
terraform {
  backend "gcs" {
    bucket = "polaris-terraform-state-c6ac9795"  # Will be replaced by setup.sh
    prefix = "environments/dev"
  }
}