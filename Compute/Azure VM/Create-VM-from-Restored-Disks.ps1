<#
    .SYNOPSIS
    After you restore the disks, use the following steps to create and configure the virtual machine from disk.
    
    .COMPONENT
    Requires Azure Az PowerShell module
    
   .NOTE
    - AzureAz module 3.0.0 or higher is required.
    - To create encrypted VMs from restored disks, your Azure role must have permission to perform the action, Microsoft.KeyVault/vaults/deploy/action. If your role doesn't have this permission, create a custom role with this action. For more information, see Azure custom roles.
    - After restoring disks, you can now get a deployment template which you can directly use to create a new VM. YOu don't need different PowerShell cmdlets to create managed/unmanaged VMs which are encrypted/unencrypted.

#>

#Create a VM using the deployment template
#The resultant job details give the template URI that can be queried and deployed.

$properties = $details.properties
$storageAccountName = $properties["Target Storage Account Name"]
$containerName = $properties["Config Blob Container Name"]
$templateBlobURI = $properties["Template Blob Uri"]

#The template isn't directly accessible since it's under a customer's storage account and the given container. We need the complete URL (along with a temporary SAS token) to access this template.

#First extract the template name from the templateBlobURI. The format is mentioned below. You can use the split operation in PowerShell to extract the final template name from this URL.
https://<storageAccountName.blob.core.windows.net>/<containerName>/<templateName>

#Then the full URL can be generated
Set-AzCurrentStorageAccount -Name $storageAccountName -ResourceGroupName <StorageAccount RG name>
$templateBlobFullURI = New-AzStorageBlobSASToken -Container $containerName -Blob <templateName> -Permission r -FullUri

#Deploy the template to create a new VM
New-AzResourceGroupDeployment -Name ExampleDeployment -ResourceGroupName ExampleResourceGroup -TemplateUri $templateBlobFullURI

#Create a VM using the config file
#The following section lists steps necessary to create a VM using VMConfig file.

#Query the restored disk properties for the job details.
$properties = $details.properties
$storageAccountName = $properties["Target Storage Account Name"]
$containerName = $properties["Config Blob Container Name"]
$configBlobName = $properties["Config Blob Name"]

#Set the Azure storage context and restore the JSON configuration file.
Set-AzCurrentStorageAccount -Name $storageaccountname -ResourceGroupName "testvault"
$destination_path = "C:\vmconfig.json"
Get-AzStorageBlobContent -Container $containerName -Blob $configBlobName -Destination $destination_path
$obj = ((Get-Content -Path $destination_path -Raw -Encoding Unicode)).TrimEnd([char]0x00) | ConvertFrom-Json

#Use the JSON configuration file to create the VM configuration.
$vm = New-AzVMConfig -VMSize $obj.'properties.hardwareProfile'.vmSize -VMName "testrestore"

#Attach the OS disk and data disks. This step provides examples for various managed and encrypted VM configurations. Use the example that suits your VM configuration.

#Non-managed and non-encrypted VMs
Set-AzVMOSDisk -VM $vm -Name "osdisk" -VhdUri $obj.'properties.StorageProfile'.osDisk.vhd.Uri -CreateOption "Attach"
    $vm.StorageProfile.OsDisk.OsType = $obj.'properties.StorageProfile'.OsDisk.OsType
    foreach($dd in $obj.'properties.StorageProfile'.DataDisks)
    {
        $vm = Add-AzVMDataDisk -VM $vm -Name "datadisk1" -VhdUri $dd.vhd.Uri -DiskSizeInGB 127 -Lun $dd.Lun -CreateOption "Attach"
    }

#Non-managed and encrypted VMs with Azure AD (BEK only)
$dekUrl = "https://ContosoKeyVault.vault.azure.net:443/secrets/ContosoSecret007/xx000000xx0849999f3xx30000003163"
    $dekUrl = "/subscriptions/abcdedf007-4xyz-1a2b-0000-12a2b345675c/resourceGroups/ContosoRG108/providers/Microsoft.KeyVault/vaults/ContosoKeyVault"
    Set-AzVMOSDisk -VM $vm -Name "osdisk" -VhdUri $obj.'properties.storageProfile'.osDisk.vhd.uri -DiskEncryptionKeyUrl $dekUrl -DiskEncryptionKeyVaultId $keyVaultId -CreateOption "Attach" -Windows/Linux
    $vm.StorageProfile.OsDisk.OsType = $obj.'properties.storageProfile'.osDisk.osType
    foreach($dd in $obj.'properties.storageProfile'.dataDisks)
    {
    $vm = Add-AzVMDataDisk -VM $vm -Name "datadisk1" -VhdUri $dd.vhd.Uri -DiskSizeInGB 127 -Lun $dd.Lun -CreateOption "Attach"
    }

