<#
    .SYNOPSIS
    Gets service properties for Azure Storage Blob services
    
    .COMPONENT
    Requires Module Az.Storage
    
    .Parameter StorageAccountName 
    Specifies the name of the Storage account
    
        
    .Parameter ResourceGroupName
    Specifies the name of the resource group
    
    .Parameter Properties
    List of properties to expand. Use * for all properties

#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [ValidateSet('*','StorageAccountName','ResourceGroupName','DefaultServiceVersion','ChangeFeed','IsVersioningEnabled','DeleteRetentionPolicy.Enabled','DeleteRetentionPolicy.Days','RestorePolicy.Enabled','RestorePolicy.Days')]
    [string[]]$Properties = @('StorageAccountName','ResourceGroupName','DefaultServiceVersion','ChangeFeed','IsVersioningEnabled')
)

Import-Module Az.Storage

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'StorageAccountName' = $StorageAccountName
                            'ResourceGroupName' = $ResourceGroupName
    }

    $ret = Get-AzStorageBlobServiceProperty @cmdArgs | Select-Object $Properties

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
