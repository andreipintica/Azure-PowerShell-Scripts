<#
    .SYNOPSIS
        Lists blobs in a container
    
    .COMPONENT
        Requires Module Az.Storage
    
    .Parameter StorageAccountName 
    Specifies the name of the Storage account to get containers
        
    .Parameter ResourceGroupName
    Specifies the name of the resource group that contains the Storage containers to get
    
    .Parameter Container
    Specifies the name of the container
    
    .Parameter BlobName 
    Specifies a name or name pattern, which can be used for a wildcard search

    .Parameter IncludeDeleted 
     Include Deleted Blob, by default get blob won't include deleted blob

    .Parameter ConcurrentTaskCount 
     Specifies the maximum concurrent network calls

    .Parameter Prefix 
    Specifies a prefix for the blob names that you want to get. 
    You can use this to find all containers that start with the same string, parameter BlobName is ignored
   
    .Parameter MaxCount 
    Specifies the maximum number of objects that this cmdlet returns

    .Parameter Properties
    List of properties to expand. Use * for all properties

#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Container,
    [string]$BlobName,
    [switch]$IncludeDeleted,
    [int]$ConcurrentTaskCount = 10,
    [string]$Prefix,
    [int]$MaxCount = 25,
    [ValidateSet('*','Name','IsDeleted','Length','LastModified','SnapshotTime','BlobType')]
    [string[]]$Properties = @('Name','IsDeleted','Length','LastModified','BlobType')
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
                            'Container' = $Container
                            'ConcurrentTaskCount' = $ConcurrentTaskCount
                            'IncludeDeleted' = $IncludeDeleted
                            'MaxCount' = $MaxCount
    }
    if([System.String]::IsNullOrWhiteSpace($Prefix) -eq $false){
        $cmdArgs.Add('Prefix',$Prefix)
    }
    elseif([System.String]::IsNullOrWhiteSpace($BlobName) -eq $false){
        $cmdArgs.Add('Blob',$BlobName)
    }
    $ret = Get-AzStorageBlob @cmdArgs | Select-Object $Properties

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
