<#
.Description
No Internet access from Azure Windows VM that has multiple IP addresses
.Info
Original product version:   Virtual Machine running Windows
Original KB number:   4040882
This issue occurs because Windows selects the lowest numerical IP address as the primary IP address regardless of the address settings in the Azure portal.

For example, in the Azure portal settings for a Windows virtual machine, you set 10.0.0.10 as the primary IP address and 10.0.0.7 as the secondary IP address. In this situation, Windows selects 10.0.0.7 as primary IP address.

This behavior blocks connectivity because only the IP address that is set as primary in the Azure portal is allowed to connect to the Internet and Azure services.
#>

#To resolve the issue, run the following Windows PowerShell commands to change the primary IP address of the Windows virtual machine:

$primaryIP = "<Primary IP address that you set in Azure portal>"
$netInterface = "<NIC name>"
[array]$IPs = Get-NetIPAddress -InterfaceAlias $netInterface | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.IPAddress -ne $primaryIP}
Set-NetIPAddress -IPAddress $primaryIP -InterfaceAlias $netInterface -SkipAsSource $false
Set-NetIPAddress -IPAddress $IPs.IPAddress -InterfaceAlias $netInterface -SkipAsSource $true
