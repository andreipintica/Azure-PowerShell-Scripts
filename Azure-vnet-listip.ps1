<#
.SYNOPSIS
List Azure IP adress from NIC.
.DESCRIPTION
List Azure IP adress.
.EXAMPLE
$list_ip

.NOTES
The script can also run in Cloud Shell Console.
#> 

$nic = Get-AzNetworkInterface

$list_ip = @()
foreach( $interface in $nic )
{
    $ip = "" | Select VirtualMachine,Subnet,PrivateIpAddress,Name
    $ip.VirtualMachine = $interface.VirtualMachine.Id.Split("/")[-1]
    $ip.Subnet = $interface.IpConfigurations.Subnet.Id.Split("/")[-1]
    $ip.PrivateIpAddress = $interface.IpConfigurations.PrivateIpAddress
    $ip.name = $interface.Name

    $list_ip += $ip    
}
