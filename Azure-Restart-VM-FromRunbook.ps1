<#
.SYNOPSIS
Restart Azure VM from RunBook.
.DESCRIPTION
Restart Azure VM from RunBook.
.EXAMPLE
Run script and edit with corresponding values
.NOTES
Hint: You can run from Azure Cloud shell also with the old syntax at the end 
eg: Get-AzVM -ResourceGroupName $Resource.Name -Name $Resource.Value | Restart-AzureRmVM
Name: Azure-Restart-VM-FromRunbook
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
#>

Param(
[string]$AutomationRG = "Resource Group Name",
[string]$targetVM = "VM Name"
)

$connectionName = "AzureRunAsConnection"
try
{
# Get the connection "AzureRunAsConnection "
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName

"Logging in to Azure..."
Add-AzAccount `
-ServicePrincipal `
-TenantId $servicePrincipalConnection.TenantId `
-ApplicationId $servicePrincipalConnection.ApplicationId `
-CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
}
catch {
if (!$servicePrincipalConnection)
{
$ErrorMessage = "Connection $connectionName not found."
throw $ErrorMessage
} else{
Write-Error -Message $_.Exception
throw $_.Exception
}
}

#Resource Groups and their corresponding VM Names
$Resources = @{$AutomationRG=$targetVM}

#Loop through the hash table and restart each VM
foreach($Resource in $Resources.GetEnumerator())
{
Get-AzVM -ResourceGroupName $Resource.Name -Name $Resource.Value | Restart-AzVM
}