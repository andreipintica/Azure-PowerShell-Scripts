<#
    .SYNOPSIS
     Removes a storage table
    
    .COMPONENT
     Requires Module Az.Storage
     
    .Parameter StorageAccountName 
     Specifies the name of the Storage account
     
        
    .Parameter ResourceGroupName
     Specifies the name of the resource group

    .Parameter Name
     Specifies the table name
     
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
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Name' = $Name
    }
    
    $null = Remove-AzStorageTable @cmdArgs

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Table $($Name) removed"
    }
    else{
        Write-Output "Table $($Name) removed"
    }
}
catch{
    throw
}
finally{
}
