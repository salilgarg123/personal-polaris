# Config management

## Initial Setup

```bash
./setup.sh
```

This will:

1. Copy all `.example` files to actual `.auto.tfvars` files
2. Create symlinks in environment directories
3. Bootstrap the state bucket
4. Configure all backend.tf files

## Update Configuration

Edit the actual config files (not the examples):
    - common.auto.tfvars     # Shared settings
    - dev.auto.tfvars        # Dev-specific settings
    - staging.auto.tfvars    # Staging-specific settings  
    - prod.auto.tfvars       # Production-specific settings

## Team Collaboration

- **Configure**: Each team member runs `./setup-team.sh` once. It's needed for local terraform execution. 
- **Customize**: Each environment can have different settings
