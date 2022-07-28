Set-location c:\
Clear-Host

#Create a Virtual Switch with PowerShell

Get-NetAdapter

$net = Get-NetAdapter -Name 'Ethernet'

New-VMSwitch -Name "External VM Switch" -AllowManagementOS $True -NetAdapterName $net.Name