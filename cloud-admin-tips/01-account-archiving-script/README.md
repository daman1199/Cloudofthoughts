---
layout: page
title: "Automating Google Workspace User Archival with GAM"
permalink: /cloud-admin-tips/01-account-archiving-script/
redirect_from:
  - /blog/google-workspace/gam
  - /admin-handbook/01-account-archiving-script/
tags: [google-workspace, admin, gam, powershell, automation]
status: published
type: handbook
date: 2025-12-08
summary: "A PowerShell automation script that handles the full lifecycle of Google Workspace user offboarding using GAM."
ShowToc: true
---

*A PowerShell automation script that handles the full lifecycle of Google Workspace user offboarding using GAM.*

| Date | Category |
|------|----------|
| 2025-12-08 | Google Workspace / Automation |

---

Offboarding users in Google Workspace can be a tedious, multi-step process. You have to create a Vault export, wait for it to process (which can take hours), download the massive files, and then re-upload them to a central storage location. Doing this manually for every employee departure is a tedious mess. 

To make sure I didn't jump off the roof whenever I had to go through this, I made a Powershell script that utilizes GAM to help take some of the load off.

## The Workflow

This script handles the "cold storage" phase of offboarding by performing the following 8 steps autonomously:

1.  **Input:** User provides the email of the departing employee.
2.  **Setup:** Creates a local temporary directory for the download.
3.  **Export:** Triggers a specific Google Vault Matter export (fetching both Email (PST) and Drive files).
4.  **Monitor:** Loops every 60 seconds to check the status of the export until it hits `COMPLETED`.
5.  **Download:** Pulls the generated PST/ZIP files to the local machine using GAM's optimized download.
6.  **Archive:** Uploads these files to a designated "Archive" Shared Drive (Team Drive) for long-term retention.
7.  **Transfer (Optional):** Transfers ownership of remaining Drive/Calendar data to an admin.
8.  **Delete (Optional):** Nukes the account from the tenant.

## The Script

> **Prerequisites:** 
> *   GAM installed and authorized with Vault access.
> *   A configured "Archive/Deleted User" Shared Drive.
> *   A specific Vault Matter created for offboarding (Get the ID via `gam print matters`).

[📄 **View raw PowerShell script**](https://github.com/daman1199/Cloudofthoughts/blob/restructure-folders/cloud-admin-tips/01-account-archiving-script/Google-workspace-archive-account.ps1)

```powershell
# Script: Google Workspace User Archiver
# Author: Daman Dhaliwal

$archive_email = Read-Host "Enter email"
$admin_email = "admin@yourdomain.com"      # The account performing the actions
$filepath = "C:\Path\To\Local\Archive"     # Update this path
$matter_id = "YOUR_VAULT_MATTER_ID"        # Master Archive Matter ID
$team_drive_id = "YOUR_SHARED_DRIVE_ID"    # Archive Shared Drive ID

# 1. Setup Local Directory
New-Item -Path $filepath -Name $archive_email -ItemType Directory -Force

# 2. Start Vault Export
gam create export matter id:$matter_id name "$archive_email" corpus mail exportlinkeddrivefiles true accounts $archive_email format pst
Write-Host "Export started. Monitoring status..."

# 3. Monitor Loop
$exportComplete = $false
while (!$exportComplete) {
  $exportInfo = gam info export id:$matter_id $archive_email
  if ($exportInfo -match "completed") {
    $exportComplete = $true
    Write-Host "Export completed."
  }
  else {
    Write-Host "Export still in progress... (Waiting 60s)"
    Start-Sleep -Seconds 60
  }
}

# 4. Download Export
gam download export id:$matter_id $archive_email noextract targetname "$archive_email" targetfolder "$filepath\$archive_email"
Write-Host "Download completed."

# 5. Upload to Shared Drive
# First, create a folder for the user
gam user $admin_email add drivefile drivefilename "$archive_email" mimetype gfolder teamdriveparentid $team_drive_id
Write-Host "Shared Drive Folder created"

# Upload all ZIP files found in the export
$zipFiles = Get-ChildItem -Path "$filepath\$archive_email" | Where-Object { $_.Name -match ".+\.zip$" }
foreach ($zipFile in $zipFiles) {
  gam user $admin_email add drivefile localfile "$($zipFile.FullName)" drivefilename "$archive_email" mimetype "application/zip" teamdriveparentid $team_drive_id teamdriveparentname "$archive_email"
  Write-Host "Uploaded: $($zipFile.Name)"
}

# 6. Data Transfer & Cleanup (Interactive)
$transfer = Read-Host "Transfer Drive/Calendar ownership to Admin? (y/n)"
if ($transfer -match "y") {
  gam create datatransfer $archive_email gdrive, calendar $admin_email privacy_level shared, private
}

$delete = Read-Host "Delete user account? (y/n)"
if ($delete -match "y") {
  gam delete user $archive_email
}
```

## Practical Implications

This script turns a task that can take hours (depending on the number of users) into something we just have to monitor as it completes.

