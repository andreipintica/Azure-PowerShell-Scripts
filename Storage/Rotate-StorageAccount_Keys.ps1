#Prefix for resources
$prefix = "prod"

#Basic variables
$id = Get-Random -Minimum 1000 -Maximum 9999

#Log into Azure
Connect-AzAccount

#get list of locations and pick one
Get-AzLocation | Select-Object Location
$location = "westeurope"

#Select the correct subscription
Get-AzSubscription -SubscriptionName "xxxxxxxxxxxxxxxxxxxx" | Select-AzSubscription

#create a resource group
$resourceGroup = "$prefix-rg-$id"
New-AzResourceGroup -Name $resourceGroup -Location $location 

#create a standard general-purpose storage account 
$storageAccountName = "$($prefix)sa$id"
New-AzStorageAccount -ResourceGroupName $resourceGroup `
  -Name $storageAccountName `
  -Location $location `
  -SkuName Standard_LRS `

#retrieve the first storage account key and display it 
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name $storageAccountName).Value[0]

Write-Host "storage account key 1 = " $storageAccountKey

#re-generate the key
New-AzStorageAccountKey -ResourceGroupName $resourceGroup `
    -Name $storageAccountName `
    -KeyName key1

#retrieve it again and display it 
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name $storageAccountName).Value[0]
Write-Host "storage account key 1 = " $storageAccountKey

#Clean Up
Remove-AzResourceGroup -Name $resourceGroup -Force