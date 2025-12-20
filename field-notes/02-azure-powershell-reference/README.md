---
layout: page
title: "Azure PowerShell Reference"
permalink: /engineer-handbook/02-azure-powershell-reference/
tags: [azure, powershell]
status: published
type: handbook
date: 2025-12-05
summary: "A quick reference for Azure Powershell Commands I use often"
ShowToc: true
---

*A quick reference for Azure Powershell Commands I use often*

| Date | Category |
|------|----------|
| 2025-12-05 | Azure / PowerShell |

---

## **Table of Contents**

### **Getting Started**
* [Installation](#installation)
* [Authentication](#authentication)
* [Subscription Management](#subscription-management-the-basics)
* [Resource Management](#resource-management)

### **Command Reference**
* [Entra ID (Formerly Azure AD)](#entra-id-formerly-azure-ad)
* [Active Directory & Entra Sync](#active-directory--entra-sync)
* [Role Assignments (RBAC)](#role-assignments-rbac)
* [Key Vault & Secrets](#key-vault--secrets)
* [Compute (Virtual Machines)](#compute-virtual-machines)
* [Networking](#networking)
* [Storage](#storage)
* [Azure Policy & Governance](#azure-policy--governance)
* [Monitoring](#monitoring)
* [Azure Migrate](#azure-migrate)

---

## Installation

**Prerequisite:** You need PowerShell 7+ (recommended) or Windows PowerShell 5.1.

### Windows
```powershell
# Option 1: Install from PSGallery (Admin Required)
Install-Module -Name Az -Repository PSGallery -Force

# Option 2: MSI Installer
# Download: https://github.com/Azure/azure-powershell/releases
```

### macOS
```bash
# 1. Install PowerShell via Homebrew
brew install --cask powershell

# 2. Enter PowerShell
pwsh

# 3. Install Az Module
Install-Module -Name Az -Repository PSGallery -Force
```

### Linux
```bash
# Ubuntu / Debian
# 1. Update the list of packages and install wget
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common

# 2. Download the Microsoft repository GPG keys and register repository
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb

# 3. Update & Install
sudo apt-get update
sudo apt-get install -y powershell

# 4. Enter PowerShell & Install Module
pwsh
Install-Module -Name Az -Force
```

## Authentication

### 1. Log In
```powershell
# Interactive Login (Browser)
Connect-AzAccount

# Device Code Login (for servers/headless)
Connect-AzAccount -UseDeviceAuthentication

# Service Principal Login (Automation)
$cred = Get-Credential
Connect-AzAccount -ServicePrincipal -Credential $cred -Tenant "<TENANT_ID>"
```

### 2. Cloud Shell
Alternatively, use the browser-based shell in the Azure Portal.
1. Click `>_` Cloud Shell icon.
2. Select **PowerShell**.

## Subscription Management (The Basics)

Ensure you are running commands against the right subscription.

### 1. View & Set Context
```powershell
# List available subscriptions
Get-AzSubscription

# Set active subscription by Name
Set-AzContext -SubscriptionName "My Subscription"

# Set active subscription by ID (Safer)
Set-AzContext -SubscriptionId "00000000-0000-0000-0000-000000000000"

# Check current context
Get-AzContext

# Find all Az commands
Get-Command -Module Az.*
```

## Resource Management

### 1. Resource Groups
```powershell
# Create a Resource Group
New-AzResourceGroup -Name "<resource-group>" -Location "eastus"

# List all Resource Groups
Get-AzResourceGroup

# Delete a Resource Group
Remove-AzResourceGroup -Name "<resource-group>" -Force
```

### 2. Generic Resources
```powershell
# Remove a specific resource by ID
Remove-AzResource -ResourceId "/subscriptions/..."
```

## Entra ID (Formerly Azure AD)

### 1. Search & Discovery
Often needed to find Object IDs for scripts.
```powershell
# Get current logged-in user context
Get-AzContext | Select-Object Account

# Get User by Email (UPN)
Get-AzADUser -UserPrincipalName "user@example.com"

# Search for a Group by Display Name
Get-AzADGroup -DisplayName "<Group Name>"

# Get a Group's Object ID directly
(Get-AzADGroup -DisplayName "<Group Name>").Id
```

## Active Directory & Entra Sync
*(Run these on the AD Connect Server or RSAT-installed machine)*

### 1. User Attributes
```powershell
# List AD Attributes for a User
Get-ADUser -Identity "username" -Properties * | Format-List

# Set custom attribute for Entra Sync filtering
Set-ADUser -Identity "username" -Replace @{'msDS-cloudExtensionAttribute1'="EntraSync"}
```

### 2. Entra Connect Sync Cycle
```powershell
# View Sync Schedule
Get-ADSyncScheduler

# Manually trigger a Delta Sync
Start-ADSyncSyncCycle -PolicyType Delta
```

## Role Assignments (RBAC)

### 1. View & Assign Roles
```powershell
# Get all role assignments in the subscription
Get-AzRoleAssignment

# Get role assignments for a specific user
Get-AzRoleAssignment -SignInName "user@domain.com"

# Remove a role assignment
Remove-AzRoleAssignment -SignInName "user@domain.com" `
    -RoleDefinitionName "Contributor" `
    -Scope "/subscriptions/<sub-id>/resourceGroups/<resource-group>"
```

## Azure Policy & Governance

### 1. Tags
```powershell
# Apply tags to a resource
$tags = @{"Department"="IT"; "Environment"="Production"}
$resource = Get-AzResource -ResourceGroupName "<resource-group>" -Name "<resource-name>"
New-AzTag -ResourceId $resource.ResourceId -Tag $tags
```

### 2. Resource Locks
```powershell
# Create a CanNotDelete Lock (Prevent accidental deletion)
New-AzResourceLock -LockName "<lock-name>" -LockLevel CanNotDelete `
    -ResourceGroupName "<resource-group>" -ResourceName "<resource-name>" -ResourceType "Microsoft.Storage/storageAccounts"
```

### 3. Policy Assignments
```powershell
# Assign a built-in policy (e.g., Require Tags) to a Resource Group
$definition = Get-AzPolicyDefinition | Where-Object { $_.DisplayName -eq 'Require a tag and its value on resources' }
```

## Key Vault & Secrets

### 1. Key Vault Management
```powershell
# Create a Key Vault
New-AzKeyVault -Name "<kv-name>" -ResourceGroupName "<resource-group>" -Location "eastus"

# List Key Vaults
Get-AzKeyVault
```

### 2. Secret Management
```powershell
# Set/Create a secret (Secure String required)
$Secret = ConvertTo-SecureString -String "MyPassword123!" -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName "<kv-name>" -Name "MySecret" -SecretValue $Secret

# Get a secret (Plain text)
(Get-AzKeyVaultSecret -VaultName "<kv-name>" -Name "MySecret" -AsPlainText)

# List all secrets in a vault
Get-AzKeyVaultSecret -VaultName "<kv-name>"
```

## Compute (Virtual Machines)

### 1. List VMs
```powershell
# List all VMs in the current subscription
Get-AzVM
```

### 2. Manage VM State
```powershell
# Start a VM
Start-AzVM -ResourceGroupName "<resource-group>" -Name "<vm-name>"

# Stop a VM (Deallocate)
Stop-AzVM -ResourceGroupName "<resource-group>" -Name "<vm-name>"

# Restart a VM
Restart-AzVM -ResourceGroupName "<resource-group>" -Name "<vm-name>"
```

## Networking

### 1. Virtual Networks & Subnets
```powershell
# List all Virtual Networks
Get-AzVirtualNetwork

# List Subnets within a VNet
Get-AzVirtualNetwork -Name "<vnet-name>" -ResourceGroupName "<resource-group>" | Select-Object -ExpandProperty Subnets
```

## Storage

### 1. Storage Accounts
```powershell
# Show Storage Accounts
Get-AzStorageAccount

# Create Storage Account (Disabling Public Access)
New-AzStorageAccount -ResourceGroupName "<resource-group>" -Name "<storage-account>" `
    -SkuName Standard_LRS -Location "eastus" -AllowBlobPublicAccess $false
```

## Monitoring

### 1. Activity Logs
```powershell
# Get Activity Log Alerts
Get-AzActivityLogAlert
```

## Azure Migrate

### 1. Installation & Discovery
```powershell
# Install Module
Install-Module Az.Migrate

# View Discovered Servers
Get-AzMigrateDiscoveredServer -ResourceGroupName "<RG>" -ProjectName "<Project>"
```

### 2. Jobs & Replication
```powershell
# View Migrate Jobs
Get-AzMigrateJob -ResourceGroupName "<RG>" -ProjectName "<Project>"

# View Server Replications
Get-AzMigrateServerReplication -ResourceGroupName "<RG>" -ProjectName "<Project>"

# Suspend Replication
Suspend-AzMigrateServerReplication -TargetObjectID "<ID>"
```