#Non-managed and encrypted VMs with Azure AD (BEK and KEK)
$dekUrl = "https://ContosoKeyVault.vault.azure.net:443/secrets/ContosoSecret007/xx000000xx0849999f3xx30000003163"
    $kekUrl = "https://ContosoKeyVault.vault.azure.net:443/keys/ContosoKey007/x9xxx00000x0000x9b9949999xx0x006"
    $keyVaultId = "/subscriptions/abcdedf007-4xyz-1a2b-0000-12a2b345675c/resourceGroups/ContosoRG108/providers/Microsoft.KeyVault/vaults/ContosoKeyVault"
    Set-AzVMOSDisk -VM $vm -Name "osdisk" -VhdUri $obj.'properties.storageProfile'.osDisk.vhd.uri -DiskEncryptionKeyUrl $dekUrl -DiskEncryptionKeyVaultId $keyVaultId -KeyEncryptionKeyUrl $kekUrl -KeyEncryptionKeyVaultId $keyVaultId -CreateOption "Attach" -Windows
    $vm.StorageProfile.OsDisk.OsType = $obj.'properties.storageProfile'.osDisk.osType
    foreach($dd in $obj.'properties.storageProfile'.dataDisks)
    {
    $vm = Add-AzVMDataDisk -VM $vm -Name "datadisk1" -VhdUri $dd.vhd.Uri -DiskSizeInGB 127 -Lun $dd.Lun -CreateOption "Attach"
    }

#Non-managed and encrypted VMs without Azure AD (BEK only) 
#The following script needs to be executed only when the source keyVault/secret isn't available.


$dekUrl = "https://ContosoKeyVault.vault.azure.net/secrets/ContosoSecret007/xx000000xx0849999f3xx30000003163"
    $keyVaultId = "/subscriptions/abcdedf007-4xyz-1a2b-0000-12a2b345675c/resourceGroups/ContosoRG108/providers/Microsoft.KeyVault/vaults/ContosoKeyVault"
    $encSetting = "{""encryptionEnabled"":true,""encryptionSettings"":[{""diskEncryptionKey"":{""sourceVault"":{""id"":""$keyVaultId""},""secretUrl"":""$dekUrl""}}]}"
    $osBlobName = $obj.'properties.StorageProfile'.osDisk.name + ".vhd"
    $osBlob = Get-AzStorageBlob -Container $containerName -Blob $osBlobName
    $osBlob.ICloudBlob.Metadata["DiskEncryptionSettings"] = $encSetting
    $osBlob.ICloudBlob.SetMetadata()

#After the secrets are available and the encryption details are also set on the OS Blob, attach the disks using the script given below.
#If the source keyVault/secrets are available already, then the script above need not be executed.

Set-AzVMOSDisk -VM $vm -Name "osdisk" -VhdUri $obj.'properties.StorageProfile'.osDisk.vhd.Uri -CreateOption "Attach"
    $vm.StorageProfile.OsDisk.OsType = $obj.'properties.StorageProfile'.OsDisk.OsType
    foreach($dd in $obj.'properties.StorageProfile'.DataDisks)
    {
    $vm = Add-AzVMDataDisk -VM $vm -Name "datadisk1" -VhdUri $dd.vhd.Uri -DiskSizeInGB 127 -Lun $dd.Lun -CreateOption "Attach"
    }

#Non-managed and encrypted VMs without Azure AD (BEK and KEK) 
#if source keyVault/key/secret are not available restore the key and secrets to key vault using the procedure in Restore an non-encrypted virtual machine from an Azure Backup recovery point. Then execute the following scripts to set encryption details on the restored OS blob (this step isn't required for a data blob). The $dekurl and $kekurl can be fetched from the restored keyVault.
#The script below needs to be executed only when the source keyVault/key/secret isn't available.

