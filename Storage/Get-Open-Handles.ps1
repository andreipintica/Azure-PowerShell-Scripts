#Connect via PowerShell to Azure account
Connect-AzAccount
#Set Azure Subscription
Select-AzSubscription -subscriptionid "your subscription id"
#create azure storage account context
$Context = New-AzStorageContext -StorageAccountName "storage account name" -StorageAccountKey "your storage account key"
Get-AzStorageFileHandle -Context $Context -ShareName "file share name" -Recursive | Sort-Object ClientIP,OpenTime
#To close the open handles
Close-AzStorageFileHandle -Context $Context -ShareName "file share name" -Path 'path of the file' -CloseAll
