<#
.SYNOPSIS
Convert blob storage managed disk to unmanaged disk vhd.
.DESCRIPTION
Convert blob storage managed disk to unmanaged disk vhd.
.NOTES
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
Requires Module.AzureRM.Compute
#>

#Source Subscription

Select-AzureRmSubscription -SubscriptionId '$SubscriptionID’ # selects the subscription that contains the machine/disks that you wish to convert
$sas = Grant-AzureRmDiskAccess -ResourceGroupName "$RgName" -DiskName "Managed_Disk_Name" -DurationInSecond 36000 -Access Read

$destContext = New-AzureStorageContext –StorageAccountName "Destination premium Storage Account Name" -StorageAccountKey "Access Key"
$blobcopy=Start-AzureStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer "storage account container name" -DestContext $destContext -DestBlob "myimage.vhd"

while(($blobCopy | Get-AzureStorageBlobCopyState).Status -eq "Pending")
{
Start-Sleep -s 30
$blobCopy | Get-AzureStorageBlobCopyState
}