<#
.SYNOPSIS
Removes an Azure resource group

.DESCRIPTION
Removes an Azure resource group
.EXAMPLE
Just run the script.
Parameter Name - Specifies the name of the resource group to remove.
Parameter Identifier - Specifies the ID of the resource group to remove.

.NOTES
Requires Module Az.Resources
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName="byName")]
    [string]$Name,
    [Parameter(Mandatory = $true,ParameterSetName="byID")]
    [string]$Identifier
)

Import-Module Az

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Force' = $null}
    
    if($PSCmdlet.ParameterSetName -eq "byID"){
        $cmdArgs.Add('ID',$Identifier)
        $Script:key = $Identifier
    }
    else{
        $cmdArgs.Add('Name',$Name)
        $Script:key = $Name
    }

    $null = Remove-AzResourceGroup @cmdArgs
    $ret = "Resource group $($Script:key) removed"

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
