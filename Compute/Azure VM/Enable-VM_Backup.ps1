<#
    .SYNOPSIS
    Enable Azure VM Backup (Azure Backup) Recovery Services 
    
    .COMPONENT
    Requires Azure Az PowerShell module
    
   .DESCRIPTION
   - Create a Recovery Services vault and set the vault context.
   - Define a backup policy
   - Apply the backup policy to protect multiple virtual machines
   - Trigger an on-demand backup job for the protected virtual machines Before you can back up (or protect) a virtual machine, you must complete the prerequisites to prepare your environment for protecting your VMs.

 

#>

#Find the Azure Backup PowerShell cmdlets available by typing the following command
Get-Command *azrecoveryservices*

#Associate the subscription you want to use with the account, since an account can have several subscriptions
Select-AzSubscription -SubscriptionName $SubscriptionName

#If you're using Azure Backup for the first time, you must use the Register-AzResourceProvider cmdlet to register the Azure Recovery Service provider with your subscription.
Register-AzResourceProvider -ProviderNamespace "Microsoft.RecoveryServices"

#You can verify that the Providers registered successfully:
Get-AzResourceProvider -ProviderNamespace "Microsoft.RecoveryServices" 
#In the command output, the RegistrationState should change to Registered. If not, just run the Register-AzResourceProvider cmdlet again.

### Create a Recovery Services vault ###

#The Recovery Services vault is a Resource Manager resource, so you need to place it within a resource group. You can use an existing resource group, or create a resource group with the New-AzResourceGroup cmdlet. When creating a resource group, specify the name and location for the resource group.
New-AzResourceGroup -Name "test-rg" -Location "West US"

#Use the New-AzRecoveryServicesVault cmdlet to create the Recovery Services vault. Be sure to specify the same location for the vault as was used for the resource group.
New-AzRecoveryServicesVault -Name "testvault" -ResourceGroupName "test-rg" -Location "West US"

#Specify the type of storage redundancy to use. You can use Locally Redundant Storage (LRS), Geo-redundant Storage (GRS), or Zone-redundant storage (ZRS). The following example shows the -BackupStorageRedundancy option for testvault set to GeoRedundant.

$vault1 = Get-AzRecoveryServicesVault -Name "testvault"
Set-AzRecoveryServicesBackupProperty  -Vault $vault1 -BackupStorageRedundancy GeoRedundant

#To view all vaults in the subscription
Get-AzRecoveryServicesVault

#Set vault context
#Before enabling protection on a VM, use Set-AzRecoveryServicesVaultContext to set the vault context. Once the vault context is set, it applies to all subsequent cmdlets. The following example sets the vault context for the vault, testvault.
Get-AzRecoveryServicesVault -Name "testvault" -ResourceGroupName "Contoso-docs-rg" | Set-AzRecoveryServicesVaultContext

#Fetch the vault ID
$targetVault = Get-AzRecoveryServicesVault -ResourceGroupName "Contoso-docs-rg" -Name "testvault"
$targetVault.ID

#If doesn't work, then try this
$targetVaultID = Get-AzRecoveryServicesVault -ResourceGroupName "Contoso-docs-rg" -Name "testvault" | select -ExpandProperty ID

#Modifying storage replication settings
Set-AzRecoveryServicesBackupProperty -Vault $targetVault -BackupStorageRedundancy GeoRedundant/LocallyRedundant

#Create protection policy
#When you create a Recovery Services vault, it comes with default protection and retention policies. The default protection policy triggers a backup job each day at a specified time. The default retention policy retains the daily recovery point for 30 days. You can use the default policy to quickly protect your VM and edit the policy later with different details.

Get-AzRecoveryServicesBackupProtectionPolicy -WorkloadType "AzureVM" -VaultId $targetVault.ID

#Change Schedule Policy Object (UTC timezone) for daily backups 

$schPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM"
$UtcTime = Get-Date -Date "2019-03-20 01:00:00Z"  #You need to provide the start time in 30 minute multiples only. In the example above, it can be only "01:00:00" or "02:30:00". The start time can't be "01:15:00"
$UtcTime = $UtcTime.ToUniversalTime()
$schpol.ScheduleRunTimes[0] = $UtcTime

#New policy

$retPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"
New-AzRecoveryServicesBackupProtectionPolicy -Name "NewPolicy" -WorkloadType "AzureVM" -RetentionPolicy $retPol -SchedulePolicy $schPol -VaultId $targetVault.ID

#Enable protection ###
#Once you've defined the protection policy, you still must enable the policy for an item. Use Enable-AzRecoveryServicesBackupProtection to enable protection. Enabling protection requires two objects - the item and the policy. Once the policy has been associated with the vault, the backup workflow is triggered at the time defined in the policy schedule.

#To enable the protection on non-encrypted Resource Manager VMs:

$pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name "NewPolicy" -VaultId $targetVault.ID
Enable-AzRecoveryServicesBackupProtection -Policy $pol -Name "V2VM" -ResourceGroupName "RGName1" -VaultId $targetVault.ID

#To enable the protection on encrypted VMs (encrypted using BEK and KEK), you must give the Azure Backup service permission to read keys and secrets from the key vault.
Set-AzKeyVaultAccessPolicy -VaultName "KeyVaultName" -ResourceGroupName "RGNameOfKeyVault" -PermissionsToKeys backup,get,list -PermissionsToSecrets get,list -ServicePrincipalName 262044b1-e2ce-469f-a196-69ab7ada62d3
$pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name "NewPolicy" -VaultId $targetVault.ID
Enable-AzRecoveryServicesBackupProtection -Policy $pol -Name "V2VM" -ResourceGroupName "RGName1" -VaultId $targetVault.ID

#To enable the protection on encrypted VMs (encrypted using BEK only), you must give the Azure Backup service permission to read secrets from the key vault.
Set-AzKeyVaultAccessPolicy -VaultName "KeyVaultName" -ResourceGroupName "RGNameOfKeyVault" -PermissionsToSecrets backup,get,list -ServicePrincipalName 262044b1-e2ce-469f-a196-69ab7ada62d3
$pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name "NewPolicy" -VaultId $targetVault.ID
Enable-AzRecoveryServicesBackupProtection -Policy $pol -Name "V2VM" -ResourceGroupName "RGName1" -VaultId $targetVault.ID