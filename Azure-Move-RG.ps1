<#
.SYNOPSIS
Move Azure resources.
.DESCRIPTION
Move Azure resources from a resource group to another resource group.
.EXAMPLE
1. Open PowerShell as an administrator.
2. Run the script.

.NOTES
Name:    Azure-Move-RG
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
#>

# Get the list of resources and store them in a variable.
$resources = Get-AzResource -ResourceGroupName rg-my-old-resourcegroup
# Display the ResoureID values on the screen.
 $resources.ResourceId

 Move the resources to the destination resource group rg-my-new-resourcegroup
 Move-AzResource -DestinationResourceGroupName rg-my-new-resourcegroup -ResourceId $resources.ResourceId

# Gets a list of resources in the source resource group
 Get-AzResource -ResourceGroupName rg-my-old-resourcegroup
# Gets a list of resources in the destination resource group
 Get-AzResource -ResourceGroupName rg-my-new-resourcegroup