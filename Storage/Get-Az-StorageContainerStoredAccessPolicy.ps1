<#
    .SYNOPSIS
     Gets the stored access policy or policies for an Azure storage container
  
    .COMPONENT
     Requires Module Az.Storage
    
    .Parameter StorageAccountName 
    Specifies the name of the Storage account
    
    .Parameter ResourceGroupName
    Specifies the name of the resource group

    .Parameter Container
    Specifies the name of the container

    .Parameter Policy
     Specifies the Azure stored access policy

    .Parameter ConcurrentTaskCount 
     Specifies the maximum concurrent network calls

#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Container,
    [string]$Policy,
    [int]$ConcurrentTaskCount = 10
)

Import-Module Az.Storage

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Container' = $Container
                            'Context' = $azAccount.Context
                            'ConcurrentTaskCount' = $ConcurrentTaskCount
    }
    
    if([System.String]::IsNullOrWhiteSpace($Policy) -eq $false){
        $cmdArgs.Add('Policy',$Policy)
    }
    $ret = Get-AzStorageContainerStoredAccessPolicy @cmdArgs | Select-Object *

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
