---
layout: page
title: "SharePoint App-Only Access via Entra ID"
permalink: /cloud-admin-tips/01-sharepoint-app-only-access/
status: published
type: handbook
date: 2025-12-05
tags: ["sharepoint", "entra-id", "azure-ad", "powershell", "automation", "security"]
author: "Daman Dhaliwal"
description: "Configuring certificate-based authentication for automated SharePoint operations using Microsoft Entra ID App-Only access."
summary: "Configuring certificate-based authentication for automated SharePoint operations."
ShowToc: true
---

*Configuring certificate-based authentication for automated SharePoint operations.*

| Date | Category |
|------|----------|
| 2025-12-05 | SharePoint / Security |

---

## Overview
This guide details how to configure **App-Only authentication** for SharePoint Online using Microsoft Entra ID (formerly Azure AD). This method is essential for background services, automation scripts, and scheduled tasks that run without user interaction.

We will use a **Self-Signed Certificate** to secure the connection, ensuring that no user passwords are stored in scripts.

---

## Prerequisites
- **Global Administrator** or **Application Administrator** rights in Entra ID.
- **PowerShell 7+** recommended.
- **PnP.PowerShell** module installed.

### Install PnP Module
If you haven't already installed the PnP PowerShell module, run the following:

```powershell
# Install for the current user
Install-Module -Name PnP.PowerShell -Scope CurrentUser

# Import the module
Import-Module PnP.PowerShell
```

---

## 1. Generate a Self-Signed Certificate

We will use the `New-PnPAzureCertificate` cmdlet to generate a new certificate pair. 

**Important:** This command protects the PFX file with a password. You must save this password to import the certificate later.

```powershell
# 1. Generate the certificate
# This will output the Common Name (CN), Thumbprint, and Valid dates.
# It will also create 'pnp.pfx' and 'pnp.cer' in your current folder.
$cert = New-PnPAzureCertificate -OutPfx pnp.pfx -OutCert pnp.cer -Store LocalMachine -ValidYears 10

# 2. Get the Password
# The cmdlet generates a secure random password for the PFX. We need to grab it to import it later.
$password = $cert.Password
Write-Host "Certificate Password: $password" -ForegroundColor Cyan
```

*   **pnp.pfx**: Contains the private key (password protected).
*   **pnp.cer**: Contains the public key (safe to share/upload).

---

## 2. Register Application in Entra ID

1.  Navigate to the [Entra ID Portal](https://entra.microsoft.com/) > **App registrations**.
2.  Click **New registration**.
    *   **Name:** `SharePoint-Automation-App` (or your preferred name).
    *   **Supported account types:** Single tenant.
    *   **Redirect URI:** Leave blank.
3.  Click **Register**.
4.  Copy the **Application (client) ID** and **Directory (tenant) ID**.

### Upload the Certificate
1.  In your new App Registration, go to **Certificates & secrets** > **Certificates**.
2.  Click **Upload certificate**.
3.  Select the `pnp.cer` file you generated.
4.  Click **Add**.

---

## 3. Grant SharePoint API Permissions

1.  In the App Registration, go to **API permissions** > **Add a permission**.
2.  Select **SharePoint**.
3.  Choose **Application permissions** (not Delegated).
4.  Select the required permissions (e.g., `Sites.FullControl.All` or `Sites.Read.All`).
5.  Click **Add permissions**.
6.  **Critical Step:** Click **Grant admin consent for [Your Tenant]**.

---

## 4. Install Certificate on Local Machine

Now we import the PFX file into the Windows Certificate Store so your machine can use it to sign requests.

```powershell
# Set location to the Local Machine certificate store
Set-Location -Path Cert:\LocalMachine\My

# Convert the password securely
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

# Import the PFX file using the password we captured earlier
Import-PfxCertificate -FilePath "C:\path\to\pnp.pfx" -Password $securePassword
```

> **Note on "Example 3":** 
> You may see Microsoft documentation referencing "Example 3" where no password is required. That logic *only* applies if the PFX was protected using an Active Directory Domain Account. Since `New-PnPAzureCertificate` creates a *password-protected* PFX by default, the method above (passing `$securePassword`) is the correct and reliable way to import it on any machine.

**Verify Installation:**
```powershell
Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*pnp*" }
```
Copy the **Thumbprint** from the output.

---

## 5. Verify Access & Usage

Now you can connect to SharePoint using the App ID and the locally installed certificate.

```powershell
# Variables
$ClientId   = "<Your-Application-ID>"
$Tenant     = "<Your-Tenant>.onmicrosoft.com"
$SiteUrl    = "https://<Your-Tenant>.sharepoint.com/sites/MySite"
$Thumbprint = "<Your-Certificate-Thumbprint>"

# Connect using the Certificate Thumbprint
Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Thumbprint $Thumbprint -Tenant $Tenant

# Test the connection
Get-PnPWeb
```

---

## Key Takeaways
- **No Passwords:** This method uses a certificate for authentication, eliminating the need to store hardcoded passwords in scripts.
- **Least Privilege:** When assigning API permissions, grant only what is necessary (e.g., `Sites.Read.All` instead of `FullControl` if possible).
- **Certificate Expiry:** Remember to monitor the expiration date of your certificate and rotate it before it expires to prevent service interruptions.

## References
*   [Granting access via Azure AD App-Only (Microsoft Learn)](https://learn.microsoft.com/en-us/sharepoint/dev/solution-guidance/security-apponly-azuread)
