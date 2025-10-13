# Polaris Terraform Infrastructure

This directory contains Terraform configurations for the Polaris project infrastructure with multi-environment support.

## 🏗️ Multi-Project Deployment Strategy

The infrastructure supports deploying different environments (dev/staging/prod) to separate GCP projects for maximum isolation and security:

### Project Structure

- **Development**: `{project-prefix}-dev` (e.g., `prj-sbx-polarisai-160925-dev`)
- **Staging**: `{project-prefix}-staging` (e.g., `prj-sbx-polarisai-160925-staging`)  
- **Production**: `{project-prefix}-prod` (e.g., `prj-sbx-polarisai-160925-prod`)

### Configuration Files

Each environment has its own configuration with project-specific settings:
    - `dev.auto.tfvars` - Development project ID and settings
    - `staging.auto.tfvars` - Staging project ID and settings
    - `prod.auto.tfvars` - Production project ID and settings

### State Management

Terraform state is stored in a single shared GCS bucket, with each environment's state file located at an environment-specific path:
    - Dev state file: `environments/dev/terraform.tfstate`
    - Staging state file: `environments/staging/terraform.tfstate`
    - Prod state file: `environments/prod/terraform.tfstate`

## 📁 Structure

```tree
terraform/
├── README.md                      # This file
├── Team-workflow.md               # Team collaboration workflow
├── .gitignore                     # Git ignore patterns
├── setup.sh                       # Bootstrap script for state bucket
├── setup-symlinks.sh              # Script to create auto.tfvars symlinks
├── setup-team.sh                  # Team member setup script
├── deploy.sh                      # Environment deployment script
├── manage.sh                      # Environment management shortcuts
├── verify-setup.sh                # Setup verification script
├── common.auto.tfvars             # Shared configuration across environments
├── common.auto.tfvars.example     # Example shared configuration
├── dev.auto.tfvars                # Development environment config
├── dev.auto.tfvars.example        # Example dev configuration
├── staging.auto.tfvars.example    # Example staging configuration
├── prod.auto.tfvars.example       # Example production configuration
├── bootstrap/                     # Bootstrap configuration (run once)
│   ├── main.tf                    # Bootstrap Terraform configuration
│   ├── variables.tf               # Bootstrap variables
│   ├── outputs.tf                 # Bootstrap outputs
│   └── terraform.tfvars.example   # Bootstrap configuration example
├── environments/
│   └── dev/                       # Development environment
│       ├── main.tf                # Environment-specific infrastructure calls
│       ├── variables.tf           # Environment variables
│       ├── versions.tf            # Terraform and provider versions
│       ├── backend.tf             # Remote state configuration
│       ├── outputs.tf             # Environment outputs
│       ├── common.auto.tfvars → ../../common.auto.tfvars (symlink)
│       └── dev.auto.tfvars → ../../dev.auto.tfvars (symlink)
└── modules/
    ├── infrastructure/            # Main infrastructure module
    │   ├── README.md              # Infrastructure module documentation
    │   ├── main.tf                # Main infrastructure configuration
    │   ├── variables.tf           # Module input variables
    │   ├── outputs.tf             # Module outputs
    │   ├── bastion.tf             # Bastion host configuration
    │   ├── cloud-run.tf           # Cloud Run services
    │   ├── cloud-sql.tf           # Cloud SQL database
    │   ├── iam.tf                 # IAM policies and bindings
    │   ├── networking.tf          # VPC and networking
    │   ├── service-accounts.tf    # Service account definitions
    │   └── storage.tf             # Cloud Storage buckets
    └── state-bucket/              # State bucket creation module
        ├── main.tf                # GCS bucket and KMS resources
        ├── variables.tf           # State bucket variables
        └── outputs.tf             # State bucket outputs
```

**Note**: Currently only the `dev` environment is configured. Staging and production environments can be added by creating corresponding directories under `environments/` with similar structure.

## 🚀 Quick Start

### 1. Bootstrap State Bucket

