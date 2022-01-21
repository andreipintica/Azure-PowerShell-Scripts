<#
    .SYNOPSIS
     Gets properties for Azure Storage services
    
    .COMPONENT
     Requires Module Az.Storage
    
    .Parameter StorageAccountName 
     Specifies the name of the Storage account
     
        
    .Parameter ResourceGroupName
     Specifies the name of the resource group
     
    .Parameter ServiceType
     Specifies the Azure Storage service type
     
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Blob','Table','Queue','File')]
    [string]$ServiceType
)

Import-Module Az.Storage

try{
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'ServiceType' = $ServiceType
    }

    $ret = @()
    $null = Get-AzStorageServiceProperty @cmdArgs | Select-Object * | ForEach-Object{
        $ret += [PSCustomObject] @{
            'DefaultServiceVersion' = $_.DefaultServiceVersion
            'StaticWebsite' = $_.StaticWebsite
            'HourMetrics' = (Select-Object -ExpandProperty $_.HourMetrics)            
            'MinuteMetrics' = (Select-Object -ExpandProperty $_.MinuteMetrics)
            'Logging' = (Select-Object -ExpandProperty $_.Logging)
        }
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
