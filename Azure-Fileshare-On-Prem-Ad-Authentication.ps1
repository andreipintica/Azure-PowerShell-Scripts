<#
.SYNOPSIS
Activate Virtualization (VTx) on the laptop from OS using HP BIOS Settings Utility.
.DESCRIPTION
This script was inspired from https://adamtheautomator.com/how-to-set-up-an-azure-file-share-with-on-prem-ad-authentication/
.EXAMPLE
Run script.

.NOTES
Name: Azure-FileShare-On-Prem-Ad-Autentication
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

Prerequisites
Be sure you have the following:

An Active Directory domain.
A single Active Directory group and user – This tutorial will use an AD group called demo-group-1 and a user account called demo-user-1 with a password of p@$$w0rd12 to test access to the file share.
A domain-joined Windows 10 PC logged in with a user with permissions to create computer objects.
Windows PowerShell v5.1 or higher. The script will use PowerShell 7.1.
The Az, ActiveDirectory, and AzFilesHybrid PowerShell modules installed. This tutorial will use the following versions:
Az v5.8.0
ActiveDirectory v1.0.1.0
AzFilesHybrid v0.2.3
Authenticated to Azure in PowerShell using the Connect-AzAccount cmdlet.
Related:Connect-AzAccount: Your Gateway to Azure

An Azure AD account with permission to create storage accounts.
An Azure resource group to create demo resources within. The tutorial will use a resource group called AzureFileDemo.
#>

#Creating an Azure File Share

New-AzStorageAccount -ResourceGroupName "AzureFileDemo" -Name "azurefile" -Location "westeurope" -SkuName "Standard_LRS"

New-AzRmStorageShare -ResourceGroupName "AzureFileDemo" -StorageAccountName "azurefile" -Name "azurefileshare"

#Creating the Azure Storage Account Keys

New-AzStorageAccountKey -ResourceGroupName "AzureFileDemo" -Name "azurefile" -KeyName "kerb1"
New-AzStorageAccountKey -ResourceGroupName "AzureFileDemo" -Name "azurefile" -KeyName "kerb2"

#Creating the Active Directory Computer Account

## Find the value of the key you just created by finding all of the storage account keys using Get-AzStorageAccountKey (ListKerbKey) and filter all results for only those matching the key name of kerb1
$Token = (Get-AzStorageAccountKey -ResourceGroupName "ATAAzureFileDemo" -Name "ataazurefile" -ListKerbKey | Where-Object {$_.KeyName -eq "kerb1"}).Value

## Create the AD computer object called ataazurefile assigning the password as the value of the storage account key. The computer account MUST be the exact same name as the storage account.
New-ADComputer -Name "ataazurefile" -AccountPassword (ConvertTo-SecureString -AsPlainText $Token -Force)

#Assigning a CIFS SPN to the Storage Account’s Computer Object

Set-ADComputer -Identity "azurefile$" -ServicePrincipalNames @{Add="cifs/azurefile.file.core.windows.net"}

#Enabling Active Directory Domain Services on the Storage Account

## Find the on-prem AD domain's GUID
$DomainGuid = (Get-ADDomain -Identity "ata_domain").ObjectGuid.Guid
## Find the on-prem AD domain's SID
$DomainSid = (Get-ADDomain -Identity "ata_domain").DomainSID.Value
## Find the storage account's AD computer account's SID
$StorAccountSid = (Get-ADComputer -Identity "ataazurefile").SID.Value

## Provide Set-AzStorageAccount with all appropriate GUIDs and SIDs
## along with the AD domain it should be a part of
$Splat = @{
    ResourceGroupName = "ATAAzureFileDemo"
    Name = "ataazurefile"
    EnableActiveDirectoryDomainServicesForFile = $true
    ActiveDirectoryDomainName = "ata_domain.local"
    ActiveDirectoryNetBiosDomainName = "ata_domain"
    ActiveDirectoryForestName = "ata_domain"
    ActiveDirectoryDomainGuid = $DomainGuid
    ActiveDirectoryDomainsid = $DomainSid
    ActiveDirectoryAzureStorageSid = $StorAccountSid
}
Set-AzStorageAccount @Splat

#Mounting the Azure File Share

$Key = (Get-AzStorageAccountKey -ResourceGroupName "AzureFileDemo" -Name "azurefile" | Where-Object {$_.KeyName -eq "key1"}).Value

#Run the net use command to mount the share to a drive letter in Windows. The command below mounts an Azure file share called azurefileshare hosted on the azurefile storage account authenticating as the AD computer account azurefile using the storage account key.

net use S: \\azurefile.file.core.windows.net\azurefileshare /user:azure_demo\azurefile $Key

#Configuring Share Permissions

## Find the AD group you'd like to assign the role
$AdGroup = Get-AzADGroup -DisplayName "demo-group-1"
## Find the Azure role definition you'd like to assign to the share
$AzRole = Get-AzRoleDefinition -Name "Storage File Data SMB Share Contributor"
## Find the storage account's ID
$StorAccId = (Get-AzStorageAccount -ResourceGroupName "AzureFileDemo" -StorageAccountName "azurefile").Id

## Assign the AD group to the role limiting the scope to the storage account
New-AzRoleAssignment -ObjectId $AdGroup.Id -RoleDefinitionName $AzRole.Name -Scope $StorAccId

#You can now mount the share using the AD credentials of the test user using the net use command.

net use S: \\azurefile.file.core.windows.net\azurefileshare /user:azure_demo\\demo-user-1 p@$$w0rd12

#Optional: Renewing the Computer Account Password

#The command below first rotates the AD computer object password to the kerb2 Kerberos token you created earlier. It then regenerates the kerb1 token and rotates the AD computer object again to this new token. This action avoids any potential loss of service whilst the kerb1 token is renewed.

$Splat = @{
    RotateToKerbKey = "kerb2"
    ResourceGroupName = "AzureFileDemo"
    StorageAccountName = "azurefile"
}

Update-AzStorageAccountADObjectPassword @Splat

#Using the command above, you could then create a PowerShell foreach loop to find all Azure storage accounts with AD Domain services enabled on them and update the password for all via the PowerShell script below.

## Find all storage accounts in the subscription that have AD Domain
## services enabled
$AdStrAccs = Get-AzStorageAccount | Where-Object {$_.AzureFilesIdentityBasedAuth.DirectoryServiceOptions -eq "AD"}

## Process each storage account found and update their password with the storage
## account key (kerb2) created earlier.
foreach ($StrAcc in $AdStrAccs) {
    $Splat = @{
        RotateToKerbKey = "kerb2"
        ResourceGroupName = $StrAcc.ResourceGroupName
        StorageAccountName = $StrAcc.StorageAccountName
    }

    Update-AzStorageAccountADObjectPassword @Splat

