<#
.SYNOPSIS
A script is meant to copy a managed disk to a storage account and then later on can be used as unmanaged disk for a VM
The managed disk should be unattached to be able to copy it to a storage account.
.DESCRIPTION
 A script is meant to copy a managed disk to a storage account and then later on can be used as unmanaged disk for a VM
The managed disk should be unattached to be able to copy it to a storage account.
.NOTES

1- The VM where the disk is attached must be deallocated!!
2- Create a storage account at the destination subscription
3- Create a container in the storage account

Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
Requires Module Az.Resources
#>

$SourceResourceGroupName = ""
$SourceManagedDiskName = ""
# Destination Storage account. If not created, you need to create a storage account and provide the details below. You also need to create a container inside the storage account
$DestStorageAccountName = ""
$DestStorageAccountAccessKey = ""
$DestContainerName = ""
$DestVHDName = "$SourceManagedDiskName.vhd"

# Login to the source subscription where you have the source VM
Clear-AzContext -Force -ErrorAction SilentlyContinue
Clear-AzDefault -Force -ErrorAction SilentlyContinue
$sub = Login-AzAccount -ErrorAction Stop
if($sub){
    WriteHeadLineMessage('Select your Azure Subscription - you will be shortly prompted to select the subscription!')
    $subsc = Get-AzSubscription| Out-GridView -PassThru -Title "Select your Azure Subscription" |Select-AzSubscription
    if ($subsc.Count -eq 0 -or $subsc.Count -ne 1){
        Write-Host "`n`nYou need to select one subscription...Terminating the script execution!!`nRe-run the script!!" -ForegroundColor Red -BackgroundColor Black
        exit
    }
    
}


$ManagedDiskSas = Grant-AzDiskAccess -ResourceGroupName $SourceResourceGroupName -DiskName $SourceManagedDiskName -DurationInSecond 3600 -Access Read
$DestStorageAcctContext = New-AzStorageContext –StorageAccountName $DestStorageAccountName -StorageAccountKey $DestStorageAccountAccessKey
# Here we start copying the VM's disk to the destination storage account
$blobcopy = Start-AzStorageBlobCopy -AbsoluteUri $ManagedDiskSas.AccessSAS -DestContainer $DestContainerName -DestContext $DestStorageAcctContext -DestBlob $DestVHDName

# This scripts monitor the status of the VHD copy
while(($blobCopy | Get-AzStorageBlobCopyState).Status -eq "Pending")
{
    Write-Host "Managed Disk $SourceManagedDiskName is still being copied to $($destStorageAcctContext.BlobEndPoint)$DestContainerName/$DestVHDName" -ForegroundColor Yellow
    Start-Sleep -s 30
    $blobCopy | Get-AzStorageBlobCopyState
}
If (($blobCopy | Get-AzStorageBlobCopyState).Status -eq "Success"){
    Write-Host "Managed Disk $SourceManagedDiskName was copied to $($destStorageAcctContext.BlobEndPoint)$DestContainerName/$DestVHDName Sucessfully" -ForegroundColor Green
}
