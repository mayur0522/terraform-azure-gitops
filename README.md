# Terraform Azure GitOps Infrastructure

Infrastructure as Code (IaC) for deploying the Insurance AI Platform on Azure using Terraform and GitOps practices.

## Overview

This repository contains Terraform configurations for provisioning and managing Azure infrastructure for the Insurance AI Platform, including:

- Azure Kubernetes Service (AKS) cluster
- Azure Virtual Networks and Subnets
- Network Security Groups
- Azure Container Registry (ACR)
- PostgreSQL Database (if managed via Terraform)
- Storage Accounts
- Key Vault for secrets management

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.40
- Azure subscription with appropriate permissions
- Service Principal or Managed Identity for authentication

## Project Structure

```
terraform/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── providers.tf        # Provider configuration
├── terraform.tfvars    # Variable values (gitignored)
├── modules/            # Custom Terraform modules
│   ├── aks/
│   ├── networking/
│   └── security/
└── environments/       # Environment-specific configurations
    ├── dev/
    ├── staging/
    └── prod/
```

## Getting Started

### 1. Azure Authentication

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Create Service Principal (optional)
az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"
```

### 2. Initialize Terraform

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format configuration
terraform fmt
```

### 3. Create terraform.tfvars

Create a `terraform.tfvars` file with your specific values:

```hcl
# terraform.tfvars (DO NOT COMMIT - contains sensitive data)

# Azure Configuration
subscription_id = "your-subscription-id"
tenant_id       = "your-tenant-id"
location        = "eastus"

# Resource Group
resource_group_name = "insurance-ai-rg"

# AKS Configuration
aks_cluster_name    = "insurance-ai-aks"
kubernetes_version  = "1.28"
node_count          = 3
vm_size             = "Standard_D4s_v3"

# Network Configuration
vnet_address_space  = ["10.0.0.0/16"]
subnet_address_space = ["10.0.1.0/24"]

# Tags
tags = {
  Environment = "production"
  Project     = "InsuranceAI"
  ManagedBy   = "Terraform"
}
```

### 4. Plan and Apply

```bash
# Review changes
terraform plan

# Apply changes
terraform apply

# Auto-approve (use with caution)
terraform apply -auto-approve
```

## State Management

### Remote State (Recommended)

Configure Azure Storage for remote state:

```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateinsuranceai"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

Initialize with backend:
```bash
terraform init -backend-config="storage_account_name=<your-storage-account>"
```

## Common Commands

```bash
# Show current state
terraform show

# List resources
terraform state list

# View outputs
terraform output

# Destroy resources (use with extreme caution)
terraform destroy

# Target specific resource
terraform apply -target=module.aks

# Import existing resource
terraform import azurerm_kubernetes_cluster.aks /subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.ContainerService/managedClusters/xxx
```

## Modules

### AKS Module
Provisions Azure Kubernetes Service cluster with:
- System and user node pools
- Azure CNI networking
- RBAC enabled
- Azure Monitor integration

### Networking Module
Creates:
- Virtual Network
- Subnets (AKS, Application Gateway, etc.)
- Network Security Groups
- Route tables

### Security Module
Manages:
- Azure Key Vault
- Security policies
- Network security rules

## Environment-Specific Deployments

```bash
# Development
terraform workspace select dev
terraform apply -var-file="environments/dev/terraform.tfvars"

# Staging
terraform workspace select staging
terraform apply -var-file="environments/staging/terraform.tfvars"

# Production
terraform workspace select prod
terraform apply -var-file="environments/prod/terraform.tfvars"
```

## GitOps Integration

This Terraform configuration is designed to work with ArgoCD for continuous deployment:

1. Terraform provisions infrastructure
2. Outputs AKS credentials and configuration
3. ArgoCD deployed to AKS handles application deployments
4. Infrastructure changes tracked via Git

## Outputs

Key outputs from this Terraform configuration:

- `aks_cluster_name` - AKS cluster name
- `aks_kubeconfig` - Kubernetes configuration
- `resource_group_name` - Azure resource group
- `acr_login_server` - Container registry URL

## Security Best Practices

- ✅ Never commit `terraform.tfvars` or `.tfstate` files
- ✅ Use Azure Key Vault for sensitive data
- ✅ Enable AKS managed identity
- ✅ Implement network policies
- ✅ Use private AKS cluster for production
- ✅ Enable Azure Security Center
- ✅ Rotate service principal credentials regularly

## Troubleshooting

### Common Issues

**Authentication Errors:**
```bash
az login --use-device-code
az account show
```

**State Lock Issues:**
```bash
# Remove lock (use carefully)
terraform force-unlock <LOCK_ID>
```

**Resource Already Exists:**
```bash
# Import existing resource
terraform import <resource_type>.<name> <azure_resource_id>
```

## Cost Management

Monitor and optimize costs:

```bash
# Estimate costs before apply
terraform plan -out=tfplan
terraform show -json tfplan | infracost breakdown --path=-
```

## Contributing

1. Create feature branch
2. Make changes
3. Run `terraform fmt` and `terraform validate`
4. Submit pull request with plan output

## Documentation

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## License

[Specify your license]

## Support

For issues and questions:
- Create GitHub issue
- Contact: [your-email@example.com]

---

**Infrastructure managed by Terraform v1.x**  
**Last updated:** 2026-01-28
