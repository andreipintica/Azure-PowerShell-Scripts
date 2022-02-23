<#
.SYNOPSIS
Enable internet connection in Hyper-V VM
.DESCRIPTION
Enable internet connection in Hyper-V VM for nested virtualization scenarios without having a DHCP Server.

.NOTES
https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/setup-nat-network#create-a-nat-virtual-network

VNET network: 172.16.0.0/16

Subnet network: 172.16.2.0/24
#> 

#In the VM where Hyper-V is installed run the following commands:

New-VMSwitch -SwitchName "SwitchName" -SwitchType Internal
Get-NetAdapter - and find the InterfaceIndex related to the previous created switch
New-NetIPAddress -IPAddress 192.168.1.1 -PrefixLength 24 -InterfaceIndex 17
New-NetNat -Name myNAT1 -InternalIPInterfaceAddressPrefix 192.168.1.0/24

#Assign a static IP to the VM created in Hyper-V
#Example
192.168.1.2
255.255.255.0
192.168.1.1
8.8.8.8