<#
    .SYNOPSIS
     Gets a list of file shares
    
    .COMPONENT
        Requires Module Az.Storage
     
    .Parameter StorageAccountName 
     Specifies the name of the Storage account

        
    .Parameter ResourceGroupName
     Specifies the name of the resource group
     
    .Parameter Name 
     Specifies the name of the file share

    .Parameter Prefix 
     Specifies the prefix for file shares

    .Parameter ConcurrentTaskCount 
     Specifies the maximum concurrent network calls

    .Parameter Properties
     List of properties to expand. Use * for all properties

#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [string]$Name,
    [string]$Prefix,
    [int]$ConcurrentTaskCount = 10,
    [ValidateSet('*','Name','LastModified','IsSnapshot','SnapshotTime','Quota','CloudFileShare','ShareClient','ShareProperties')]
    [string[]]$Properties = @('Name','LastModified','IsSnapshot','SnapshotTime','Quota')
)

Import-Module Az.Storage

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'ConcurrentTaskCount' = $ConcurrentTaskCount
    }
    if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
    }
    elseif([System.String]::IsNullOrWhiteSpace($Prefix) -eq $false){
        $cmdArgs.Add('Prefix',$Prefix)
    }
    
    $ret = Get-AzStorageShare @cmdArgs | Select-Object $Properties

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
