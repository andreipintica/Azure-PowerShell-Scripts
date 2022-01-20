<#
.SYNOPSIS
Creates a network security group
.DESCRIPTION
Creates a network security group
.EXAMPLE
Parameter Name - Specifies the name of the network security group to create
Parameter ResourceGroupName - Specifies the name of a resource group
Parameter Location - Specifies the region for which to create a network security group

.NOTES
Requires Module Az.Network
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,    
    [Parameter(Mandatory = $true)]
    [string]$Location
)

Import-Module Az.Network

try{
    [string[]]$Properties = @('Name','Location','ResourceGroupName','Id','Tags','Etag','ProvisioningState','Subnets','ResourceGuid')

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Force' = $null
                            'Name' = $Name
                            'ResourceGroupName' = $ResourceGroupName
                            'Location' =$Location
                            }

    $ret = New-AzNetworkSecurityGroup @cmdArgs | Select-Object $Properties

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
