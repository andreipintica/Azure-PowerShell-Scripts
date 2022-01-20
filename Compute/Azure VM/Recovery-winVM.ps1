<#
.SYNOPSIS
Troubleshoot a Windows VM by attaching the OS disk to a recovery VM using Azure PowerShell.
.DESCRIPTION
If your Windows virtual machine (VM) in Azure encounters a boot or disk error, you may need to perform troubleshooting steps on the disk itself. A common example would be a failed application update that prevents the VM from being able to boot successfully. This article details how to use Azure PowerShell to connect the disk to another Windows VM to fix any errors, then repair your original VM.
.EXAMPLE


.NOTES
Name: Azure-recovery-win
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

The scripts in this article only apply to the VMs that use Managed Disk.

Recovery process overview
We can now use Azure PowerShell to change the OS disk for a VM. We no longer need to delete and recreate the VM.

The troubleshooting process is as follows:

Stop the affected VM.
Create a snapshot from the OS Disk of the VM.
Create a disk from the OS disk snapshot.
Attach the disk as a data disk to a recovery VM.
Connect to the recovery VM. Edit files or run any tools to fix issues on the copied OS disk.
Unmount and detach disk from recovery VM.
Change the OS disk for the affected VM.

#> 

#Make sure that you have the latest Azure PowerShell installed and logged in to your subscription:

Connect-AzAccount

#Determine boot issues

Get-AzVMBootDiagnosticsData -ResourceGroupName myResourceGroup `
    -Name myVM -Windows -LocalPath C:\Users\ops\

#Stop the VM

Stop-AzVM -ResourceGroupName "myResourceGroup" -Name "myVM"

#Create a snapshot from the OS Disk of the VM

$resourceGroupName = 'myResourceGroup' 
$location = 'eastus' 
$vmName = 'myVM'
$snapshotName = 'mySnapshot'  

#Get the VM
$vm = get-azvm `
-ResourceGroupName $resourceGroupName `
-Name $vmName

#Create the snapshot configuration for the OS disk
$snapshot =  New-AzSnapshotConfig `
-SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id `
-Location $location `
-CreateOption copy

#Take the snapshot
New-AzSnapshot `
   -Snapshot $snapshot `
   -SnapshotName $snapshotName `
   -ResourceGroupName $resourceGroupName

#Create a disk from the snapshot

#Set the context to the subscription Id where Managed Disk will be created
#You can skip this step if the subscription is already selected

$subscriptionId = 'yourSubscriptionId'

Select-AzSubscription -SubscriptionId $SubscriptionId

#Provide the name of your resource group
$resourceGroupName ='myResourceGroup'

#Provide the name of the snapshot that will be used to create Managed Disks
$snapshotName = 'mySnapshot' 

#Provide the name of the Managed Disk
$diskName = 'newOSDisk'

#Provide the size of the disks in GB. It should be greater than the VHD file size.
$diskSize = '128'

#Provide the storage type for Managed Disk. Premium_LRS or Standard_LRS.
$storageType = 'Standard_LRS'

#Provide the Azure region (e.g. westus) where Managed Disks will be located.
#This location should be same as the snapshot location
#Get all the Azure location using command below:
#Get-AzLocation
$location = 'eastus'

$snapshot = Get-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName 
 
$diskConfig = New-AzDiskConfig -AccountType $storageType -Location $location -CreateOption Copy -SourceResourceId $snapshot.Id
 
New-AzDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $diskName

#Now you have a copy of the original OS disk. You can mount this disk to another Windows VM for troubleshooting purposes.

#Attach the disk to another Windows VM for troubleshooting
#Now we attach the copy of the original OS disk to a VM as a data disk. This process allows you to correct configuration errors or review additional application or system log files in the disk. The following example attaches the disk named newOSDisk to the VM named RecoveryVM.
#To attach the disk, the copy of the original OS disk and the recovery VM must be in the same location.

$rgName = "myResourceGroup"
$vmName = "RecoveryVM"
$location = "eastus" 
$dataDiskName = "newOSDisk"
$disk = Get-AzDisk -ResourceGroupName $rgName -DiskName $dataDiskName 

$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName 

$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 0 -VM $vm -ManagedDiskId $disk.Id

Update-AzVM -VM $vm -ResourceGroupName $rgName

#Connect to the recovery VM and fix issues on the attached disk
#RDP to your recovery VM using the appropriate credentials. The following example downloads the RDP connection file for the VM named RecoveryVM in the resource group named myResourceGroup, and downloads it to C:\Users\ops\Documents"

Get-AzRemoteDesktopFile -ResourceGroupName "myResourceGroup" -Name "RecoveryVM" `
    -LocalPath "C:\Users\ops\Documents\myVMRecovery.rdp"

#The data disk should be automatically detected and attached. View the list of attached volumes to determine the drive letter as follows:
Get-Disk

#After the copy of the original OS disk is mounted, you can perform any maintenance and troubleshooting steps as needed. Once you have addressed the issues, continue with the following steps.

#Unmount and detach original OS Disk
#Once your errors are resolved, you unmount and detach the existing disk from your recovery VM. You cannot use your disk with any other VM until the lease attaching the disk to the recovery VM is released.
#From within your RDP session, unmount the data disk on your recovery VM. You need the disk number from the previous Get-Disk cmdlet. Then, use Set-Disk to set the disk as offline:
Set-Disk -Number 2 -IsOffline $True

#Confirm the disk is now set as offline using Get-Disk again. 

#Exit your RDP session. From your Azure PowerShell session, remove the disk named newOSDisk from the VM named 'RecoveryVM'.

$myVM = Get-AzVM -ResourceGroupName "myResourceGroup" -Name "RecoveryVM"
Remove-AzVMDataDisk -VM $myVM -Name "newOSDisk"
Update-AzVM -ResourceGroup "myResourceGroup" -VM $myVM

#Change the OS disk for the affected VM
#You can use Azure PowerShell to swap the OS disks. You don't have to delete and recreate the VM.
#This example stops the VM named myVM and assigns the disk named newOSDisk as the new OS disk.

# Get the VM 
$vm = Get-AzVM -ResourceGroupName myResourceGroup -Name myVM 

# Make sure the VM is stopped\deallocated
Stop-AzVM -ResourceGroupName myResourceGroup -Name $vm.Name -Force

# Get the new disk that you want to swap in
$disk = Get-AzDisk -ResourceGroupName myResourceGroup -Name newDisk

# Set the VM configuration to point to the new disk  
Set-AzVMOSDisk -VM $vm -ManagedDiskId $disk.Id -Name $disk.Name  -sto

# Update the VM with the new OS disk. Possible values of StorageAccountType include: 'Standard_LRS' and 'Premium_LRS'
Update-AzVM -ResourceGroupName myResourceGroup -VM $vm -StorageAccountType <Type of the storage account >

# Start the VM
Start-AzVM -Name $vm.Name -ResourceGroupName myResourceGroup

#Verify and enable boot diagnostics
#The following example enables the diagnostic extension on the VM named myVMDeployed in the resource group named myResourceGroup:

$myVM = Get-AzVM -ResourceGroupName "myResourceGroup" -Name "myVMDeployed"
Set-AzVMBootDiagnostics -ResourceGroupName myResourceGroup -VM $myVM -enable
Update-AzVM -ResourceGroup "myResourceGroup" -VM $myVM


