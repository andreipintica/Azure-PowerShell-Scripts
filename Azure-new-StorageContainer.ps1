<#
.SYNOPSIS
Creates an Azure storage container
.DESCRIPTION
Creates an Azure storage container
.EXAMPLE
Just run the script.
Parameter StorageAccountName - Specifies the name of the Storage account to get containers.
Parameter ResourceGroupName - Specifies the name of the resource group that contains the Storage containers to get.
Parameter Name - Specifies a name for the new container.
Parameter Permission - Specifies the level of public access to this container.
Parameter ConcurrentTaskCount - Specifies the maximum concurrent network calls.
.NOTES
Requires Module Az.Resources
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [ValidateSet('Off','Container','Blob')]
    [string]$Permission = 'Off',
    [int]$ConcurrentTaskCount = 10
)

Import-Module Az.Storage

try{
    [string[]]$Properties = @('Name','LastModified','PublicAccess')

    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Name' = $Name
                            'Permission' = $Permission
                            'ConcurrentTaskCount' = $ConcurrentTaskCount
    }
    
    $ret = New-AzStorageContainer @cmdArgs | Select-Object $Properties

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