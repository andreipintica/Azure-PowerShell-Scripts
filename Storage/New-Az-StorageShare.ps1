<#
    .SYNOPSIS
     Creates a file share
    
    .COMPONENT
     Requires Module Az.Storage
    
    .Parameter StorageAccountName 
     Specifies the name of the Storage account to get containers
        
    .Parameter ResourceGroupName
     Specifies the name of the resource group that contains the Storage containers to get

    .Parameter Name 
     Specifies the name of a file share

    .Parameter ConcurrentTaskCount 
     Specifies the maximum concurrent network calls

#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [int]$ConcurrentTaskCount = 10
)

Import-Module Az.Storage

try{
    [string[]]$Properties = @('Name','LastModified','IsSnapshot','SnapshotTime','Quota')
    
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Name' = $Name
                            'ConcurrentTaskCount' = $ConcurrentTaskCount
    }
    
    $ret = New-AzStorageShare @cmdArgs | Select-Object $Properties

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
