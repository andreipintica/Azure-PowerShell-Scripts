# Creating a NIC Team

Get-NetAdapter

Get-NetLbfoTeam

New-NetLbfoTeam -Name "Team1" -TeamMembers "NIC1","NIC2"

New-NetLbfoTeam -Name "Team1" -TeamMembers "NIC1","NIC2" -TeamingMode SwitchIndependent -LoadBalancingAlgorithm Dynamic


# Create a NIC Team in a Virtual Machine

Get-VM

Set-VMNetworkAdapter -VMName <VMname> -AllowTeaming On

New-NetLbfoTeam -Name "Team2" -TeamMembers "NIC1","NIC2"


# IP Assign IP address

Set-NetIPAddress -InterfaceIndex 12 -IPAddress 192.168.0.1 -PrefixLength 24

Set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses 192.168.1.10