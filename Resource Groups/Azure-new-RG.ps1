<#
.SYNOPSIS
Creates an Azure resource group

.DESCRIPTION
Creates an Azure resource group
.EXAMPLE
Just run the script.
Parameter Name - Specifies a name for the resource group.
Parameter Location - Specifies the location of the resource group.

.NOTES
Requires Module Az.Resources
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$Location
)

Import-Module Az

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Force' = $null
                            'Name' = $Name
                            'Location' = $Location}

    $ret = New-AzResourceGroup @cmdArgs

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
