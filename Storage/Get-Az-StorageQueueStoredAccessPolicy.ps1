<#
    .SYNOPSIS
     Gets the stored access policy or policies for an Azure storage queue
    .COMPONENT
     Requires Module Az.Storage
    
    .Parameter StorageAccountName 
    Specifies the name of the Storage account
      
    .Parameter ResourceGroupName
    Specifies the name of the resource group
    
    .Parameter Queue
    Specifies the name of the queue

    .Parameter Policy 
    Specifies a stored access policy

#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [string]$Queue,
    [string]$Policy
)

Import-Module Az.Storage

try{
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Queue' = $Queue
    }
    if([System.String]::IsNullOrWhiteSpace($Policy) -eq $false){
        $cmdArgs.Add('Policy',$Policy)
    }
    
    $ret = Get-AzStorageQueueStoredAccessPolicy @cmdArgs | Select-Object *

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
