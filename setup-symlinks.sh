#!/bin/bash

# Setup symlinks for Terraform auto.tfvars files
# This script creates symlinks from environment directories to the root auto.tfvars files

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

print_info "🔗 Setting up Terraform auto.tfvars symlinks"
echo

# Check if we're in the correct directory
if [ ! -f "common.auto.tfvars.example" ]; then
    print_warning "common.auto.tfvars.example not found. Please run this script from the terraform root directory."
    exit 1
fi

# Ensure actual auto.tfvars files exist (copy from examples if needed)
for config_file in common dev staging prod; do
    example_file="${config_file}.auto.tfvars.example"
    target_file="${config_file}.auto.tfvars"
    
    if [ -f "$example_file" ] && [ ! -f "$target_file" ]; then
        cp "$example_file" "$target_file"
        print_success "Created $target_file from example"
    fi
done

# Create symlinks for each environment
for env in dev staging prod; do
    env_dir="environments/$env"
    
    if [ ! -d "$env_dir" ]; then
        print_warning "Environment directory $env_dir not found, skipping..."
        continue
    fi
    
    print_info "Setting up symlinks for $env environment..."
    
    # Create symlink for common.auto.tfvars
    cd "$env_dir"
    if [ -L "common.auto.tfvars" ]; then
        print_info "common.auto.tfvars symlink already exists"
    else
        ln -sf ../../common.auto.tfvars .
        print_success "Created common.auto.tfvars symlink"
    fi
    
    # Create symlink for environment-specific auto.tfvars
    env_tfvars="${env}.auto.tfvars"
    if [ -L "$env_tfvars" ]; then
        print_info "$env_tfvars symlink already exists"
    else
        if [ -f "../../$env_tfvars" ]; then
            ln -sf "../../$env_tfvars" .
            print_success "Created $env_tfvars symlink"
        else
            print_warning "../../$env_tfvars not found, skipping..."
        fi
    fi
    
    cd - > /dev/null
    echo
done

print_success "🎉 Symlink setup complete!"
echo
print_info "📝 Now you can manage all environment configurations from the root directory:"
print_info "  • Edit common.auto.tfvars for shared settings"
print_info "  • Edit dev.auto.tfvars, staging.auto.tfvars, prod.auto.tfvars for environment-specific settings"
echo
print_info "🚀 The changes will automatically be available in each environment directory via symlinks."