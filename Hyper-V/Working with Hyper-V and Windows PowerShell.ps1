Set-location c:\
Clear-Host

#Return a list of Hyper-V commands
Get-Command -Module hyper-v | Out-GridView

Update-Help * -Force

Get-Help Get-VM

#Return a list of virtual machines
Get-VM

Get-VM | where {$_.State -eq 'Running'}

Get-VM | where {$_.State -eq 'Off'}

#Start and shut down virtual machines
Start-VM -Name <virtual machine name>

Get-VM | where {$_.State -eq 'Off'} | Start-VM

Get-VM | where {$_.State -eq 'Running'} | Stop-VM

#Create a VM checkpoint
Get-VM -Name <VM Name> | Checkpoint-VM -SnapshotName <name for snapshot>

$VMName = "VMNAME"

#Create a new virtual machine
 $VM = @{
     Name = $VMName
     MemoryStartupBytes = 2147483648
     Generation = 2
     NewVHDPath = "C:\Virtual Machines\$VMName\$VMName.vhdx"
     NewVHDSizeBytes = 53687091200
     BootDevice = "VHD"
     Path = "C:\Virtual Machines\$VMName"
     SwitchName = (Get-VMSwitch).Name
 }

 New-VM @VM

#Measure
Enable-VMResourceMetering -VMName vmsrv01

Measure-VM vmsrv01

Measure-VM vmsrv01 | fl

Measure-VM vmsrv01 | Select-Object -ExpandProperty NetworkMeteredTrafficReport

Reset-VMResourceMetering -VMName vmsrv01

Disable-VMResourceMetering -VMName vmsrv01