<#
.SYNOPSIS
Convert blob storage managed disk to unmanaged disk vhd.
.DESCRIPTION
Convert blob storage managed disk to unmanaged disk vhd.
.NOTES
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
#>

$ResourceGroupName = ''
$VNetName = ''
$SubnetName = ''
$VMName = ''
$VMSize = ''
$Location = ''
$StorageAccountName = ''
$StorageAcccountSrouceContainer = ''
$OSVHDName = ''

# Login to the destination subscription where you have copied the vhd to a storage account
$sub = Connect-AzAccount -ErrorAction Stop
    if($sub){
        Get-AzSubscription| Out-GridView -PassThru -Title "Select your Azure Subscription" |Select-AzSubscription
        
}

$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$VNet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName
$Subnet = $VNet.Subnets |Where-Object {$_.Name -eq $SubnetName}
$Subnet2 = $VNet.Subnets |Where-Object {$_.Name -eq 'vms'}
$pip = New-AzPublicIpAddress -Name "$VMName-pub-ip" -ResourceGroupName $ResourceGroupName -Location $Location -Sku Basic -AllocationMethod Static
$NIC = New-AzNetworkInterface -Name "$VMName-ext-nic" -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $Subnet.Id -EnableIPForwarding -PublicIpAddressId $pip.Id
$NIC2 = New-AzNetworkInterface -Name "$VMName-int-nic" -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $Subnet2.Id -EnableIPForwarding
$SourceOSDiskURI = $StorageAccount.PrimaryEndpoints.Blob + "$StorageAcccountSrouceContainer/" + $OSVHDName
$diskConfig = New-AzDiskConfig -SkuName Standard_LRS -Location $Location -CreateOption Import -StorageAccountId $StorageAccount.Id -SourceUri $SourceOSDiskURI -OsType Linux
$osdisk = New-AzDisk -Disk $diskConfig -ResourceGroupName $ResourceGroupName -DiskName "$VMName-osdisk"
$VM = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VM = Add-AzVMNetworkInterface -VM $VM -Id $NIC.Id -Primary
$VM = Add-AzVMNetworkInterface -VM $VM -Id $NIC2.Id
$VM = Set-AzVMOSDisk -ManagedDiskId $osdisk.Id -VM $VM -CreateOption Attach -Linux
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VM -Verbose