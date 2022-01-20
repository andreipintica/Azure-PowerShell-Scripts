<#
.SYNOPSIS
 Add an allow ICMP ping between two Window's VM's.
.DESCRIPTION
 The script it's creating a new NSG rule to allow the ICMP ping requests 
.EXAMPLE
Just run the script.
.NOTES
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
Requires Module Az.Resources
#>

#Add allow ICMP ping to NSG

Get-AzNetworkSecurityGroup -Name "VMName" | Add-AzNetworkSecurityRuleConfig -Name ICMP-Ping -Description "Allow Ping" -Access Allow -Protocol ICMP -Direction Inbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange * | Set-AzNetworkSecurityGroup
