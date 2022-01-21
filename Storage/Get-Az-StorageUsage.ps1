<#
    .SYNOPSIS
     Gets the Storage resource usage of the current subscription
    
    .COMPONENT
        Requires Module Az.Storage
    
    .Parameter Location
     Get Storage resources usage on the specified location
     
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Location
)

Import-Module Az.Storage

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Location' = $Location
    }
    
    $ret = Get-AzStorageUsage @cmdArgs | Select-Object *

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
