<#
    .SYNOPSIS
    Gets the storage accounts
    
    .COMPONENT
    Requires Module Az.Storage

    .Parameter Name
     Specifies the name of the Storage account
     
        
    .Parameter ResourceGroupName
    Specifies the name of the resource group that contains the Storage accounts
     
    .Parameter IncludeGeoReplicationStats
    Get the GeoReplicationStats of the Storage account
     
    .Parameter Properties
     List of properties to expand. Use * for all properties
     
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = "ByName")]
    [string]$Name,
    [Parameter(ParameterSetName = "ByResourceGroup")]
    [Parameter(Mandatory = $true,ParameterSetName = "ByName")]
    [string]$ResourceGroupName,
    [Parameter(ParameterSetName = "ByName")]
    [switch]$IncludeGeoReplicationStats,
    [ValidateSet('*','ResourceGroupName','StorageAccountName','Location','StatusOfPrimary','Id','CreationTime','ProvisioningState','PrimaryLocation','EnableHttpsTrafficOnly')]
    [string[]]$Properties = @('ResourceGroupName','StorageAccountName','Location','Id')
)

Import-Module Az.Storage

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    if([System.String]::IsNullOrWhiteSpace($ResourceGroupName) -eq $false){
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
    }
    if($PSCmdlet.ParameterSetName -eq 'ByName'){
        $cmdArgs.Add('Name',$Name)
        $cmdArgs.Add('IncludeGeoReplicationStats',$IncludeGeoReplicationStats)
    }

    $ret = Get-AzStorageAccount @cmdArgs | Select-Object $Properties

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