```bash
# First, create the GCS bucket for storing Terraform state
./setup.sh
```

### 2. Configure Your Project

```bash
# Edit the common configuration file
vi common.auto.tfvars

# Update your GCP project ID and shared settings
# project_id = "your-actual-gcp-project-id"
```

### 3. Setup Environment Configuration

```bash
# Create symlinks for auto.tfvars files
./setup-symlinks.sh

# Optionally customize environment-specific settings
vi dev.auto.tfvars      # Dev-specific settings
vi staging.auto.tfvars  # Staging-specific settings
vi prod.auto.tfvars     # Production-specific settings
```

### 4. Deploy to Environments

**Important**: Each environment deploys to its own GCP project as specified in the respective `.auto.tfvars` files.

```bash
# Deploy to development project
export GOOGLE_PROJECT=$(grep 'project_id' dev.auto.tfvars | cut -d'"' -f2)
./manage.sh setup dev      # Initialize and plan dev
./manage.sh deploy dev     # Deploy to dev project

# Deploy to staging project  
export GOOGLE_PROJECT=$(grep 'project_id' staging.auto.tfvars | cut -d'"' -f2)
./manage.sh setup staging  # Initialize and plan staging
./manage.sh deploy staging # Deploy to staging project

# Deploy to production project
export GOOGLE_PROJECT=$(grep 'project_id' prod.auto.tfvars | cut -d'"' -f2) 
./manage.sh setup prod     # Initialize and plan prod
./manage.sh deploy prod    # Deploy to production project
```

**NOTE:** Production and staging environments not prepared yet.

## 🔧 Configuration Management

### Centralized Configuration

All environment configuration is managed from the root directory:

- **`common.auto.tfvars`** - Shared settings (project ID, default regions, etc.)
- **`<env>.auto.tfvars`** - Environment-specific overrides (Cloud SQL, Cloud Run resources, networking, etc.)

### Environment Scaling Examples

**Development** (minimal resources):

```hcl
# dev.auto.tfvars
cloudsql_tier = "db-f1-micro"
cloudrun_cpu = "1"
cloudrun_memory = "512Mi"
```

**Staging** (moderate resources):

```hcl  
# staging.auto.tfvars
cloudsql_tier = "db-g1-small"
cloudrun_cpu = "2"
cloudrun_memory = "1Gi"
```

**Production** (production resources):

```hcl
# prod.auto.tfvars  
cloudsql_tier = "db-custom-2-4096"
cloudrun_cpu = "4"
cloudrun_memory = "2Gi"
```

## 🏗️ Architecture

### State Management

- **Bootstrap**: Local state in `bootstrap/` directory for creating the initial GCS bucket and KMS key
- **Environments**: Remote state in shared GCS bucket with environment-specific prefixes:
  - `environments/dev/` - Development environment state
  - `environments/staging/` - Staging environment state (not yet created)
  - `environments/prod/` - Production environment state (not yet created)

The bootstrap process creates a single state bucket that all environments share, with each environment storing its state under a unique prefix path.

### Module Structure

- **Infrastructure Module**: Main module containing all infrastructure components
- **Environment Configs**: Call the infrastructure module with environment-specific parameters

### Database Schema

The infrastructure provisions a Cloud SQL PostgreSQL instance with three databases:

- **marketplace**: Main application database for the Polaris Portal service
- **knowledge**: Database for the Knowledge Management API service
- **keycloak**: Database for the Keycloak authentication service

Each database has:

- Dedicated user account with same name as database
- Secure randomly generated password stored in Secret Manager
- Proer IAM permissions for service account access
- VPC-private networking (no public IP access)

### Cloud Storage Volume Mounts

The infrastructure provisions Cloud Storage buckets mounted as volumes for persistent data:

- **Knowledge Management API**: 
  - Bucket: `bkt-{project_id}-knowledge-data-{env}`
  - Mount path: `/app/data`
  - Purpose: Stores uploaded files and documents
  - Lifecycle: 90-day retention, 30-day archive

