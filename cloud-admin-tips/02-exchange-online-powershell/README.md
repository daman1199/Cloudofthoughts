---
layout: page
title: Exchange Online PowerShell Guide
aliases: ["Exchange PowerShell"]
permalink: /cloud-admin-tips/exchange-online-powershell/
tags: [microsoft365, exchange, powershell]
status: published
type: handbook
date: 2025-12-11
summary: "Essential commands and scripts for managing Exchange Online efficiently via PowerShell."
ShowToc: true
---

*Essential commands, connection methods, and scripts for managing Exchange Online efficiently.*

| Date | Category |
|------|----------|
| 2025-12-11 | Exchange / PowerShell |

---

## Installation

### Prerequisites
- PowerShell 7+ (recommended) or Windows PowerShell 5.1
- Global Admin or Exchange Admin permissions

### Install the Module
```powershell
# Install for current user (no admin required)
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser

# Or install globally (requires admin)
Install-Module -Name ExchangeOnlineManagement
```

---

## Connecting to Exchange Online

### Standard Connection
Modern authentication with MFA support:
```powershell
# Interactive login
Connect-ExchangeOnline

# Specify user principal name
Connect-ExchangeOnline -UserPrincipalName admin@domain.com

# Disconnect when done
Disconnect-ExchangeOnline -Confirm:$false
```

### Check Connection Status
```powershell
# Verify you're connected
Get-ConnectionInformation
```

---

## Mailbox Management

<details>

<summary><strong>📬 View all mailbox commands</strong> (Create, modify, statistics, auto-reply)</summary>

### 1. View Mailboxes
```powershell
# List all mailboxes
Get-ExoMailbox -ResultSize Unlimited

# Get specific mailbox
Get-ExoMailbox -Identity user@domain.com

# List shared mailboxes only
Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited

# List room mailboxes
Get-Mailbox -RecipientTypeDetails RoomMailbox -ResultSize Unlimited
```

### 2. Mailbox Statistics
```powershell
# Get mailbox size and item count
Get-ExoMailboxStatistics -Identity user@domain.com

# Export mailbox sizes to CSV
Get-ExoMailbox -ResultSize Unlimited | Get-ExoMailboxStatistics | 
    Select-Object DisplayName, ItemCount, @{Name="Size(GB)";Expression={[math]::Round($_.TotalItemSize.Value.ToBytes()/1GB,2)}} | 
    Export-Csv -Path "C:\MailboxSizes.csv" -NoTypeInformation
```

### 3. Create Mailboxes
```powershell
# Create a new user mailbox
New-Mailbox -Name "John Doe" -DisplayName "John Doe" -Alias jdoe -UserPrincipalName jdoe@domain.com

# Create a shared mailbox
New-Mailbox -Name "Support Team" -DisplayName "Support Team" -Shared -PrimarySmtpAddress support@domain.com
```

### 4. Modify Mailbox Settings
```powershell
# Set mailbox quota
Set-Mailbox -Identity user@domain.com -ProhibitSendQuota 49GB -ProhibitSendReceiveQuota 50GB -IssueWarningQuota 48GB

# Enable litigation hold
Set-Mailbox -Identity user@domain.com -LitigationHoldEnabled $true

# Configure email forwarding
Set-Mailbox -Identity user@domain.com -ForwardingSMTPAddress forward@domain.com -DeliverToMailboxAndForward $true

# Convert user mailbox to shared mailbox
Set-Mailbox -Identity user@domain.com -Type Shared
```

### 5. Out of Office (Auto-Reply)
```powershell
# Set auto-reply for a user
Set-MailboxAutoReplyConfiguration -Identity user@domain.com `
    -AutoReplyState Enabled `
    -InternalMessage "I'm out of office until Monday." `
    -ExternalMessage "Thank you for your email. I will respond when I return."

# Check auto-reply status
Get-MailboxAutoReplyConfiguration -Identity user@domain.com

