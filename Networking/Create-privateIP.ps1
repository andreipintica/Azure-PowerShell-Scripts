<#
.SYNOPSIS
Create AZ VM Private IP.
.DESCRIPTION
Create AZ VM Private IP.
.NOTES
Name: Azure-create-privateip
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

Requires Module Az

#>

$RgName = "API-Day4"
$Location = "westeurope"
New-AzResourceGroup -Name $RgName -Location $Location

# Create a subnet configuration
$SubnetConfig = New-AzVirtualNetworkSubnetConfig `
-Name MySubnet `
-AddressPrefix 10.0.0.0/24

# Create a virtual network
$VNet = New-AzVirtualNetwork `
-ResourceGroupName $RgName `
-Location $Location `
-Name MyVNet `
-AddressPrefix 10.0.0.0/16 `
-Subnet $subnetConfig

# Get the subnet object for use in a later step.
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetConfig.Name -VirtualNetwork $VNet

$IpConfigName1 = "IPConfig-1"
$IpConfig1     = New-AzNetworkInterfaceIpConfig `
  -Name $IpConfigName1 `
  -Subnet $Subnet `
  -PrivateIpAddress 10.0.0.4 `
  -Primary

$NIC = New-AzNetworkInterface `
  -Name MyNIC `
  -ResourceGroupName $RgName `
  -Location $Location `
  -IpConfiguration $IpConfig1

$VirtualMachine = New-AzVMConfig -VMName MyVM -VMSize "Standard_DS2_v2"
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName Day4 -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter' -Version latest
New-AzVM -ResourceGroupName $RgName -Location $Location -VM $VirtualMachine -Verbose