- **Keycloak**:
  - Bucket: `bkt-{project_id}-keycloak-providers-{env}`
  - Mount path: `/opt/keycloak/providers`
  - Purpose: Stores keycloak-theme.jar and provider customizations
  - Lifecycle: No automatic deletion (persistent themes)

- **OpenSearch Vector DB**:
  - Bucket: `bkt-{project_id}-opensearch-data-{env}`
  - Mount path: `/usr/share/opensearch/data`
  - Purpose: Stores vector embeddings and search indices
  - Lifecycle: 365-day retention for long-term data

Each storage bucket has:

- Service-specific IAM permissions (principle of least privilege)
- Environment-specific naming and isolation
- Cloud Storage FUSE integration for seamless file access

## 📋 Available Commands

### Environment Management

```bash
./manage.sh setup <env>     # Setup environment (init + plan)
./manage.sh deploy <env>    # Deploy environment  
./manage.sh status <env>    # Show environment status
./manage.sh destroy <env>   # Destroy environment
./manage.sh list            # List all environments
```

### Deployment Script

```bash  
./deploy.sh <env> init      # Initialize Terraform
./deploy.sh <env> plan      # Plan changes  
./deploy.sh <env> apply     # Apply changes
./deploy.sh <env> destroy   # Destroy resources
./deploy.sh <env> output    # Show outputs
```

## 🔐 Prerequisites

1. **Terraform** (>= 1.9)
2. **Google Cloud SDK** with authentication configured
3. **GCP Project** with appropriate permissions:
   - Compute Engine API
   - Cloud Storage API  
   - Cloud KMS API (for state encryption)
4. **IAM Permissions**: 
   - Storage Admin (for state bucket)
   - Compute Admin (for compute resources)
   - Service Account Admin (for service accounts)

## 🛡️ Security Features

- **Separated Environments**: Each environment has isolated state  
- **Service Accounts**: Dedicated service accounts per environment
- **Firewall Rules**: Environment-specific security rules
- **Private Resources**: No public access to sensitive resources

## �️ Bastion Host & Database Access

### Overview

The infrastructure includes a secure bastion host for accessing private resources like Cloud SQL. The bastion host:
    - Has **no external IP** (private only)
    - Accessible only via **Google IAP tunnel**
    - Pre-configured with database tools
    - Follows security best practices
    - Internet access via Cloud NAT

### Connecting to Bastion Host

#### Prerequisites

```bash
# Ensure you have appropriate IAM permissions
# - roles/iap.tunnelResourceAccessor
# - roles/compute.osLogin
# These are configured via the iap_users variable
```

#### Method 1: Direct SSH (Recommended)

```bash
# Set environment variables
export PROJECT_ID="your-project-id"
export ENVIRONMENT="dev"  # or staging/prod
export ZONE="us-central1-a"

# Connect directly (gcloud handles IAP automatically)
gcloud compute ssh gce-bastion-${ENVIRONMENT} \
  --zone=${ZONE} \
  --project=${PROJECT_ID}
```

#### Method 2: Manual IAP Tunnel

```bash
# Terminal 1: Start IAP tunnel
gcloud compute start-iap-tunnel gce-bastion-${ENVIRONMENT} 22 \
  --local-host-port=localhost:2222 \
  --zone=${ZONE} \
  --project=${PROJECT_ID}

# Terminal 2: Connect via SSH
ssh -p 2222 ubuntu@localhost
```

### Accessing Cloud SQL from Bastion

Once connected to the bastion host, you can access Cloud SQL databases:

#### Option A: Using Pre-configured Cloud SQL Proxy

```bash
# Start the systemd service (pre-configured)
sudo systemctl start cloud-sql-proxy
sudo systemctl status cloud-sql-proxy

# Connect to databases
psql -h localhost -p 5432 -U marketplace -d marketplace
psql -h localhost -p 5432 -U knowledge -d knowledge
psql -h localhost -p 5432 -U keycloak -d keycloak
```

#### Option B: Manual Cloud SQL Proxy

