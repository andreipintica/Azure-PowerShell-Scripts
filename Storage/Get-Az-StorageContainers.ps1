#
    .SYNOPSIS
        Gets the storage containers
    
    .DESCRIPTION  
        
    .COMPONENT
        Requires Module Az.Storage
    
    .Parameter StorageAccountName 
     Specifies the name of the Storage account to get containers
        
    .Parameter ResourceGroupName
     Specifies the name of the resource group that contains the Storage containers to get
     
    .Parameter Name 
     Specifies the container name

    .Parameter Prefix 
     Specifies a prefix used in the name of the container or containers you want to get. 
     You can use this to find all containers that start with the same string, parameter Name is ignored

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
    [string]$Name,
    [string]$Prefix,
    [int]$MaxCount = 25,
    [ValidateSet('*','Name','LastModified','PublicAccess')]
    [string[]]$Properties = @('Name','LastModified','PublicAccess')
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
                            'MaxCount' = $MaxCount
    }
    if([System.String]::IsNullOrWhiteSpace($Prefix) -eq $false){
        $cmdArgs.Add('Prefix',$Prefix)
    }
    elseif([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
    }
    $ret = Get-AzStorageContainer @cmdArgs | Select-Object $Properties

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
