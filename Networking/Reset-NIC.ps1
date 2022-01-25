<#
.Description
Reset the local administrator account password.
.Info
Reset the network interface for Azure Windows VM to resolve issues when you cannot connect to Microsoft Azure Windows Virtual Machine (VM) after:

You disable the default Network Interface (NIC).
You manually set a static IP for the NIC.
.Notes
Make sure that you have the latest Azure PowerShell installed - https://docs.microsoft.com/en-us/powershell/azure/
Open an elevated Azure PowerShell session (Run as administrator). Run the following commands:
#>

#Set the variables 
$SubscriptionID = "<Subscription ID>"​
$VM = "<VM Name>"
$ResourceGroup = "<Resource Group>"
$VNET = "<Virtual Network>"
$IP = "NEWIP"

#Log in to the subscription​ 
Add-AzAccount
Select-AzSubscription -SubscriptionId $SubscriptionId 

#Check whether the new IP address is available in the virtual network.
Test-AzureStaticVNetIP –VNetName $VNET –IPAddress  $IP

#Add/Change static IP. This process will not change MAC address
Get-AzVM -ResourceGroupName $ResourceGroup -Name $VM | Set-AzureStaticVNetIP -IPAddress $IP | Update-AzVM


<-------------->

#For Classic VMs

#Set the variables 
$SubscriptionID = "<Subscription ID>"​
$VM = "<VM Name>"
$CloudService = "<Cloud Service>"
$VNET = "<Virtual Network>"
$IP = "NEWIP"

#Log in to the subscription​ 
Add-AzureAccount
Select-AzureSubscription -SubscriptionId $SubscriptionId 

#Check whether the new IP address is available in the virtual network.
Test-AzureStaticVNetIP –VNetName $VNET –IPAddress  $IP

#Add/Change static IP. This process will not change MAC address
Get-AzureVM -ResourceGroupName $CloudService -Name $VM | Set-AzureStaticVNetIP -IPAddress $IP |Update-AzureVM