```bash
# Get connection name from terraform outputs
terraform output cloudsql_instance

# Start proxy manually
cloud-sql-proxy --port=5432 PROJECT:REGION:INSTANCE_NAME &

# Connect to database
psql -h localhost -p 5432 -U USERNAME -d DATABASE_NAME
```

#### Option C: Direct Private IP Connection

```bash
# Get private IP from terraform outputs
terraform output cloudsql_instance

# Connect directly via private IP
psql -h 10.x.x.x -p 5432 -U USERNAME -d DATABASE_NAME
```

### Getting Connection Details

Use terraform outputs to get exact connection information:

```bash
# Bastion connection info
terraform output bastion_host
terraform output bastion_iap_access_commands

# Database connection details (contains passwords - sensitive)
terraform output -json cloudsql_connection_strings

# Cloud SQL instance information
terraform output cloudsql_instance

# Available databases
terraform output cloudsql_databases
```

### Complete Connection Example

```bash
# 1. Navigate to environment directory
cd environments/dev

# 2. Get connection details
export PROJECT_ID=$(terraform output -raw project_id)
export BASTION_NAME=$(terraform output -json bastion_host | jq -r '.name')
export ZONE=$(terraform output -json bastion_host | jq -r '.zone')

# 3. Connect to bastion
gcloud compute ssh ${BASTION_NAME} --zone=${ZONE} --project=${PROJECT_ID}

# 4. On bastion: Start Cloud SQL Proxy
sudo systemctl start cloud-sql-proxy

# 5. Connect to your database
psql -h localhost -p 5432 -U marketplace -d marketplace
# Password will be prompted (get from: terraform output -json cloudsql_connection_strings)
```

### Testing Internal Service Connectivity

The bastion host can also be used to test connectivity to internal Cloud Run services using service-to-service authentication:

#### Quick Connectivity Test

```bash
# Test all internal services from bastion host
gcloud compute ssh gce-bastion-dev --zone=us-central1-a --project=prj-sbx-polarisai-160925 --tunnel-through-iap --command="
echo '=== Testing Internal Service Access ==='
echo

echo '1. OpenSearch Vector DB:'
TOKEN=\$(curl -s -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience=https://opensearch-vector-dev-4febp3r6qq-uc.a.run.app&format=full')
HTTP_CODE=\$(curl -s -o /dev/null -w '%{http_code}' -H \"Authorization: Bearer \$TOKEN\" 'https://opensearch-vector-dev-4febp3r6qq-uc.a.run.app/')
echo \"   Status: \$HTTP_CODE (200=Success)\"

echo
echo '2. Knowledge Management API:'
TOKEN=\$(curl -s -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience=https://knowledge-mgmt-api-dev-4febp3r6qq-uc.a.run.app&format=full')
HTTP_CODE=\$(curl -s -o /dev/null -w '%{http_code}' -H \"Authorization: Bearer \$TOKEN\" 'https://knowledge-mgmt-api-dev-4febp3r6qq-uc.a.run.app/')
echo \"   Status: \$HTTP_CODE (200=Success)\"

echo
echo '3. Keycloak:'
TOKEN=\$(curl -s -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience=https://keycloak-dev-4febp3r6qq-uc.a.run.app&format=full')
HTTP_CODE=\$(curl -s -o /dev/null -w '%{http_code}' -H \"Authorization: Bearer \$TOKEN\" 'https://keycloak-dev-4febp3r6qq-uc.a.run.app/')
echo \"   Status: \$HTTP_CODE (200=Success)\"

echo
echo '=== All Internal Services Accessible! ==='
"
```

#### Individual Service Testing

