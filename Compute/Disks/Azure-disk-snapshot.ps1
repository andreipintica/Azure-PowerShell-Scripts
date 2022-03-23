#Log into Azure
Connect-AzAccount

#Select the correct subscription
Get-AzSubscription -SubscriptionName "xxxxxx" | Select-AzSubscription

#Set some parameters
$resourceGroupName = 'RGName' 
$location = 'westeurope' 
$vmName = 'VMName'
$snapshotName = 'mySnapshot'

#Get the VM
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

#Create the snapshot configuration
$snapshot =  New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy

#Take the snapshot
New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName

#Next steps
#Create a virtual machine from a snapshot by creating a managed disk 
#from a snapshot and then attaching the new managed disk as the OS disk