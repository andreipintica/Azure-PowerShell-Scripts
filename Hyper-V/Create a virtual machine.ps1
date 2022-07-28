# Create a virtual machine

Get-VMSwitch  * | Format-Table Name

New-VM -Name Win10VM -MemoryStartupBytes 4GB -BootDevice VHD -NewVHDPath .\VMs\Win10.vhdx -Path .\VMData -NewVHDSizeBytes 20GB -Generation 2 -Switch ExternalSwitch

Start-VM -Name Win10VM