```bash
# Test OpenSearch Vector DB
gcloud compute ssh gce-bastion-dev --zone=us-central1-a --project=prj-sbx-polarisai-160925 --tunnel-through-iap --command="
TOKEN=\$(curl -s -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience=https://opensearch-vector-dev-4febp3r6qq-uc.a.run.app&format=full')
curl -H \"Authorization: Bearer \$TOKEN\" 'https://opensearch-vector-dev-4febp3r6qq-uc.a.run.app/'
"

# Test Knowledge Management API  
gcloud compute ssh gce-bastion-dev --zone=us-central1-a --project=prj-sbx-polarisai-160925 --tunnel-through-iap --command="
TOKEN=\$(curl -s -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience=https://knowledge-mgmt-api-dev-4febp3r6qq-uc.a.run.app&format=full')
curl -H \"Authorization: Bearer \$TOKEN\" 'https://knowledge-mgmt-api-dev-4febp3r6qq-uc.a.run.app/'
"

# Test Keycloak
gcloud compute ssh gce-bastion-dev --zone=us-central1-a --project=prj-sbx-polarisai-160925 --tunnel-through-iap --command="
TOKEN=\$(curl -s -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience=https://keycloak-dev-4febp3r6qq-uc.a.run.app&format=full')
curl -H \"Authorization: Bearer \$TOKEN\" 'https://keycloak-dev-4febp3r6qq-uc.a.run.app/'
"
```

#### Environment Variables for Other Environments

```bash
# For staging environment
export ENVIRONMENT="staging"  
export PROJECT_ID="prj-sbx-polarisai-160925-staging"

# For production environment  
export ENVIRONMENT="prod"
export PROJECT_ID="prj-sbx-polarisai-160925-prod"

# Then replace 'dev' with ${ENVIRONMENT} in the commands above
```

### Browser Testing via Authenticated Proxy

To test internal services with a browser, you need an authenticated proxy that handles Google Cloud identity tokens automatically.

#### Step 1: Create the Proxy Script

```bash
# Create auth-proxy.py in your project directory
cat > auth-proxy.py << 'EOF'
#!/usr/bin/env python3
"""
Authenticated proxy for accessing Cloud Run services through bastion host.
This proxy runs on the bastion host and handles authentication automatically.
"""
import http.server
import socketserver
import urllib.request
import subprocess
import sys

PORT = 8000
SERVICE_URL = sys.argv[1] if len(sys.argv) > 1 else 'https://knowledge-mgmt-api-dev-4febp3r6qq-uc.a.run.app'

class AuthProxy(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            # Get identity token from metadata service
            cmd = [
                'curl', '-s', '-H', 'Metadata-Flavor: Google',
                f'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience={SERVICE_URL}&format=full'
            ]
            token = subprocess.check_output(cmd).decode().strip()
            
            # Make authenticated request to the service
            url = SERVICE_URL + self.path
            req = urllib.request.Request(url)
            req.add_header('Authorization', f'Bearer {token}')
            
            with urllib.request.urlopen(req) as response:
                self.send_response(response.status)
                # Copy headers (except problematic ones)
                skip_headers = ['transfer-encoding', 'connection', 'content-encoding']
                for header, value in response.headers.items():
                    if header.lower() not in skip_headers:
                        self.send_header(header, value)
                self.end_headers()
                self.wfile.write(response.read())
                
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(f'Proxy Error: {e}'.encode())

if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), AuthProxy) as httpd:
        print(f"Serving authenticated proxy on port {PORT} for {SERVICE_URL}")
        httpd.serve_forever()
EOF
```

#### Step 2: Copy Script to Bastion Host

```bash
# Copy the proxy script to bastion host
gcloud compute scp auth-proxy.py gce-bastion-dev:/tmp/auth-proxy.py \
  --zone=us-central1-a \
  --project=prj-sbx-polarisai-160925 \
  --tunnel-through-iap
```

#### Step 3: Start the Proxy on Bastion Host

```bash
# Start the authenticated proxy (runs in background)
gcloud compute ssh gce-bastion-dev \
  --zone=us-central1-a \
  --project=prj-sbx-polarisai-160925 \
  --tunnel-through-iap \
  --command="python3 /tmp/auth-proxy.py https://knowledge-mgmt-api-dev-4febp3r6qq-uc.a.run.app" &

# For other services, replace the URL:
# OpenSearch: https://opensearch-vector-dev-4febp3r6qq-uc.a.run.app  
# Keycloak: https://keycloak-dev-4febp3r6qq-uc.a.run.app
```

