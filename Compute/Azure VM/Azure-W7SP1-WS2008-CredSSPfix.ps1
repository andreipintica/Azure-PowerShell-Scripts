<#
.SYNOPSIS
    Azure Serial Console Script for OS Windows 7 Service Pack 1 / Windows Server 2008 R2 Service Pack 1 CredSSP Fix.
.DESCRIPTION
    Run this azure serial console script for CredSSP Fix.
.NOTES
    Script name: Azure-W7SP1-WS2008-CredSSPfix.sp1
    URL: https://docs.microsoft.com/en-us/troubleshoot/azure/virtual-machines/credssp-encryption-oracle-remediation#remote-powershell-scripts
#>

#Set up your variables:
$subscriptionID = "<your subscription ID>"
$vmname = "<IP of your machine or FQDN>"
$PSPort = "5986" #change this variable if you customize HTTPS on PowerShell to another port


#Log in to your subscription
Add-AzureRmAccount
Select-AzureRmSubscription -SubscriptionID $subscriptionID
Set-AzureRmContext -SubscriptionID $subscriptionID


#Connect to Remote PowerShell
$Skip = New-PSSessionOption -SkipCACheck -SkipCNCheck
Enter-PSSession -ComputerName $vmname -port $PSPort -Credential (Get-Credential) -useSSL -SessionOption $Skip


#Create a download location
md c:\temp


##Download the KB file
$source = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/05/windows6.1-kb4103718-x64_c051268978faef39e21863a95ea2452ecbc0936d.msu"
$destination = "c:\temp\windows6.1-kb4103718-x64_c051268978faef39e21863a95ea2452ecbc0936d.msu"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($source,$destination)


#Install the KB
expand -F:* $destination C:\temp\
dism /ONLINE /add-package /packagepath:"c:\temp\Windows6.1-KB4103718-x64.cab"


#Add the vulnerability key to allow unpatched clients
REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters" /v AllowEncryptionOracle /t REG_DWORD /d 2


#Set up Azure Serial Console flags
cmd
bcdedit /set {bootmgr} displaybootmenu yes
bcdedit /set {bootmgr} timeout 5
bcdedit /set {bootmgr} bootems yes
bcdedit /ems {current} on
bcdedit /emssettings EMSPORT:1 EMSBAUDRATE:115200


#Restart the VM to complete the installations/settings
shutdown /r /t 0 /f
