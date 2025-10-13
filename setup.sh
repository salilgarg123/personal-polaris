#!/bin/bash

# Polaris Terraform Bootstrap Script
# This script creates the initial GCS bucket for storing Terraform state

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

print_info "🚀 Polaris Terraform Bootstrap"
echo "============================="

# Step 0: Setup configuration files from examples
print_info "🔄 Step 0: Setting up configuration files..."

# Copy auto.tfvars.example files to auto.tfvars if they don't exist
for config_file in common dev staging prod; do
    example_file="${config_file}.auto.tfvars.example"
    target_file="${config_file}.auto.tfvars"
    
    if [ -f "$example_file" ]; then
        if [ ! -f "$target_file" ]; then
            cp "$example_file" "$target_file"
            print_success "Created $target_file from example"
        else
            print_info "$target_file already exists, skipping..."
        fi
    else
        print_warning "$example_file not found, skipping..."
    fi
done

# Setup symlinks for environments
print_info "Setting up environment symlinks..."
./setup-symlinks.sh

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform first."
    print_info "Visit: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli"
    exit 1
fi

# Check if gcloud is installed and configured
if ! command -v gcloud &> /dev/null; then
    print_error "Google Cloud SDK is not installed. Please install gcloud first."  
    print_info "Visit: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

print_success "Prerequisites check passed"

# Navigate to bootstrap directory
if [ ! -d "bootstrap" ]; then
    print_error "Bootstrap directory not found. Please run this script from the terraform root directory."
    exit 1
fi

cd bootstrap

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_warning "terraform.tfvars not found in bootstrap directory"
    print_info "Creating it from terraform.tfvars.example..."
    if [ -f "terraform.tfvars.example" ]; then
        cp terraform.tfvars.example terraform.tfvars
        print_success "Created terraform.tfvars from example"
        print_warning "Please edit bootstrap/terraform.tfvars with your actual GCP project ID"
        print_info "Then run this script again"
        exit 1
    else
        print_error "terraform.tfvars.example not found"
        exit 1
    fi
fi

# Check if project ID is configured
if grep -q "your-gcp-project-id" terraform.tfvars; then
    print_error "Please update bootstrap/terraform.tfvars with your actual GCP project ID"
    exit 1
fi

print_info "Configuration file found and configured"

echo ""
print_info "📋 Bootstrap Steps:"
echo "1. Initialize Terraform (local state)"
echo "2. Create the GCS state bucket"
echo "3. Set up KMS encryption"
echo "4. Output bucket name for environment configuration"
echo ""

read -p "Do you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Bootstrap cancelled."
    exit 0
fi

print_info "🔄 Step 1: Initializing Terraform..."
terraform init

print_info "🔄 Step 2: Planning infrastructure..."
terraform plan -out=tfplan

print_info "🔄 Step 3: Creating state bucket..."
terraform apply tfplan

print_info "🔄 Step 4: Getting bucket name..."
BUCKET_NAME=$(terraform output -raw state_bucket_name)
print_success "State bucket created: $BUCKET_NAME"

print_info "🔄 Step 5: Updating environment backend configurations..."
cd ..

# Update all environment backend.tf files with the actual bucket name
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

echo ""
print_success "🎉 Bootstrap complete!"
echo ""
print_info "📝 Next steps:"
echo "1. All environment backend configurations have been updated with:"
echo "   Bucket name: $BUCKET_NAME"
echo ""
echo "2. Deploy environments using:"
echo "   ./manage.sh setup dev"
echo "   ./manage.sh deploy dev"
echo ""
print_info "The state bucket is ready and configured for all environments!"