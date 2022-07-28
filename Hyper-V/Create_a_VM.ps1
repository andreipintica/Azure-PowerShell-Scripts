Set-Location E:\
Clear-Host

Get-VMSwitch * | Format-Table Name

#create a virtual computer with an existing virtual hard disk
New-VM -Name Win10VM -MemoryStartupBytes 4GB -BootDevice VHD -VHDPath .\VMs\Win10.vhdx -Path .\VMData -Generation 2 -Switch vSwitch01

#region
Get-NetAdapter

New-VMSwitch -name ExternalSwitch  -NetAdapterName Ethernet -AllowManagementOS $true

New-VMSwitch -name InternalSwitch -SwitchType Internal

New-VMSwitch -name PrivateSwitch -SwitchType Private
#endregion

#create a virtual computer with a new virtual hard disk
New-VM -Name Win10VM -MemoryStartupBytes 4GB -BootDevice VHD -NewVHDPath .\VMs\Win10.vhdx -Path .\VMData -NewVHDSizeBytes 20GB -Generation 2 -Switch vSwitch01

#Start the VM
Start-VM -Name Win10VM

#Connect
VMConnect.exe
