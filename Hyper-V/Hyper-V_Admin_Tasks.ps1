Set-location c:\
Clear-Host

#Memory
Get-Counter -ListSet Arbeitsspeicher | select -expand counter

Get-Counter "\Arbeitsspeicher\Verfügbare mb"

while ($true) { Get-Counter "\Arbeitsspeicher\Verfügbare mb" ; Start-Sleep -s .5 }

Get-VMMemory -ComputerName hvsrv01 -VMName nanosrv01

Set-VMMemory -ComputerName hvsrv01 -VMName vmsrv01 -StartupBytes 1024MB


#Measure
Enable-VMResourceMetering -VMName vmsrv01

Measure-VM vmsrv01

Measure-VM vmsrv01 | fl

Measure-VM vmsrv01 | Select-Object -ExpandProperty NetworkMeteredTrafficReport

Reset-VMResourceMetering -VMName vmsrv01

Disable-VMResourceMetering -VMName vmsrv01

#Integrationservice
Get-VMIntegrationService -VMName vmsrv01

#VMVersion
Get-VMHostSupportedVersion

#Create Disk
New-VHD –path E:\parentdisk.vhdx -Dynamic -SizeBytes 60gb -LogicalSectorSizeBytes 4096

New-VHD -Path E:\diffdisk.vhdx -SizeBytes 1tb -Differencing -ParentPath E:\parentdisk.vhdx

#Achtung: Mount-VHD c:\disks\server1.vhdx -ReadOnly

Optimize-VHD -Path E:\parentdisk.vhdx -Mode full


Convert-VHD -Path E:\parentdisk.vhd -DestinationPath E:\parentdisk.vhdx -VHDType dynamic


Resize-VHD -Path E:\parentdisk.vhdx -SizeBytes 500gb


Merge-VHD -Path E:\diffdisk.vhdx -DestinationPath E:\parentdisk.vhdx


#Switched EmbeddedTeaming
New-VMSwitch -Name setswitch -NetAdapterName "nic1","nic2" -EnableEmbeddedTeaming $true

Add-VMNetworkAdapter -VMName server1 -SwitchName setswitch -Name set1