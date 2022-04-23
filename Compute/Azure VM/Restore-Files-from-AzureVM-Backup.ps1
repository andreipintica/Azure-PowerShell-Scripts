<#
    .SYNOPSIS
    In addition to restoring disks, you can also restore individual files from an Azure VM backup. The restore files functionality provides access to all files in a recovery point. Manage the files via File Explorer as you would for normal files.

    .COMPONENT
    Requires Azure Az PowerShell module
    
   .DESCRIPTION
  The basic steps to restore a file from an Azure VM backup are:
  - Select the VM.
  - Choose a recovery point.
  - Mount the disks of recovery point.
  - Copy the required files.
  - Unmount the disk
#>

#Select the VM (when restoring the VM)
#To get the PowerShell object that identifies the right backup item, start from the container in the vault, and work your way down the object hierarchy.
$namedContainer = Get-AzRecoveryServicesBackupContainer  -ContainerType "AzureVM" -Status "Registered" -FriendlyName "V2VM" -VaultId $targetVault.ID
$backupitem = Get-AzRecoveryServicesBackupItem -Container $namedContainer  -WorkloadType "AzureVM" -VaultId $targetVault.ID

#Choose a recovery point (when restoring the VM)
#ist all recovery points for the backup item. Then choose the recovery point to restore. If you're unsure which recovery point to use, it's a good practice to choose the most recent RecoveryPointType = AppConsistent point in the list.
#In the following script, the variable, $rp, is an array of recovery points for the selected backup item, from the past seven days. The array is sorted in reverse order of time with the latest recovery point at index 0. Use standard PowerShell array indexing to pick the recovery point. In the example, $rp[0] selects the latest recovery point.
$startDate = (Get-Date).AddDays(-7)
$endDate = Get-Date
$rp = Get-AzRecoveryServicesBackupRecoveryPoint -Item $backupitem -StartDate $startdate.ToUniversalTime() -EndDate $enddate.ToUniversalTime() -VaultId $targetVault.ID
$rp[0]

#Mount the disks of recovery point
Get-AzRecoveryServicesBackupRPMountScript -RecoveryPoint $rp[0] -VaultId $targetVault.ID

#Unmount the disks
Disable-AzRecoveryServicesBackupRPMountScript -RecoveryPoint $rp[0] -VaultId $targetVault.ID