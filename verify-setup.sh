#!/bin/bash

# Verification script to check if setup completed successfully
# This script verifies that the backend configurations have been properly updated

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

print_info "🔍 Verifying Terraform Setup"
echo "============================"

# Check if bootstrap was run
if [ ! -f "bootstrap/terraform.tfstate" ]; then
    print_error "Bootstrap not completed. Please run: ./setup.sh"
    exit 1
fi

print_success "Bootstrap state found"

# Get bucket name from bootstrap
cd bootstrap
BUCKET_NAME=$(terraform output -raw state_bucket_name 2>/dev/null || echo "")
cd ..

if [ -z "$BUCKET_NAME" ]; then
    print_error "Could not get bucket name from bootstrap output"
    exit 1
fi

print_success "State bucket name: $BUCKET_NAME"

# Check each environment backend configuration
all_configured=true
for env in dev staging prod; do
    backend_file="environments/$env/backend.tf"
    if [ -f "$backend_file" ]; then
        if grep -q "PLACEHOLDER_BUCKET_NAME" "$backend_file"; then
            print_error "$env environment backend not configured"
            all_configured=false
        else
            actual_bucket=$(grep 'bucket = ' "$backend_file" | sed 's/.*bucket = "\([^"]*\)".*/\1/')
            if [ "$actual_bucket" = "$BUCKET_NAME" ]; then
                print_success "$env environment backend configured correctly"
            else
                print_error "$env environment has wrong bucket name: $actual_bucket"
                all_configured=false
            fi
        fi
    else
        print_error "$env backend file not found"
        all_configured=false
    fi
done

# Check if configuration files exist
config_ok=true
for config_file in common dev staging prod; do
    example_file="${config_file}.auto.tfvars.example"
    actual_file="${config_file}.auto.tfvars"
    
    if [ ! -f "$example_file" ]; then
        print_error "$example_file template not found"
        config_ok=false
    fi
    
    if [ ! -f "$actual_file" ]; then
        print_warning "$actual_file not created from template"
        config_ok=false
    fi
done

# Check if symlinks exist
symlinks_ok=true
for env in dev staging prod; do
    if [ ! -L "environments/$env/common.auto.tfvars" ]; then
        print_warning "$env environment missing common.auto.tfvars symlink"
        symlinks_ok=false
    fi
    if [ ! -L "environments/$env/$env.auto.tfvars" ]; then
        print_warning "$env environment missing $env.auto.tfvars symlink"
        symlinks_ok=false
    fi
done

if [ "$config_ok" = false ] || [ "$symlinks_ok" = false ]; then
    print_info "Run ./setup.sh to create missing configuration files and symlinks"
fi

echo ""
if [ "$all_configured" = true ]; then
    print_success "🎉 Setup verification passed!"
    echo ""
    print_info "✅ Your Terraform infrastructure is ready to deploy:"
    echo "   ./manage.sh setup dev    # Initialize dev environment"
    echo "   ./manage.sh deploy dev   # Deploy dev environment"
else
    print_error "Setup verification failed. Please check the errors above."
    exit 1
fi