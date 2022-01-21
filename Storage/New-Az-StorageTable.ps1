<#
    .SYNOPSIS
     Creates a storage table
    
    .COMPONENT
     Requires Module Az.Storage
    
    .Parameter StorageAccountName 
     Specifies the name of the Storage account
     
        
    .Parameter ResourceGroupName
     Specifies the name of the resource group
     
    .Parameter Name
     Specifies the name of the new table name
     
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Name
)

Import-Module Az.Storage

try{
    [string[]]$Properties = @('Name','CloudTable','Uri')
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Name' =$Name
    }
    
    $ret = New-AzStorageTable @cmdArgs | Select-Object $Properties

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
