<#
.SYNOPSIS
    Azure Serial Console Script for OS Windows Server 2012 CredSSP Fix.
.DESCRIPTION
    Run this azure serial console script for CredSSP Fix.
.NOTES
    Script name: Azure-WS2012CredSSPfix.ps1
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
$source = "http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/04/windows8-rt-kb4103730-x64_1f4ed396b8c411df9df1e6755da273525632e210.msu"
$destination = "c:\temp\windows8-rt-kb4103730-x64_1f4ed396b8c411df9df1e6755da273525632e210.msu"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($source,$destination)


#Install the KB
expand -F:* $destination C:\temp\
dism /ONLINE /add-package /packagepath:"c:\temp\Windows8-RT-KB4103730-x64.cab"


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
