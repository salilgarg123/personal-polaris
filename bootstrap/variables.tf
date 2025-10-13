# Bootstrap Variables

variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "default_region" {
  description = "Default Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "state_bucket_location" {
  description = "Location for the Terraform state bucket"
  type        = string
  default     = "US"
}