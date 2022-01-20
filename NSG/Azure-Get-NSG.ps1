<#
.SYNOPSIS
Receive the info from a network security group.
.DESCRIPTION
This script is inspired by the article "Delete an Azure VM with objects using PowerShell" by Adam Bertram
.EXAMPLE
Parameter Name - Specifies the name of the network security group  
Parameter ResourceGroupName - Specifies the name of the resource group that the network security group belongs to. Mandatory when parameter name is set!
Parameter Properties - List of properties to expand. Use * for all properties

.NOTES
Requires Module Az.Network
#>

param( 
    [string]$Name,
    [string]$ResourceGroupName,
    [ValidateSet('*','Name','Location','ResourceGroupName','Id','Tags','Etag','ProvisioningState','Subnets','ResourceGuid')]
    [string[]]$Properties = @('Name','Location','ResourceGroupName','Id','Tags','Etag','ProvisioningState','Subnets','ResourceGuid')
)

Import-Module Az.Network

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
    }    
    if([System.String]::IsNullOrWhiteSpace($ResourceGroupName) -eq $false){
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
    }

    $ret = Get-AzNetworkSecurityGroup @cmdArgs | Select-Object $Properties

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
}
