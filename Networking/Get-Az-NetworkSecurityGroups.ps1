<#
    .SYNOPSIS
        Gets a network security group
    
    .COMPONENT
        Requires Module Az
   
    .Parameter Name
     Specifies the name of the network security group   
     
    .Parameter ResourceGroupName
    Specifies the name of the resource group that the network security group belongs to. 
   
      
    .Parameter Properties
    List of properties to expand. Use * for all properties
    
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