#### Step 4: Create Port Forwarding to Proxy

```bash
# Forward local port 8080 to the proxy running on bastion host
gcloud compute ssh gce-bastion-dev \
  --zone=us-central1-a \
  --project=prj-sbx-polarisai-160925 \
  --tunnel-through-iap \
  -- -L 8080:localhost:8000 -N &
```

#### Step 5: Access in Browser

```bash
# Now you can access the service in your browser at:
# http://localhost:8080

# Test with curl first:
curl http://localhost:8080/
```

#### Multiple Services Setup

```bash
# Terminal 1: Knowledge Management API proxy
gcloud compute ssh gce-bastion-dev \
  --zone=us-central1-a \
  --project=prj-sbx-polarisai-160925 \
  --tunnel-through-iap \
  --command="python3 /tmp/auth-proxy.py https://knowledge-mgmt-api-dev-4febp3r6qq-uc.a.run.app" &

# Terminal 2: Port forwarding for Knowledge API
gcloud compute ssh gce-bastion-dev \
  --zone=us-central1-a \
  --project=prj-sbx-polarisai-160925 \
  --tunnel-through-iap \
  -- -L 8080:localhost:8000 -N &

# For additional services, use different ports:
# - Knowledge API: http://localhost:8080
# - OpenSearch: http://localhost:8081 (proxy on port 8001)
# - Keycloak: http://localhost:8082 (proxy on port 8002)
```

#### Proxy Benefits

- ✅ **Automatic Authentication**: Handles Google Cloud identity tokens
- ✅ **Browser Compatible**: Works with any browser and web tools
- ✅ **Transparent**: Feels like direct access to the service
- ✅ **Secure**: All authentication handled via bastion host service account
- ✅ **Multiple Services**: Can run multiple proxies for different services

#### Troubleshooting Proxy

```bash
# Check if proxy is running on bastion host
gcloud compute ssh gce-bastion-dev \
  --zone=us-central1-a \
  --project=prj-sbx-polarisai-160925 \
  --tunnel-through-iap \
  --command="ps aux | grep auth-proxy"

# Check port forwarding
netstat -ln | grep :8080

# Test proxy directly
curl -v http://localhost:8080/
```

### Security Features

- **IAP Authentication**: Only authorized users can access bastion
- **No External IP**: Bastion not exposed to internet
- **Encrypted Tunnels**: All connections encrypted via IAP
- **Private Database**: Cloud SQL accessible only within VPC
- **Audit Logging**: All access logged in Google Cloud audit logs
- **OS Login**: Centralized SSH key management
- **Shielded VM**: Hardware-level security features enabled

### Troubleshooting

#### Can't connect to bastion

```bash
# Check IAM permissions
gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:$(gcloud config get-value account)"

# Verify bastion is running
gcloud compute instances list --filter="name:bastion-*"
```

#### Can't connect to database

```bash
# Check Cloud SQL Proxy status
sudo systemctl status cloud-sql-proxy
sudo journalctl -u cloud-sql-proxy -f

# Check database connectivity
cloud-sql-proxy --version
gcloud sql instances list
```

#### IAP tunnel issues

```bash
# Enable IAP API if not already enabled
gcloud services enable iap.googleapis.com

# Check IAP permissions
gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --filter="bindings.role:roles/iap.tunnelResourceAccessor"
```

## �🚨 Best Practices

1. **Always plan before apply**: Use `plan` to review changes
2. **Environment isolation**: Never share resources between environments  
3. **State backup**: State is versioned and encrypted in GCS
4. **Configuration review**: Review auto.tfvars changes before deployment
5. **Gradual rollout**: Deploy to dev → staging → prod
6. **Secure access**: Use bastion host for all database access
7. **IAP permissions**: Regularly review IAP user access
8. **Connection cleanup**: Close database connections when done