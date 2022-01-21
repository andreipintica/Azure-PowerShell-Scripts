<#
    .SYNOPSIS
    Removes a network security group
    
    .COMPONENT
    Requires Module Az
    
    .Parameter Name
     Specifies the name of the network security group to remove
    
    .Parameter ResourceGroupName        
    Specifies the name of a resource group that removes the network security group from
    
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [string]$Tenant
)

Import-Module Az.Network

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Force' = $null
                            'Name' = $Name
                            'ResourceGroupName' = $ResourceGroupName
                            }

    $null = Remove-AzNetworkSecurityGroup @cmdArgs 
    $ret = "Network security group $($Name) removed"

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
