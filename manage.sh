#!/bin/bash

# Quick Environment Management Script
# This script provides shortcuts for common environment operations

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

show_help() {
    echo "🌟 Polaris Environment Manager"
    echo "=============================="
    echo
    echo "Usage: $0 <command> [environment]"
    echo
    echo "Commands:"
    echo "  setup <env>     - Setup environment (init + plan)"
    echo "  deploy <env>    - Deploy environment (apply)"
    echo "  status <env>    - Show environment status"
    echo "  destroy <env>   - Destroy environment"
    echo "  list            - List all environments"
    echo "  help            - Show this help"
    echo
    echo "Environments: dev, staging, prod"
    echo
    echo "Examples:"
    echo "  $0 setup dev      # Initialize and plan dev environment"
    echo "  $0 deploy staging # Deploy staging environment"
    echo "  $0 status prod    # Show prod environment status"
    echo "  $0 list           # List all environments"
}

list_environments() {
    print_info "Available Environments:"
    echo
    for env in dev staging prod; do
        env_dir="environments/$env"
        if [ -d "$env_dir" ]; then
            tfvars_status="❌"
            state_status="❌"
            
            if [ -f "$env_dir/terraform.tfvars" ]; then
                tfvars_status="✅"
            fi
            
            if [ -f "$env_dir/.terraform/terraform.tfstate" ]; then
                state_status="✅"
            fi
            
            echo "  📂 $env"
            echo "     Config: $tfvars_status | State: $state_status"
        fi
    done
}

setup_environment() {
    local env=$1
    print_info "Setting up $env environment..."
    
    # Check if bootstrap has been run
    if [ ! -f "bootstrap/terraform.tfstate" ]; then
        print_warning "Bootstrap not found. Please run bootstrap first:"
        print_info "./setup.sh"
        return 1
    fi
    
    # Check if symlinks exist
    if [ ! -L "environments/$env/common.auto.tfvars" ]; then
        print_warning "Symlinks not found. Creating them..."
        ./setup-symlinks.sh
    fi
    
    ./deploy.sh "$env" init
    ./deploy.sh "$env" plan
    print_success "$env environment setup complete!"
}

deploy_environment() {
    local env=$1
    print_info "Deploying $env environment..."
    ./deploy.sh "$env" apply
}

show_status() {
    local env=$1
    print_info "Status for $env environment:"
    
    cd "environments/$env"
    if [ -f ".terraform/terraform.tfstate" ]; then
        terraform show -json | jq -r '.values.root_module.resources[] | select(.type != null) | "\(.type).\(.name)"' 2>/dev/null || terraform show
    else
        print_warning "No terraform state found. Run setup first."
    fi
    cd - > /dev/null
}

destroy_environment() {
    local env=$1
    print_warning "This will destroy ALL resources in $env environment!"
    ./deploy.sh "$env" destroy
}

# Main script logic
case ${1:-help} in
    setup)
        if [ -z "$2" ]; then
            print_warning "Please specify environment: dev, staging, or prod"
            exit 1
        fi
        setup_environment "$2"
        ;;
    deploy)
        if [ -z "$2" ]; then
            print_warning "Please specify environment: dev, staging, or prod"
            exit 1
        fi
        deploy_environment "$2"
        ;;
    status)
        if [ -z "$2" ]; then
            print_warning "Please specify environment: dev, staging, or prod"
            exit 1
        fi
        show_status "$2"
        ;;
    destroy)
        if [ -z "$2" ]; then
            print_warning "Please specify environment: dev, staging, or prod"
            exit 1
        fi
        destroy_environment "$2"
        ;;
    list)
        list_environments
        ;;
    help|*)
        show_help
        ;;
esac