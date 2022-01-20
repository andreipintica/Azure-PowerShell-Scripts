<#
.SYNOPSIS
    Azure Serial Console Script for OS RS3 - Windows 10 version 1709 / Windows Server 2016 version 1709 CredSSP Fix.
.DESCRIPTION
    Run this azure serial console script for CredSSP Fix.
.NOTES
    Script name: Azure-W10.1709-WS2016.1709-CredSSPfix.ps1
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
$source = "http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/05/windows10.0-kb4103727-x64_c217e7d5e2efdf9ff8446871e509e96fdbb8cb99.msu"
$destination = "c:\temp\windows10.0-kb4103727-x64_c217e7d5e2efdf9ff8446871e509e96fdbb8cb99.msu"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($source,$destination)


#Install the KB
expand -F:* $destination C:\temp\
dism /ONLINE /add-package /packagepath:"c:\temp\Windows10.0-KB4103727-x64.cab"


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
