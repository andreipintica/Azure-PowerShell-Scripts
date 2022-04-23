<#
    .SYNOPSIS
    Restore Azure VM Backup (Azure Backup) Recovery Services 
    
    .COMPONENT
    Requires Azure Az PowerShell module
    
   .DESCRIPTION
  The basic steps to restore an Azure VM are:
  - Select the VM.
  - Choose a recovery point.
  - Restore the disks.
  - Create the VM from stored disks.

#>

#Select the VM (when restoring files)
$namedContainer = Get-AzRecoveryServicesBackupContainer  -ContainerType "AzureVM" -Status "Registered" -FriendlyName "V2VM" -VaultId $targetVault.ID
$backupitem = Get-AzRecoveryServicesBackupItem -Container $namedContainer  -WorkloadType "AzureVM" -VaultId $targetVault.ID

#Choose a recovery point (when restoring files)
$startDate = (Get-Date).AddDays(-7)
$endDate = Get-Date
$rp = Get-AzRecoveryServicesBackupRecoveryPoint -Item $backupitem -StartDate $startdate.ToUniversalTime() -EndDate $enddate.ToUniversalTime() -VaultId $targetVault.ID
$rp[0] #In the following script, the variable, $rp, is an array of recovery points for the selected backup item, from the past seven days. The array is sorted in reverse order of time with the latest recovery point at index 0. Use standard PowerShell array indexing to pick the recovery point. In the example, $rp[0] selects the latest recovery point.

#Restore the disks
#To restore the disks and configuration information:
$restorejob = Restore-AzRecoveryServicesBackupItem -RecoveryPoint $rp[0] -StorageAccountName "DestAccount" -StorageAccountResourceGroupName "DestRG" -VaultId $targetVault.ID
$restorejob

#Restore managed disks If the backed VM has managed disks and you want to restore them as managed disks,
#It's strongly recommended to use the TargetResourceGroupName parameter for restoring managed disks since it results in significant performance improvements. If this parameter isn't given, then you can't benefit from the instant restore functionality and the restore operation will be slower in comparison. If the purpose is to restore managed disks as unmanaged disks, then don't provide this parameter and make the intention clear by providing the -RestoreAsUnmanagedDisks parameter. The -RestoreAsUnmanagedDisks parameter is available from Azure PowerShell 3.7.0 onwards. In future versions, it will be mandatory to provide either of these parameters for the right restore experience.
#The VMConfig.JSON file will be restored to the storage account and the managed disks will be restored to the specified target RG.
$restorejob = Restore-AzRecoveryServicesBackupItem -RecoveryPoint $rp[0] -StorageAccountName "DestAccount" -StorageAccountResourceGroupName "DestRG" -TargetResourceGroupName "DestRGforManagedDisks" -VaultId $targetVault.ID

#Wait for the Restore job to complete.
Wait-AzRecoveryServicesBackupJob -Job $restorejob -Timeout 43200

#After restore job has completed
# get the details of the restore operation. The JobDetails property has the information needed to rebuild the VM.

$restorejob = Get-AzRecoveryServicesBackupJob -Job $restorejob -VaultId $targetVault.ID
$details = Get-AzRecoveryServicesBackupJobDetail -Job $restorejob -VaultId $targetVault.ID