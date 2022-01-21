<#
    .SYNOPSIS
   Downloads a storage blob, existing files are overwritten
    
   .COMPONENT
   Requires Module Az.Storage
    
    .Parameter StorageAccountName 
    Specifies the name of the Storage account to get containers
    
        
    .Parameter ResourceGroupName
    Specifies the name of the resource group that contains the Storage containers to get
    
    .Parameter Container
    Specifies the name of the container
    
    .Parameter BlobNames
    Specifies the names of the blobs to be downloaded
    
    .Parameter CheckMd5 
    Specifies whether to check the Md5 sum for the downloaded file
   
    .Parameter ConcurrentTaskCount 
    Specifies the maximum concurrent network calls
   
    .Parameter Destination 
    Specifies the location to store the downloaded file
     
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
    [Parameter(Mandatory = $true)]
    [string[]]$BlobNames,
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    [switch]$CheckMd5,
    [int]$ConcurrentTaskCount = 10,
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
                            'CheckMd5' = $CheckMd5
                            'Destination' = $Destination
                            'Blob' = $null
                            'Force' = $null
                            'Confirm' = $false
    }
    $ret = @()
    foreach($name in $BlobNames){
        $cmdArgs['Blob'] = $name
        $ret += Get-AzStorageBlobContent @cmdArgs | Select-Object $Properties
    }

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
