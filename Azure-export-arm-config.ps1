<#
.SYNOPSIS
Export current arm config.
.DESCRIPTION
Export current arm config json.
.NOTES
Name: Azure-export-arm-config
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

Requires Module Az

#>

#Set up your variables: $subscriptionID = "<SUBSCRIPTION ID>" 
$rgname = "API-WIN-01" 
$vmname = "API-W2016-01"  

#Stop deallocate the VM 
Stop-AzureRmVM -ResourceGroupName $rgname -Name $vmname  
    
#Export the JSON file;  
Get-AzureRmVM -ResourceGroupName $rgname -Name $vmname |ConvertTo-Json -depth 100|Out-file -FilePath c:\temp\$vmname.json