# Disable auto-reply
Set-MailboxAutoReplyConfiguration -Identity user@domain.com -AutoReplyState Disabled
```

</details>

---

## Permissions Management

<details>

<summary><strong>🔐 View all permission commands</strong> (Calendar, Full Access, Send-As, Send on Behalf)</summary>

### 1. Calendar Delegation (Folder Permissions)
Grant specific rights to another user's calendar or inbox folder.
```powershell
# Grant "Editor" rights to a calendar
Add-MailboxFolderPermission -Identity user@domain.com:\Calendar -User delegate@domain.com -AccessRights Editor -SendNotificationToUser:$true

# Grant "Reviewer" (read-only) access
Add-MailboxFolderPermission -Identity user@domain.com:\Calendar -User delegate@domain.com -AccessRights Reviewer

# View current calendar permissions
Get-MailboxFolderPermission -Identity user@domain.com:\Calendar

# Remove calendar permission
Remove-MailboxFolderPermission -Identity user@domain.com:\Calendar -User delegate@domain.com -Confirm:$false
```

**Common Identities:** `:\Calendar`, `:\Inbox`, `:\Contacts`  
**Access Rights:** `Owner`, `Editor`, `Reviewer`, `Contributor`

### 2. Full Access Permissions
Grant full ownership access to a mailbox (allows opening another user's mailbox in Outlook).
```powershell
# Grant Full Access
Add-MailboxPermission -Identity target@domain.com -User admin@domain.com -AccessRights FullAccess -InheritanceType All

# Grant Full Access without auto-mapping (won't auto-add to Outlook)
Add-MailboxPermission -Identity target@domain.com -User admin@domain.com -AccessRights FullAccess -AutoMapping $false

# Remove Full Access
Remove-MailboxPermission -Identity target@domain.com -User admin@domain.com -AccessRights FullAccess -Confirm:$false

# View all users with Full Access to a mailbox
Get-MailboxPermission -Identity target@domain.com | Where-Object {$_.AccessRights -like "FullAccess"}
```

### 3. Send-As Permissions
Allow a user to send email *as* a specific mailbox or distribution group.
```powershell
# Grant Send-As
Add-RecipientPermission -Identity "Shared Mailbox" -Trustee "User Name" -AccessRights SendAs -Confirm:$false

# Remove Send-As
Remove-RecipientPermission -Identity "Shared Mailbox" -Trustee "User Name" -AccessRights SendAs -Confirm:$false

# View Send-As permissions
Get-RecipientPermission -Identity "Shared Mailbox" | Where-Object {$_.AccessRights -like "SendAs"}
```

### 4. Send on Behalf Permissions
```powershell
# Grant Send on Behalf
Set-Mailbox -Identity shared@domain.com -GrantSendOnBehalfTo user@domain.com

# View Send on Behalf permissions
Get-Mailbox -Identity shared@domain.com | Select-Object GrantSendOnBehalfTo
```

</details>

---

## Distribution Groups

<details>

<summary><strong>👥 View all distribution group commands</strong> (Create, modify, manage membership)</summary>

### 1. Create Distribution Groups
```powershell
# Create a basic distribution group
New-DistributionGroup -Name "IT Department" -DisplayName "IT Department" -PrimarySmtpAddress it@domain.com -Type Distribution

# Create a security-enabled distribution group
New-DistributionGroup -Name "Finance Team" -Type Security -PrimarySmtpAddress finance@domain.com
```

### 2. View Distribution Groups
```powershell
# List all distribution groups
Get-DistributionGroup -ResultSize Unlimited

# Get specific group details
Get-DistributionGroup -Identity "IT Department"

# View group members
Get-DistributionGroupMember -Identity "IT Department"

# Export group membership to CSV
Get-DistributionGroupMember -Identity "IT Department" | Select-Object Name, PrimarySmtpAddress | Export-Csv -Path "C:\ITMembers.csv" -NoTypeInformation
```

### 3. Modify Distribution Groups
```powershell
# Hide group from Global Address List
Set-DistributionGroup -Identity "IT Department" -HiddenFromAddressListsEnabled $true

# Restrict who can send to the group
Set-DistributionGroup -Identity "IT Department" -AcceptMessagesOnlyFromSendersOrMembers "manager@domain.com"

