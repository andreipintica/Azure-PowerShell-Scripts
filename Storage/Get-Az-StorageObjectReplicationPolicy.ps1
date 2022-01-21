<#
    .SYNOPSIS
     Gets or lists object replication policy of a Storage account
    
    .COMPONENT
     Requires Module Az.Storage
    
    .Parameter StorageAccountName 
     Specifies the name of the Storage account
       
    .Parameter ResourceGroupName
     Specifies the name of the resource group
     
    .Parameter PolicyId
     Object Replication Policy Id

#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [string]$PolicyId
)

Import-Module Az.Storage

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'StorageAccountName' = $StorageAccountName
                            'ResourceGroupName' = $ResourceGroupName
    }
    if([System.String]::IsNullOrWhiteSpace($PolicyId) -eq $false){
        $cmdArgs.Add('PolicyId',$PolicyId)
    }
    $ret = Get-AzStorageObjectReplicationPolicy @cmdArgs | Select-Object *

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
