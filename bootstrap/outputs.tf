# Bootstrap Outputs

output "state_bucket_name" {
  description = "Name of the created state bucket"
  value       = module.state_bucket.bucket_name
}

output "state_bucket_url" {
  description = "URL of the created state bucket"
  value       = module.state_bucket.bucket_url
}
