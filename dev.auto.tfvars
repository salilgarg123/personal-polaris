project_id = "prj-d-bu1-sample-base-qopg"

# Shared VPC (landing zone network)
shared_vpc_host_project = "prj-d-shared-base-0bs7"
shared_vpc_network_name = "vpc-d-shared-base"
shared_vpc_subnet_name  = "sb-d-shared-base-us-central1"

# Cloud SQL
cloudsql_tier                = "db-f1-micro"
cloudsql_disk_size           = 20
cloudsql_deletion_protection = false

# Cloud Run
cloudrun_cpu           = "1"
cloudrun_memory        = "512Mi"
cloudrun_min_instances = 0
cloudrun_max_instances = 3

# Container Images
container_images = {
  polaris_portal = "us-central1-docker.pkg.dev/prj-d-bu1-sample-base-qopg/ghcr-remote/in-atos-aara/atos-polaris-ai-portal:1.0.65"
  knowledge_api  = "us-central1-docker.pkg.dev/prj-d-bu1-sample-base-qopg/ghcr-remote/in-atos-aara/atos-ai-knowledge:1.0.48"
  opensearch     = "gcr.io/cloudrun/hello"
  keycloak       = "us-central1-docker.pkg.dev/prj-d-bu1-sample-base-qopg/quay-remote/keycloak/keycloak:26.4.0"
}

# IAP access
iap_users = []

# Bastion
bastion_enabled      = true
bastion_machine_type = "e2-standard-2"
bastion_disk_size    = 10
