# State Bucket Module Variables

variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "bucket_location" {
  description = "Location for the Terraform state bucket"
  type        = string
  default     = "US"
}