<#
.SYNOPSIS
Detach existing storage.
.DESCRIPTION
Detach the data disks from the VM.
.NOTES
Name: Azure-detach-storage
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

Requires Module Az

#>

# STEP 1: Sign-in to Azure via Azure Resource Manager

Login-AzureRmAccount

# STEP 2: Select Azure Subscription

$subscriptionId = 
    ( Get-AzureRmSubscription |
        Out-GridView `
          -Title "Select an Azure Subscription …" `
          -PassThru
    ).SubscriptionId

Get-AzureRmSubscription -SubscriptionId $subscriptionId | Select-AzureRmSubscription

# Detach the data disks from the VM.
$rgName = 'vm-infra-2'
$vmName = 'plweaz1ws2'
$dataDiskCount = 12
$diskNameArray = @()

$VirtualMachine = Get-AzureRmVM -ResourceGroupName $rgName -Name $vmName

for ($i = 1; $i -le $dataDiskCount; $i++) {
    $diskNameArray += $vmName + "_datadisk$i"
}

Remove-AzureRmVMDataDisk -VM $VirtualMachine -DataDiskNames $diskNameArray
Update-AzureRmVM -ResourceGroupName $rgName -VM $VirtualMachine

# Delete the storage
for ($i = 1; $i -le $dataDiskCount; $i++) {
    $dataDiskName = $vmName + "_datadisk$i"
    Remove-AzureRmDisk -ResourceGroupName $rgName -DiskName $dataDiskName -Force
}