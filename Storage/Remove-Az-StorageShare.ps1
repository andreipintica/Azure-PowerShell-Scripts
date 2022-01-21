<#
    .SYNOPSIS
     Deletes a file share
    
    .COMPONENT
     Requires Module Az.Storage
   
    .Parameter StorageAccountName 
     Specifies the name of the Storage account
      
        
    .Parameter ResourceGroupName
     Specifies the name of the resource group

    .Parameter Name 
     Specifies the name of the share

    .Parameter IncludeAllSnapshot
     Remove File Share with all of its snapshots

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
    [switch]$IncludeAllSnapshot,
    [int]$ConcurrentTaskCount = 10
)

Import-Module Az.Storage

try{
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Name' = $Name
                            'Force' = $null
                            'Confirm' = $false
                            'IncludeAllSnapshot' = $IncludeAllSnapshot
                            'ConcurrentTaskCount' = $ConcurrentTaskCount
    }
    
    $null = Remove-AzStorageShare @cmdArgs

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Share $($Name) removed"
    }
    else{
        Write-Output "Share $($Name) removed"
    }
}
catch{
    throw
}
finally{
}
