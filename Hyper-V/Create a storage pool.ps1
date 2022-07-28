# Create a storage pool

# This line uses the **Get-PhysicalDisk** cmdlet to get all PhysicalDisk objects than are not yet in a (concrete) storage pool, 
# and assigns the array of objects to the $PhysicalDisks variable.

$PhysicalDisks = (Get-PhysicalDisk -CanPool $True)

# This line creates a new storage pool using the $PhysicalDisks variable to specify the disks to include 
# from the WindowsStorage subsystem (specified with a wildcard * to remove the need to modify the friendly name for different computers).

New-StoragePool -FriendlyName CompanyData -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $PhysicalDisks


$PhysicalDisks = (Get-PhysicalDisk -CanPool $True)
New-StoragePool -FriendlyName CompanyData -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $PhysicalDisks`
-ResiliencySettingNameDefault Mirror -ProvisioningTypeDefault Thin -Verbose


$PhysicalDisks = Get-StorageSubSystem -FriendlyName "Windows Storage*" | Get-PhysicalDisk -CanPool $True 
New-StoragePool -FriendlyName "CompanyData" -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $PhysicalDisks |New-VirtualDisk -FriendlyName "UserData" -Size 100GB -ProvisioningType Thin |Initialize-Disk -PassThru |New-Partition -AssignDriveLetter -UseMaximumSize |Format-Volume

