<#
    .SYNOPSIS
     Lists storage tables
    
    .COMPONENT
     Requires Module Az.Storage
    
    .Parameter StorageAccountName 
     Specifies the name of the Storage account
     
        
    .Parameter ResourceGroupName
     Specifies the name of the resource group
     
    .Parameter Name
     Specifies the table name
     
    .Parameter Prefix 
     Specifies a prefix used in the name of the table or tables
     
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
    [ValidateSet('*','Name','CloudTable','Uri','Context')]
    [string[]]$Properties = @('Name','CloudTable','Uri')
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
    }
    if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
    }
    elseif([System.String]::IsNullOrWhiteSpace($Prefix) -eq $false){
        $cmdArgs.Add('Prefix',$Prefix)
    }
    $ret = Get-AzStorageTable @cmdArgs | Select-Object *

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
