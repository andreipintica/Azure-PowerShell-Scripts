<#
.SYNOPSIS
Create a scale set
.DESCRIPTION
Create a scale set
.NOTES
Name: Azure-create-a-scale-set
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

Requires Module Az

#>

#Create a scale set
New-AzResourceGroup -ResourceGroupName "API-WIN-LAB" -Location "westeurope"
#Create VM
New-AzVmss `
  -ResourceGroupName "API-WIN-LAB" `
  -Location "westeurope" `
  -VMScaleSetName "API-Scale-01" `
  -VirtualNetworkName "API-VNET-01" `
  -SubnetName "API-SUBNET-01" `
  -PublicIpAddressName "API-PU-01" `
  -LoadBalancerName "API-LB-01" `
  -UpgradePolicyMode "Automatic"

#Deploy sample application
# Define the script for your Custom Script Extension to run
$publicSettings = @{
    "fileUris" = (,"https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate-iis.ps1");
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File automate-iis.ps1"
}

# Get information about the scale set
$vmss = Get-AzVmss `
            -ResourceGroupName "API-WIN-LAB" `
            -VMScaleSetName "API-Scale-01"

# Use Custom Script Extension to install IIS and configure basic website
Add-AzVmssExtension -VirtualMachineScaleSet $vmss `
    -Name "customScript" `
    -Publisher "Microsoft.Compute" `
    -Type "CustomScriptExtension" `
    -TypeHandlerVersion 1.8 `
    -Setting $publicSettings

# Update the scale set and apply the Custom Script Extension to the VM instances
Update-AzVmss `
    -ResourceGroupName "API-WIN-LAB" `
    -Name "API-Scale-01" `
    -VirtualMachineScaleSet $vmss

#Allow traffic to application
# Get information about the scale set
$vmss = Get-AzVmss `
            -ResourceGroupName "API-WIN-LAB" `
            -VMScaleSetName "API-Scale-01"

#Create a rule to allow traffic over port 80
$nsgFrontendRule = New-AzNetworkSecurityRuleConfig `
  -Name myFrontendNSGRule `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 200 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 80 `
  -Access Allow

#Create a network security group and associate it with the rule
$nsgFrontend = New-AzNetworkSecurityGroup `
  -ResourceGroupName  "API-WIN-LAB" `
  -Location EastUS `
  -Name myFrontendNSG `
  -SecurityRules $nsgFrontendRule

$vnet = Get-AzVirtualNetwork `
  -ResourceGroupName  "API-WIN-LAB" `
  -Name myVnet

$frontendSubnet = $vnet.Subnets[0]

$frontendSubnetConfig = Set-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork $vnet `
  -Name mySubnet `
  -AddressPrefix $frontendSubnet.AddressPrefix `
  -NetworkSecurityGroup $nsgFrontend

Set-AzVirtualNetwork -VirtualNetwork $vnet

# Update the scale set and apply the Custom Script Extension to the VM instances
Update-AzVmss `
    -ResourceGroupName "API-WIN-LAB" `
    -Name "API-Scale-01" `
    -VirtualMachineScaleSet $vmss
