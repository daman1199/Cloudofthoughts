# Azure CLI Reference for Management Groups & IAM

*A quick reference for Azure CLI commands I use often

| Date | Category |
|------|----------|
| 2025-12-05 | Azure / CLI |

---

## **Table of Contents**

### **Getting Started**
* [Installation](#installation)
* [Azure Cloud Shell](#azure-cloud-shell-browser-based)
* [Authentication](#authentication)
* [Subscription Management](#subscription-management-the-basics)
* [Resource Management (Resource Groups)](#resource-management-resource-groups)

### **Command Reference**
* [Management Groups](#management-groups)
* [Entra ID (Formerly Azure AD)](#entra-id-formerly-azure-ad)
* [Role Assignments (RBAC)](#role-assignments-rbac)
* [Key Vault & Secrets](#key-vault--secrets)
* [Virtual Machines (VMs)](#virtual-machines-vms)
* [Networking](#networking)
* [Storage](#storage)
* [Kubernetes (AKS & Kubectl)](#kubernetes-aks--kubectl)
* [App Service (Web Apps)](#app-service-web-apps)
* [Private Networking & DNS](#private-networking--dns)

---

## Installation

### Windows
```powershell
# Option 1: Chocolatey (My Personal Favorite Windows Package Manager)
choco install azure-cli

# Option 2: Using Winget
winget install -e --id Microsoft.AzureCLI

# Option 3: No Admin Rights (ZIP Method)
# Follow the official guide: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&pivots=zip
```

### macOS
```bash
# Using Homebrew (Recommended)
brew install azure-cli
```

### Linux
```bash
# Ubuntu / Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## Azure Cloud Shell (Browser-Based)

If you don't want to install anything locally, you can use the interactive shell directly in the Azure Portal.

1.  Click the **Cloud Shell** icon (`>_`) in the top navigation bar.
2.  Select **Bash** or **PowerShell**.
3.  **Requirement:** You will be prompted to create a **Storage Account** to persist your files (this incurs a small cost).

![Azure Cloud Shell Icon](./images/azportal-cli.png)

## Authentication

### 1. Log In (Interactive)
The standard way to log in on a local machine.
```bash
# Opens your default browser to sign in
az login
```

### 2. Log In (Device Code)
Use this if you are on a server or the browser doesn't open.
```bash
az login --use-device-code
```

### 3. Log In (Service Principal)
For automation and CI/CD pipelines.
```bash
az login --service-principal -u <APP_ID> -p <PASSWORD> --tenant <TENANT_ID>
```

## Subscription Management (The Basics)

Before running other commands, ensure you are in the correct subscription.

### 1. View Subscriptions
```bash
# List all subscriptions you have access to
az account list
```

### 2. Set Active Subscription
```bash
# Set your active subscription by name
az account set --subscription "my-subscription-name"

# Alternatively, set by Subscription ID
az account set --subscription "00000000-0000-0000-0000-000000000000"
```

### 3. Verify Current Context
```bash
# Check which subscription is currently active
az account show 
```

## Resource Management (Resource Groups)

### 1. Basic Operations
```bash
# Create a Resource Group
az group create --name "<resource-group>" --location eastus

# List all Resource Groups
az group list -o table

# Delete a Resource Group (and all resources inside it)
az group delete --name "<resource-group>" --yes --no-wait
```

## Management Groups

### 1. View Management Groups
```bash
# List all management groups
az account management-group list

# Show details of a specific management group
az account management-group show --name '<management-group-name>'

# Show hierarchy (expand children)
az account management-group show --name '<management-group-name>' -e -r
```

### 2. Create & Update Management Groups
```bash
# Update display name
az account management-group update --name '<management-group-name>' --display-name '<Display Name>'
```

### 3. Move Management Groups
```bash
# Move a management group under a new parent
az account management-group update --name '<management-group-name>' --parent '<parent-management-group>'
```

### 4. Delete Management Group
```bash
# Delete a management group
az account management-group delete --name '<management-group-name>'
```

## Entra ID (Formerly Azure AD)

### 1. Search & Discovery
Often you need to find an Object ID for a script or role assignment.
```bash
# Get current user's details
az ad signed-in-user show

# Find a user by email (User Principal Name)
az ad user show --id "user@example.com"

# Find a group by display name (filter)
az ad group list --filter "displayname eq '<Group Name>'"

# Get Object ID of a specific group
az ad group show --group "<Group Name>" --query id -o tsv
```

### 2. Create a Group
```bash
# Create a new Azure AD group
az ad group create --display-name "<Group Name>" --mail-nickname "<group-nickname>"
```

### 3. List Groups
```bash
# List groups in table format
az ad group list -o table
```

### 4. Add Members to Group
```bash
# 1. Get the Object ID of the user
USER_OBJECT_ID=$(az ad user list --filter "displayname eq 'Jane Doe'" --query "[0].id" -o tsv)

# 2. Add the user to the group
az ad group member add --group "<Group Name>" --member-id $USER_OBJECT_ID

# Verify membership
az ad group member list --group "<Group Name>"
```

## Role Assignments (RBAC)

### 1. Remove Role Assignment
```bash
# Remove 'User Access Administrator' role from a user at the root scope
az role assignment delete \
    --assignee <USER_EMAIL> \
    --role "User Access Administrator" \
    --scope "/"
```

## Virtual Machines (VMs)

### 1. Manage VMs
```bash
# List all VMs in a table
az vm list -o table

# Start/Stop a VM
az vm start -g <resource-group> -n <vm-name>
az vm stop -g <resource-group> -n <vm-name>

# Connect via SSH (if public IP exists)
az ssh vm -g <resource-group> -n <vm-name>
```

### 2. VM Troubleshooting
```bash
# Get VM instance view (status)
az vm get-instance-view -g <resource-group> -n <vm-name> --query instanceView.statuses[1]
```

## Networking

### 1. Virtual Networks (VNet)
```bash
# Create a VNet with a default subnet
az network vnet create -g <resource-group> -n <vnet-name> --address-prefix 10.0.0.0/16 \
    --subnet-name <subnet-name> --subnet-prefix 10.0.1.0/24

# List VNets
az network vnet list -o table
```

### 2. Network Security Groups (NSG)
```bash
# Create an NSG
az network nsg create -g <resource-group> -n <nsg-name>

# Add an inbound rule (Allow SSH)
az network nsg rule create -g <resource-group> --nsg-name <nsg-name> -n AllowSSH \
    --priority 100 --destination-port-ranges 22 --access Allow --protocol Tcp
```

## Storage

### 1. Storage Accounts
```bash
# Create a Storage Account (LRS)
az storage account create -g <resource-group> -n <storage-account> --sku Standard_LRS

# List Storage Accounts
az storage account list -o table
```

### 2. Blob Storage
```bash
# Create a container
az storage container create -n <container-name> --account-name <storage-account>

# Upload a file
az storage blob upload -f ./file.txt -c <container-name> -n file.txt --account-name <storage-account>
```

## Kubernetes (AKS & Kubectl)

### 1. AKS Management
```bash
# Get credentials for kubectl (Merge into ~/.kube/config)
az aks get-credentials -g <resource-group> -n <cluster-name>

# Attach an ACR to an AKS cluster
az aks update -g <resource-group> -n <cluster-name> --attach-acr <acr-name>

# Invoke kubectl (Private Cluster Bypass)
# Use this to run commands against a private cluster without a VPN
az aks command invoke -g <resource-group> -n <cluster-name> --command "kubectl get nodes"
```

### 2. Kubectl Essentials
```bash
# Node & Pod Status
kubectl get nodes -o wide
kubectl get pods -A

# Debugging
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>

# Deploy & Update
kubectl apply -f manifest.yaml
kubectl delete pod <pod-name> # Force restart
kubectl get svc # Check External-IP
```



## Key Vault & Secrets

### 1. Key Vault Management
```bash
# Create a Key Vault
az keyvault create --name "<kv-name>" --resource-group "<resource-group>" --location eastus

# List Key Vaults
az keyvault list -o table
```

### 2. Secret Management
```bash
# Set a secret (Create/Update)
az keyvault secret set --vault-name "<kv-name>" --name "MySecret" --value "MyPassword123!"

# Get a secret value (Plain text)
az keyvault secret show --vault-name "<kv-name>" --name "MySecret" --query value -o tsv

# List all secrets in a vault
az keyvault secret list --vault-name "<kv-name>" -o table
```

## App Service (Web Apps)

### 1. Secure Deployment
```bash
# Create a Linux Web App
az webapp create -g <resource-group> -p <app-service-plan> -n <app-name> --runtime "NODE:18-lts"

# Disable Public Access (Zero Trust)
az webapp update -g <resource-group> -n <app-name> --public-network-access Disabled

# Assign Managed Identity
az webapp identity assign -g <resource-group> -n <app-name>
```



### 2. VNet Integration
```bash
# Connect Web App to a VNet Subnet (Outbound traffic)
az webapp vnet-integration add -g <resource-group> -n <app-name> --vnet <vnet-name> --subnet <subnet-name>
```

## Private Networking & DNS

### 1. Private Endpoints
```bash
# Create a Private Endpoint for a resource (e.g., Web App)
az network private-endpoint create \
    -g <resource-group> -n "<pe-name>" \
    --vnet-name <vnet-name> --subnet <subnet-name> \
    --private-connection-resource-id "/subscriptions/.../sites/<app-name>" \
    --group-id sites --connection-name "<connection-name>"
```

### 2. Private DNS Zones
```bash
# Create a Private DNS Zone
az network private-dns zone create -g <resource-group> -n "privatelink.azurewebsites.net"

# Link Zone to VNet
az network private-dns link vnet create \
    -g <resource-group> -n "<link-name>" \
    -z "privatelink.azurewebsites.net" -v <vnet-name> -e false

# Add A Record (Point to Private Endpoint IP)
az network private-dns record-set a add-record \
    -g <resource-group> -z "privatelink.azurewebsites.net" \
    -n "<app-name>" -a 10.0.1.5
```
