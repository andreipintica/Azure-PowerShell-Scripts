<#
.SYNOPSIS
convert a virtual machine, not in an availability set, but with virtual hard disks in a storage account (without encryption) to a virtual machine using Managed Disks
.DESCRIPTION
 convert a virtual machine, not in an availability set, but with virtual hard disks in a storage account (without encryption) to a virtual machine using Managed Disks
.NOTES

#The first section of the script prepares three variables to store information about your environment:

ResourceGroupName: The name of the resource group that contains the virtual machine you wish to convert to use Managed Disks
VMName: The name of the virtual machine in question
SubscriptionID: The GUID of the subscription that contains the resource group and the virtual machine

Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
Requires Module.AzureRM.Compute
#>

Login-AzureRmAccount #will request your login credentials so that the current PowerShell session can sign you into your account.

Install-Module AzureRM.Compute -RequiredVersion 2.6.0 -AllowClobber
$ResourceGroupName = "RGName"
$VMName = "VMName"
$SubscriptionID = "subID"

Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId $SubscriptionID

Stop-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName -Force

ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $ResourceGroupName -VMName $VMName