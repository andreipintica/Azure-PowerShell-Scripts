<#
    .SYNOPSIS
     Removes the specified storage container
    
    .COMPONENT
     Requires Module Az.Storage
    
    .Parameter StorageAccountName 
     Specifies the name of the Storage account to get containers
        
    .Parameter ResourceGroupName
     Specifies the name of the resource group that contains the Storage containers to get
     
    .Parameter Name 
     Specifies the name of the container to remove
     
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
                            'Confirm' = $false
                            'Force' = $null
                            'Name' = $Name
    }
    $null = Remove-AzStorageContainer @cmdArgs

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Storage container $($Name) removed"
    }
    else{
        Write-Output = "Storage container $($Name) removed"
    }
}
catch{
    throw
}
finally{
}
