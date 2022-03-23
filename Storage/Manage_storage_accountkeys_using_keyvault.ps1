#Prefix for resources
$prefix = "prod"

#Basic variables
$location = "westeurope"
$id = Get-Random -Minimum 1000 -Maximum 9999

#Log into Azure
Connect-AzAccount

#Select the correct subscription
Get-AzSubscription

Get-AzSubscription -SubscriptionName "xxxxxxxxx" | Select-AzSubscription

Get-AzContext

#Create a resource group for Key Vault
$keyVaultGroup = New-AzResourceGroup -Name "$prefix-key-vault-$id" -Location $location

#Create a new Key Vault
$keyVaultParameters = @{
    Name = "$prefix-key-vault-$id"
    ResourceGroupName = $keyVaultGroup.ResourceGroupName
    Location = $location
    Sku = "Premium"
}

$keyVault = New-AzKeyVault @keyVaultParameters

#Grant yourself access to the Key Vault (if you are a Guest user)
#Give your user principal access to all storage account permissions, on your Key Vault instance
$accessPolicy = @{
    VaultName = $keyVault.Name
    UserPrincipalName = "andrei.pintica@gmail.com"
    PermissionsToStorage = ("get","list","listsas","delete","set","update","regeneratekey","recover","backup","restore","purge")
}

Set-AzKeyVaultAccessPolicy @accessPolicy

$keyVault | Format-List

#Create a new storage account
$saAccountParameters = @{
    Name = "$($prefix)sa$id"
    ResourceGroupName = $keyVaultGroup.ResourceGroupName
    Location = $location
    SkuName = "Standard_LRS"
}

$storageAccount = New-AzStorageAccount @saAccountParameters

Get-AzStorageAccountKey -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName

$keyVaultSpAppId = "xxxxxxxxxxxxxxxxxxxxxxx"

New-AzRoleAssignment -ApplicationId $keyVaultSpAppId -RoleDefinitionName 'Storage Account Key Operator Service Role' -Scope $storageAccount.Id

# Add your storage account to your Key Vault's managed storage accounts
$managedStorageAccount = @{
    VaultName = $keyVault.VaultName
    AccountName = $storageAccount.StorageAccountName
    AccountResourceId = $storageAccount.Id
    ActiveKeyName = "key1"
    RegenerationPeriod = [System.Timespan]::FromDays(90)
}

Add-AzKeyVaultManagedStorageAccount @managedStorageAccount

Get-AzKeyVaultManagedStorageAccount -VaultName $keyVault.VaultName

Update-AzKeyVaultManagedStorageAccountKey -VaultName $keyVault.VaultName -AccountName $storageAccount.StorageAccountName -KeyName "key1"

#Clean Up
Remove-AzResourceGroup -Name tw-key-vault-9490 -Force