# Require sender authentication (prevent external senders)
Set-DistributionGroup -Identity "IT Department" -RequireSenderAuthenticationEnabled $true

# Set group owner
Set-DistributionGroup -Identity "IT Department" -ManagedBy "admin@domain.com"
```

### 4. Manage Group Membership
```powershell
# Add a member
Add-DistributionGroupMember -Identity "IT Department" -Member user@domain.com

# Remove a member
Remove-DistributionGroupMember -Identity "IT Department" -Member user@domain.com -Confirm:$false

# Add multiple members from CSV
# CSV format: Email
# user1@domain.com
# user2@domain.com
Import-Csv "C:\members.csv" | ForEach-Object {
    Add-DistributionGroupMember -Identity "IT Department" -Member $_.Email
}
```

</details>

---

## Resource & Room Management

<details>

<summary><strong>🏢 View all room & resource commands</strong> (Room mailboxes, booking policies, Places metadata)</summary>

### 1. Create a Room Mailbox
```powershell
# Create a basic room mailbox
New-Mailbox -Name "ConfRoom-4thFl-Large" -Room -DisplayName "4th Floor Conference Room" -PrimarySmtpAddress 4thFL_ConfRoom@domain.com -ResourceCapacity 10
```

### 2. Create a Room List (Building)
Room Lists are distribution groups that group rooms together for the Outlook "Room Finder".
```powershell
# Create a room list
New-DistributionGroup -Name "Headquarters Rooms" -RoomList -PrimarySmtpAddress hq-rooms@domain.com

# Add rooms to the list
Add-DistributionGroupMember -Identity "Headquarters Rooms" -Member 4thFL_ConfRoom@domain.com
```

### 3. Configure Room Booking Policies
```powershell
# Allow automatic booking
Set-CalendarProcessing -Identity 4thFL_ConfRoom@domain.com -AutomateProcessing AutoAccept

# Set booking window (how far in advance)
Set-CalendarProcessing -Identity 4thFL_ConfRoom@domain.com -BookingWindowInDays 180

# Limit meeting duration
Set-CalendarProcessing -Identity 4thFL_ConfRoom@domain.com -MaximumDurationInMinutes 480

# Restrict who can book
Set-CalendarProcessing -Identity 4thFL_ConfRoom@domain.com -BookInPolicy "user1@domain.com","user2@domain.com"
```

### 4. Configure "Places" Metadata
The `Set-Place` cmdlet configures searchable metadata for the Room Finder.
```powershell
# Basic location
Set-Place -Identity "ConfRoom-4thFl-Large" -City "New York"

# Advanced metadata
Set-Place -Identity "ConfRoom-4thFl-Large" `
    -City "New York" `
    -Building "Headquarters" `
    -Floor "4" `
    -AudioDeviceName "PolyCam" `
    -Capacity 10
```
*Note: It may take up to 24 hours for these properties to reflect in the Outlook Room Finder.*

</details>

---

## Mail Flow & Transport Rules

<details>

<summary><strong>📨 View all mail flow commands</strong> (Transport rules, message trace)</summary>

### 1. View Transport Rules
```powershell
# List all transport rules
Get-TransportRule

# Get specific rule details
Get-TransportRule -Identity "Block External Forwarding" | Format-List
```

### 2. Create Transport Rules
```powershell
# Block auto-forwarding to external domains
New-TransportRule -Name "Block External Forwarding" `
    -SentToScope NotInOrganization `
    -MessageTypeMatches AutoForward `
    -RejectMessageReasonText "External forwarding is not allowed."

# Add disclaimer to outbound emails
New-TransportRule -Name "Email Disclaimer" `
    -SentToScope NotInOrganization `
    -ApplyHtmlDisclaimerText "<p><i>This email is confidential...</i></p>" `
    -ApplyHtmlDisclaimerLocation Append
```

