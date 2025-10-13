#!/bin/bash

# Polaris Environment Deployment Script
# Usage: ./deploy.sh <environment> [action]
# Example: ./deploy.sh dev plan
# Example: ./deploy.sh staging apply

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check arguments
if [ $# -lt 1 ]; then
    print_error "Usage: $0 <environment> [action]"
    print_info "Environments: dev, staging, prod"
    print_info "Actions: plan, apply, destroy, init"
    exit 1
fi

ENVIRONMENT=$1
ACTION=${2:-plan}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="$SCRIPT_DIR/environments/$ENVIRONMENT"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    print_info "Valid environments: dev, staging, prod"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(plan|apply|destroy|init|output)$ ]]; then
    print_error "Invalid action: $ACTION"
    print_info "Valid actions: plan, apply, destroy, init, output"
    exit 1
fi

# Check if environment directory exists
if [ ! -d "$ENV_DIR" ]; then
    print_error "Environment directory not found: $ENV_DIR"
    exit 1
fi

print_info "🚀 Polaris Infrastructure Deployment"
print_info "Environment: $ENVIRONMENT"
print_info "Action: $ACTION"
print_info "Directory: $ENV_DIR"
echo

# Change to environment directory
cd "$ENV_DIR"

# Check if auto.tfvars files and symlinks exist
if [ ! -f "../../common.auto.tfvars" ] || [ ! -f "../../${ENVIRONMENT}.auto.tfvars" ]; then
    print_warning "Auto.tfvars configuration files not found"
    print_info "Run the setup script from the root terraform directory:"
    print_info "cd ../../ && ./setup.sh"
    exit 1
fi

if [ ! -L "common.auto.tfvars" ] || [ ! -L "${ENVIRONMENT}.auto.tfvars" ]; then
    print_warning "Auto.tfvars symlinks not found in $ENV_DIR"
    print_info "Run the symlink setup script from the root terraform directory:"
    print_info "cd ../../ && ./setup-symlinks.sh"
    read -p "Do you want to run the symlink setup now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd ../..
        ./setup-symlinks.sh
        cd "$ENV_DIR"
        print_success "Symlinks created successfully"
    else
        print_warning "Please ensure auto.tfvars symlinks are created before proceeding"
        exit 1
    fi
fi

# Check if common configuration is updated
if grep -q "your-gcp-project-id" ../../common.auto.tfvars; then
    print_warning "Please update common.auto.tfvars with your actual GCP project ID"
    print_info "Edit: ../../common.auto.tfvars"
    exit 1
fi

# Check if backend configuration has been set up
if grep -q "PLACEHOLDER_BUCKET_NAME" backend.tf; then
    print_warning "Backend bucket name not configured. Please run bootstrap first:"
    print_info "cd ../../ && ./setup.sh"
    exit 1
else
    # Extract bucket name from backend.tf for display
    STATE_BUCKET=$(grep 'bucket = ' backend.tf | sed 's/.*bucket = "\([^"]*\)".*/\1/')
    if [ -n "$STATE_BUCKET" ]; then
        print_info "Using state bucket: $STATE_BUCKET"
    fi
fi

# Execute terraform commands
case $ACTION in
    init)
        print_info "Initializing Terraform for $ENVIRONMENT..."
        terraform init
        ;;
    plan)
        print_info "Planning infrastructure for $ENVIRONMENT..."
        terraform plan -out=tfplan-$ENVIRONMENT
        ;;
    apply)
        if [ -f "tfplan-$ENVIRONMENT" ]; then
            print_info "Applying planned changes for $ENVIRONMENT..."
            terraform apply tfplan-$ENVIRONMENT
        else
            print_warning "No plan file found. Running plan and apply..."
            terraform plan -out=tfplan-$ENVIRONMENT
            terraform apply tfplan-$ENVIRONMENT
        fi
        ;;
    destroy)
        print_warning "This will DESTROY all resources in $ENVIRONMENT!"
        read -p "Are you sure? Type 'yes' to confirm: " -r
        if [[ $REPLY == "yes" ]]; then
            terraform destroy
        else
            print_info "Destroy cancelled"
        fi
        ;;
    output)
        print_info "Terraform outputs for $ENVIRONMENT:"
        terraform output
        ;;
esac

print_success "Operation completed for $ENVIRONMENT environment!"