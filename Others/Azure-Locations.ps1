<#
.SYNOPSIS
 Gets all locations and the supported resource providers for each location
.DESCRIPTION
 Gets all locations and the supported resource providers for each location
.EXAMPLE
Just run the script.
.NOTES
Requires Module Az.Resources
#>

Import-Module Az.Resources

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    $ret = Get-AzLocation @cmdArgs | Sort-Object DisplayName | Select-Object *

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