### 3. Message Trace
```powershell
# Trace messages from the last 10 days
Get-MessageTrace -SenderAddress user@domain.com -StartDate (Get-Date).AddDays(-10) -EndDate (Get-Date)

# Trace messages to a specific recipient
Get-MessageTrace -RecipientAddress external@example.com -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)

# Export message trace to CSV
Get-MessageTrace -StartDate (Get-Date).AddDays(-2) -EndDate (Get-Date) | 
    Select-Object Received, SenderAddress, RecipientAddress, Subject, Status | 
    Export-Csv -Path "C:\MessageTrace.csv" -NoTypeInformation
```

</details>

---

## Reporting & Auditing

<details>

<summary><strong>📊 View all reporting commands</strong> (Inactive mailboxes, forwarding, permissions audits)</summary>

### 1. Inactive Mailboxes
```powershell
# Find mailboxes not accessed in 90+ days
Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | 
    Where-Object {$_.LastLogonTime -lt (Get-Date).AddDays(-90)} | 
    Select-Object DisplayName, LastLogonTime | 
    Export-Csv -Path "C:\InactiveMailboxes.csv" -NoTypeInformation
```

### 2. Mailbox Forwarding Report
```powershell
# Find all mailboxes with forwarding enabled
Get-Mailbox -ResultSize Unlimited | 
    Where-Object {$_.ForwardingSMTPAddress -ne $null -or $_.ForwardingAddress -ne $null} | 
    Select-Object DisplayName, PrimarySmtpAddress, ForwardingSMTPAddress, ForwardingAddress, DeliverToMailboxAndForward | 
    Export-Csv -Path "C:\ForwardingReport.csv" -NoTypeInformation
```

### 3. Mailbox Permissions Report
```powershell
# Export all Full Access permissions
Get-Mailbox -ResultSize Unlimited | ForEach-Object {
    Get-MailboxPermission -Identity $_.PrimarySmtpAddress | 
        Where-Object {$_.AccessRights -like "FullAccess" -and $_.User -notlike "NT AUTHORITY\SELF"} |
        Select-Object @{Name="Mailbox";Expression={$_.Identity}}, User, AccessRights
} | Export-Csv -Path "C:\FullAccessReport.csv" -NoTypeInformation
```

### 4. Distribution Group Membership Report
```powershell
# Export all groups and their members
Get-DistributionGroup -ResultSize Unlimited | ForEach-Object {
    $group = $_.Name
    Get-DistributionGroupMember -Identity $_ | Select-Object @{Name="Group";Expression={$group}}, Name, PrimarySmtpAddress
} | Export-Csv -Path "C:\GroupMembership.csv" -NoTypeInformation
```

</details>

---

## Useful Tips & Best Practices

<details>

<summary><strong>💡 View tips and best practices</strong></summary>

### 1. Always Use -ResultSize Unlimited
For large tenants, the default result size is limited. Always specify `-ResultSize Unlimited` when querying all objects.

### 2. Error Handling
```powershell
# Stop script on error
$ErrorActionPreference = "Stop"

# Or use -ErrorAction Stop on individual commands
Get-Mailbox -Identity user@domain.com -ErrorAction Stop
```

### 3. Bulk Operations from CSV
```powershell
# Example: Grant Full Access to multiple mailboxes from CSV
# CSV format: Mailbox,User
# shared1@domain.com,user1@domain.com
# shared2@domain.com,user2@domain.com

Import-Csv "C:\permissions.csv" | ForEach-Object {
    Add-MailboxPermission -Identity $_.Mailbox -User $_.User -AccessRights FullAccess -AutoMapping $false
    Write-Host "Granted Full Access to $($_.Mailbox) for $($_.User)"
}
```

### 4. Disconnect When Done
```powershell
# Always disconnect to free up resources
Disconnect-ExchangeOnline -Confirm:$false
```

</details>

---

## Resources & Documentation
- [Exchange Online PowerShell V3 Module](https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2)
- [Exchange Online Cmdlet Reference](https://learn.microsoft.com/en-us/powershell/module/exchange/)
- [Connect to Exchange Online PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-to-exchange-online-powershell)

---

[← Back to Cloud Admin Tips](../)