$dekUrl = "https://ContosoKeyVault.vault.azure.net/secrets/ContosoSecret007/xx000000xx0849999f3xx30000003163"
    $kekUrl = "https://ContosoKeyVault.vault.azure.net/keys/ContosoKey007/x9xxx00000x0000x9b9949999xx0x006"
    $keyVaultId = "/subscriptions/abcdedf007-4xyz-1a2b-0000-12a2b345675c/resourceGroups/ContosoRG108/providers/Microsoft.KeyVault/vaults/ContosoKeyVault"
    $encSetting = "{""encryptionEnabled"":true,""encryptionSettings"":[{""diskEncryptionKey"":{""sourceVault"":{""id"":""$keyVaultId""},""secretUrl"":""$dekUrl""},""keyEncryptionKey"":{""sourceVault"":{""id"":""$keyVaultId""},""keyUrl"":""$kekUrl""}}]}"
    $osBlobName = $obj.'properties.StorageProfile'.osDisk.name + ".vhd"
    $osBlob = Get-AzStorageBlob -Container $containerName -Blob $osBlobName
    $osBlob.ICloudBlob.Metadata["DiskEncryptionSettings"] = $encSetting
    $osBlob.ICloudBlob.SetMetadata()

#After the key/secrets are available and the encryption details are set on the OS Blob, attach the disks using the script given below.
#If the source keyVault/key/secrets are available, then the script above need not be executed.

Set-AzVMOSDisk -VM $vm -Name "osdisk" -VhdUri $obj.'properties.StorageProfile'.osDisk.vhd.Uri -CreateOption "Attach"
    $vm.StorageProfile.OsDisk.OsType = $obj.'properties.StorageProfile'.OsDisk.OsType
    foreach($dd in $obj.'properties.StorageProfile'.DataDisks)
    {
    $vm = Add-AzVMDataDisk -VM $vm -Name "datadisk1" -VhdUri $dd.vhd.Uri -DiskSizeInGB 127 -Lun $dd.Lun -CreateOption "Attach"
    }

#Managed and non-encrypted VMs ( https://docs.microsoft.com/en-us/azure/virtual-machines/windows/attach-disk-ps )
#Managed and encrypted VMs with Azure AD (BEK and KEK) ( https://docs.microsoft.com/en-us/azure/virtual-machines/windows/attach-disk-ps ) 
#Managed and encrypted VMs without Azure AD (BEK only ( https://docs.microsoft.com/en-us/azure/backup/backup-azure-restore-key-secret )

#Set the Network settings
$nicName="p1234"
$pip = New-AzPublicIpAddress -Name $nicName -ResourceGroupName "test" -Location "WestUS" -AllocationMethod Dynamic
$virtualNetwork = New-AzVirtualNetwork -ResourceGroupName "test" -Location "WestUS" -Name "testvNET" -AddressPrefix 10.0.0.0/16
$virtualNetwork | Set-AzVirtualNetwork
$vnet = Get-AzVirtualNetwork -Name "testvNET" -ResourceGroupName "test"
$subnetindex=0
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName "test" -Location "WestUS" -SubnetId $vnet.Subnets[$subnetindex].Id -PublicIpAddressId $pip.Id
$vm=Add-AzVMNetworkInterface -VM $vm -Id $nic.Id

#Create the virtual machine
New-AzVM -ResourceGroupName "test" -Location "WestUS" -VM $vm

#Push ADE extension. If the ADE extensions aren't pushed, then the data disks will be marked as unencrypted, so it's mandatory for the steps below to be executed:
#For VM with Azure AD - Use the following command to manually enable encryption for the data disks
#BEK only
Set-AzVMDiskEncryptionExtension -ResourceGroupName $RG -VMName $vm.Name -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $dekUrl -DiskEncryptionKeyVaultId $keyVaultId -VolumeType Data

#BEK and KEK
Set-AzVMDiskEncryptionExtension -ResourceGroupName $RG -VMName $vm.Name -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $dekUrl -DiskEncryptionKeyVaultId $keyVaultId  -KeyEncryptionKeyUrl $kekUrl -KeyEncryptionKeyVaultId $keyVaultId -VolumeType Data

#For VM without Azure AD - Use the following command to manually enable encryption for the data disks.
#If during the command execution it asks for AADClientID, then you need to update your Azure PowerShell.

#BEK only
Set-AzVMDiskEncryptionExtension -ResourceGroupName $RG -VMName $vm.Name -DiskEncryptionKeyVaultUrl $dekUrl -DiskEncryptionKeyVaultId $keyVaultId -SkipVmBackup -VolumeType "All"

#BEK and KEK
Set-AzVMDiskEncryptionExtension -ResourceGroupName $RG -VMName $vm.Name -DiskEncryptionKeyVaultUrl $dekUrl -DiskEncryptionKeyVaultId $keyVaultId -KeyEncryptionKeyUrl $kekUrl -KeyEncryptionKeyVaultId $keyVaultId -SkipVmBackup -VolumeType "All"