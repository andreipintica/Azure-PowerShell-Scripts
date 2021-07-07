<#
.SYNOPSIS
Search MAC Address in the defined DHCP Scope.
.DESCRIPTION
This script will search for a specific MAC address in the DHCP Scope (you most have access on your AD account to DHCP Scope).
.NOTES
Name: MAC-search
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

Mac search format: xx-xx-xx-xx-xx-xx
#>


$macid = "xx-xx-xx-xx-xx-xx"
$server = 'DHCPServer'
$dhcpsubnets = Get-DhcpServerv4Scope -ComputerName $server
foreach  ($dhcpsubnet in $dhcpsubnets) {
Get-DhcpServerv4Lease -ComputerName $server -ScopeId $dhcpsubnet.scopeid -AllLeases | where {($_.clientid -eq $macid)}
} 
