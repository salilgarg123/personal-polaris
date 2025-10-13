#!/bin/bash

# Polaris Terraform Team Setup Script
# This script configures Terraform for team members joining an existing project
# Use this when the state bucket already exists and you need to configure your local environment

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

print_info "👥 Polaris Terraform Team Setup"
echo "==============================="

# Check if this is a fresh clone or existing setup
if [ -f "bootstrap/terraform.tfstate" ]; then
    print_warning "Bootstrap state found - you might be the original developer"
    print_info "If you're joining an existing team, please delete bootstrap/terraform.tfstate first"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

print_info "🔄 Setting up for team collaboration..."

# Step 1: Setup configuration files from templates
print_info "Step 1: Setting up configuration files..."
./setup-symlinks.sh

# Step 2: Get the shared state bucket name
print_info "Step 2: Configuring shared state bucket..."
echo ""
print_info "You need the shared state bucket name from your team."
print_info "Ask your team lead for the bucket name, or find it in:"
print_info "  • GCP Console → Cloud Storage"
print_info "  • Look for bucket starting with 'polaris-terraform-state-'"
echo ""

# Prompt for bucket name
while true; do
    read -p "Enter the shared state bucket name: " BUCKET_NAME
    if [ -n "$BUCKET_NAME" ]; then
        # Validate bucket name format
        if [[ "$BUCKET_NAME" =~ ^polaris-terraform-state-[a-f0-9]+$ ]]; then
            break
        else
            print_warning "Bucket name should match pattern: polaris-terraform-state-xxxxxxxx"
            print_info "Please check the bucket name and try again"
        fi
    else
        print_error "Bucket name cannot be empty"
    fi
done

# Step 3: Verify bucket exists and is accessible
print_info "Step 3: Verifying bucket access..."

# Check if gcloud is configured
if ! command -v gcloud &> /dev/null; then
    print_error "Google Cloud SDK not found. Please install gcloud first."
    exit 1
fi

# Try to access the bucket
if ! gsutil ls "gs://$BUCKET_NAME" &>/dev/null; then
    print_error "Cannot access bucket gs://$BUCKET_NAME"
    print_info "Please ensure:"
    print_info "  1. The bucket name is correct"
    print_info "  2. You have access permissions to the bucket"
    print_info "  3. You're authenticated with gcloud (run: gcloud auth login)"
    exit 1
fi

print_success "Bucket access verified: $BUCKET_NAME"

# Step 4: Update backend configurations
print_info "Step 4: Updating backend configurations..."

for env in dev staging prod; do
    backend_file="environments/$env/backend.tf"
    if [ -f "$backend_file" ]; then
        # Replace placeholder with actual bucket name
        sed -i "s/PLACEHOLDER_BUCKET_NAME/$BUCKET_NAME/g" "$backend_file"
        print_success "Updated $backend_file with bucket name"
    else
        print_warning "Backend file not found: $backend_file"
    fi
done

# Step 5: Update configuration with team settings
print_info "Step 5: Configuration guidance..."
echo ""
print_warning "Please update your configuration files:"
print_info "  1. Edit common.auto.tfvars with your GCP project ID"
print_info "  2. Verify environment-specific settings in dev.auto.tfvars, etc."
print_info "  3. Ask your team for any specific configuration values"
echo ""

# Check if common config needs updating
if grep -q "your-gcp-project-id" common.auto.tfvars; then
    print_warning "Don't forget to update common.auto.tfvars with your actual project ID!"
fi

echo ""
print_success "🎉 Team setup complete!"
echo ""
print_info "📝 Next steps:"
echo "1. Update common.auto.tfvars with your GCP project ID"
echo "2. Test your setup:"
echo "   ./manage.sh setup dev"
echo "3. Deploy if needed:"
echo "   ./manage.sh deploy dev"
echo ""
print_info "You're now connected to the shared Terraform state!"