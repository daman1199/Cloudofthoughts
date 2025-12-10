# Script: Google Workspace User Archiver
# Author: Daman Dhaliwal
#
# DESCRIPTION:
# This script automates the full offboarding and archival process for a Google Workspace user using GAM and Google Vault.
#
# WORKFLOW:
# 1. Inputs: Asks for the User Email to archive.
# 2. Local Setup: Creates a temporary local directory to store the export.
# 3. Vault Export: Triggers a Google Vault export (Email & Linked Drive files) for the user.
# 4. Monitoring: Loops and checks the export status every 60 seconds until complete.
# 5. Download: Downloads the resulting PST/ZIP files to the local machine.
# 6. Upload: Creates a folder in a designated Shared Drive (Team Drive) and uploads the archive files.
# 7. Data Transfer: (Optional) Transfers user's Drive and Calendar ownership to the Admin account.
# 8. Deletion: (Optional) Deletes the user account from the tenant.
#
# PREREQUISITES:
# - GAM configured with Vault access.
# - A specific Vault Matter ID (replace <MATTER_ID> placeholders).
# - A Shared Drive ID (replace <TEAM_DRIVE_ID> placeholders).
# - 'admin' alias configured in GAM or specific admin email.

$archive_email = Read-Host "Enter the archive email" #asking user to input the email to be archived
$admin_email = "admin@yourdomain.com" # The account performing the actions
$filepath = "C:\Path\To\Local\Archive"  # Replace with your preferred path

New-Item -Path $filepath -Name $archive_email -ItemType Directory -Force  #creates local folder named after archivee for download

# Start vault export
gam create export matter id:<YOUR_VAULT_MATTER_ID> name ""$archive_email"" corpus mail exportlinkeddrivefiles true accounts $archive_email format pst
Write-Host "Export started. Checking status periodically..."

# Loop to monitor export completion 
$exportComplete = $false
while (!$exportComplete) {
  $exportInfo = gam info export id:<YOUR_VAULT_MATTER_ID> $archive_email #gam command to check export info
  if ($exportInfo -match "completed") {
    $exportComplete = $true
    Write-Host "Export completed."
  }
  else {
    Write-Host "Export still in progress..."
    Start-Sleep -Seconds 60  # Time between export checks
  }
}

# Download file to local path
gam download export id:<YOUR_VAULT_MATTER_ID> $archive_email noextract targetname ""$archive_email"" targetfolder ""$filepath\$archive_email""
Write-Host "Download completed."

#adds drive folder to email archive shared drive
gam user $admin_email add drivefile drivefilename ""$archive_email"" mimetype gfolder teamdriveparentid <YOUR_SHARED_DRIVE_ID> 
Write-Host "Shared Drive Folder created"


#looks for zip files within local path to upload - incase of multiple zips, we use foreach to account for other zip files
$zipFiles = Get-ChildItem -Path "$filepath\$archive_email" | Where-Object { $_.Name -match ".+\.zip$" }
foreach ($zipFile in $zipFiles) {
  gam user $admin_email add drivefile localfile "$($zipFile.FullName)" drivefilename "$archive_email" mimetype "application/zip" teamdriveparentid <YOUR_SHARED_DRIVE_ID> teamdriveparentname ""$archive_email""
  Write-Host "Uploaded: $($zipFile.Name)"
}



# Prompt for data transfer and user deletion
Write-Host "Okay to transfer data (Drive and Calendar) to admin account? (y/n)"
$transfer = Read-Host
if ($transfer -eq "y" -or $transfer -eq "Y" -or $transfer -eq "yes" -or $transfer -eq "Yes") {
  gam create datatransfer $archive_email gdrive, calendar admin privacy_level shared, private
}
else {
  Write-Host "Not transferring data."
}



Write-Host "Okay to delete user? (y/n)"
$delete = Read-Host
if ($delete -eq "y" -or $delete -eq "Y" -or $delete -eq "yes" -or $delete -eq "Yes") {
  gam delete user $archive_email
}
else {
  Write-Host "Not deleting user. Exiting script."
}