<#
.SYNOPSIS
Change the OS disk used by an Azure VM using PowerShell
.DESCRIPTION
Change the OS disk used by an Azure VM using PowerShell
.NOTES
Name: Azure-change-the-os-disk
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

Requires Module Az

#>



#Get a list of disks in a resource group using
Get-AzDisk -ResourceGroupName myResourceGroup | Format-Table -Property Name

#When you have the name of the disk that you would like to use, set that as the OS disk for the VM. This example stop\deallocates the VM named myVM and assigns the disk named newDisk as the new OS disk.

# Get the VM 
$vm = Get-AzVM -ResourceGroupName myResourceGroup -Name myVM 

# Make sure the VM is stopped\deallocated
Stop-AzVM -ResourceGroupName myResourceGroup -Name $vm.Name -Force

# Get the new disk that you want to swap in
$disk = Get-AzDisk -ResourceGroupName myResourceGroup -Name newDisk

# Set the VM configuration to point to the new disk  
Set-AzVMOSDisk -VM $vm -ManagedDiskId $disk.Id -Name $disk.Name 

# Update the VM with the new OS disk
Update-AzVM -ResourceGroupName myResourceGroup -VM $vm 

# Start the VM
Start-AzVM -Name $vm.Name -ResourceGroupName myResourceGroup
