#Create an internal switch
New-VMSwitch -SwitchName "NAT-Switch" -SwitchType Internal

Get-NetAdapter

#NAT Gateway
New-NetIPAddress -IPAddress 192.168.3.2 -PrefixLength 24 -InterfaceIndex 24

#NAT network
New-NetNat -Name MyNATnetwork -InternalIPInterfaceAddressPrefix 192.168.3.0/24