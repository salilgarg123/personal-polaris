# Infrastructure Module

This module provides the core infrastructure components for the Polaris application.

## Components

### Cloud Run Services

- **Polaris Portal** - Main web application with IAP authentication
- **Knowledge Management API** - Internal API for document processing  
- **OpenSearch Vector DB** - Vector database for semantic search
- **Keycloak** - Authentication and identity management service
- **Connectivity Test** - Service for testing inter-service communication

### Cloud SQL Database

- **PostgreSQL 15** instance with three databases:
  - `marketplace` - Main application database
  - `knowledge` - Knowledge management data
  - `keycloak` - Authentication service data
- **Secret Manager** to keep passwords for database users

### Cloud Storage

- **Knowledge Data Bucket** - Document storage with FUSE mount
- **Keycloak Providers Bucket** - Custom themes and providers
- **OpenSearch Data Bucket** - Vector indices and search data

### Networking

- **VPC Network** - Private network for all services
- **Private IP Allocation** - For Cloud SQL and managed services
- **Cloud NAT** - Outbound internet access for private resources

### Security

- **Service Accounts** - Dedicated accounts per service with minimal permissions
- **IAP Protection** - Identity-Aware Proxy for public services
- **Private Services** - Internal services accessible only within VPC

### Optional Components

- **Bastion Host** - Secure access to private resources via IAP tunnel
- **Resource Scheduling** - Automatic stop/start scheduling for cost optimization

## Usage

```hcl
module "polaris_infrastructure" {
  source = "./modules/infrastructure"
  
  # Required variables
  project_id     = "your-project-id"
  environment    = "dev"
  default_region = "us-central1"
  
  # Cloud SQL configuration
  cloudsql_tier               = "db-f1-micro"
  cloudsql_deletion_protection = false
  
  # Cloud Run configuration  
  cloudrun_cpu    = "1"
  cloudrun_memory = "512Mi"
  
  # IAP users
  iap_users = ["user:admin@example.com"]
  
  # Optional bastion host
  bastion_enabled = true
}
```

## Outputs

The module outputs connection strings, service URLs, and resource identifiers needed by applications and other infrastructure components.
