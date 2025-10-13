# State Bucket Module Outputs

output "bucket_name" {
  description = "Name of the GCS bucket for Terraform state storage"
  value       = google_storage_bucket.terraform_state.name
}

output "bucket_url" {
  description = "URL of the GCS bucket"
  value       = google_storage_bucket.terraform_state.url
}
