<#
.Description
The script verifies if you have a rule in your Network Security Gourp to permit RDP traffic.
.Info
ssign all the configuration data for your Network Security Group to the $rules variable. 
The following example obtains information about the Network Security Group named myNetworkSecurityGroup in the resource group named myResourceGroup:
#>

$rules = Get-AzNetworkSecurityGroup -ResourceGroupName "myResourceGroup" `
    -Name "myNetworkSecurityGroup"
