<#
.SYNOPSIS
A script used to set customized server settings on Azure Windows VMs running Windows Server 2016, Windows Server 2019 or Windows Server 2022.
.DESCRIPTION
A script used to set customized server settings on Azure Windows VMs running Windows Server 2016, Windows Server 2019 or Windows Server 2022.
This script will do all of the following:
Check if the PowerShell window is running as Administrator (which is a requirement), otherwise the PowerShell script will be exited.
Allow ICMP (ping) through Windows Firewall for IPv4 and IPv6.
Enable Remote Desktop (RDP) and enable Windows Firewall rule.
Enable secure RDP authentication Network Level Authentication (NLA).
Enable Remote Management (for RSAT tools and Windows Admin Center) and enable Windows Firewall rules.
Enable User Account Control (UAC).
Disable RDP printer mapping.
Disable IE security for Administrators.
Disable Windows Admin Center pop-up.
Disable Server Manager at logon.
Disable guest account.
Disable Hibernation.
Set Windows Diagnostic level (Telemetry) to Security (no Windows diagnostic data will be sent).
Set Folder Options.
Set volume label of C: to OS.
Set Time Zone (UTC+01:00).
Set Power Management to High Performance, if it is not currently the active plan.
Set the Interactive Login to "Do not display the last username".
Set language to En-US and keyboard to Belgian (Period).
Create the C:\Temp folder, if it does not exist.
Remove description of the Local Administrator Account.
Restart the server to apply all changes, five seconds after running the last command.
.NOTES
Disclaimer:     This script is provided "As Is" with no warranties.
.EXAMPLE
.\Set-Customized-Server-Settings-Azure-IaaS-Windows-Server-2016-2019-2022.ps1
.LINK
#>

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Variables

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$allowIcmpV4FirewallRuleName = "Allow_Ping_ICMPv4" # ICMPv4 Firewall Rule Name
$allowIcmpV4FirewallRuleDisplayName = "Allow Ping ICMPv4" # ICMPv4 Firewall Rule Display Name
$allowIcmpV4FirewallRuleDescription = "Packet Internet Groper ICMPv4"
$allowIcmpV6FirewallRuleName = "Allow_Ping_ICMPv6" # ICMPv6 Firewall Rule Name
$allowIcmpV6FirewallRuleDisplayName = "Allow Ping ICMPv6" # ICMPv6 Firewall Rule Display Name
$allowIcmpV6FirewallRuleDescription = "Packet Internet Groper ICMPv6"
$allowRdpDisplayName = "Remote Desktop*"
$rdpRegKeyPath = "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$rdpRegKeyName = "UserAuthentication"
$wmiFirewallRuleDisplayGroup = "Windows Management Instrumentation (WMI)"
$remoteEventLogFirewallRuleDisplayGroup = "Remote Event Log Management"
$uacRegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$uacRegKeyName = "EnableLUA"
$rdpPrinterMappingRegKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$rdpPrinterMappingRegKeyName = "fDisableCpm"
$adminIESecurityRegKeyPath = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$adminIESecurityRegKeyName = "IsInstalled"
$serverManagerRegKeyPath = "HKLM:\SOFTWARE\Microsoft\ServerManager"
$wacPopPupKeyName = "DoNotPopWACConsoleAtSMLaunch"
$scheduledTaskNameServerManager = "ServerManager"
$windowsDiagnosticLevelRegKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$windowsDiagnosticLevelRegKeyName = "AllowTelemetry"
$interActiveLogonRegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$interActiveLogonRegKeyName = "DontDisplayLastUsername"
$folderOptionsRegKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" # Per-User
$folderOptionsHiddenRegKeyName = "Hidden"
$folderOptionsHideFileExtRegKeyName = "HideFileExt" 
$folderOptionsShowSuperHiddenRegKeyName = "ShowSuperHidden" 
$folderOptionsHideDrivesWithNoMediaRegKeyName = "HideDrivesWithNoMedia" 
$folderOptionsSeperateProcessRegKeyName = "SeperateProcess" 
$folderOptionsAlwaysShowMenusRegKeyName = "AlwaysShowMenus" 
$windowsExplorerProcessName = "explorer"
$cDriveLabel = "OS" # Volume label of C:
$timezone = "Romance Standard Time" # Time zone
$powerManagement = "High performance"
$currentLangAndKeyboard = (Get-WinUserLanguageList).InputMethodTips
$keyboardInputMethod = "0409:00000813" # Belgian Period
$tempFolder = "C:\Temp" # Temp folder name
$administratorName = $env:UserName

$writeEmptyLine = "`n"
$writeSeperatorSpaces = " - "
$global:currenttime = Set-PSBreakpoint -Variable currenttime -Mode Read -Action {$global:currenttime= Get-Date -UFormat "%A %m/%d/%Y %R"}
$foregroundColor1 = "Red"
$foregroundColor2 = "Yellow"

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Check if PowerShell runs as Administrator, otherwise exit the script

if ($isAdministrator -eq $false) {
        # Check if running as Administrator, otherwise exit the script
        Write-Host ($writeEmptyLine + "# Please run PowerShell as Administrator" + $writeSeperatorSpaces + $currentTime)`
        -foregroundcolor $foregroundColor1 $writeEmptyLine
        Start-Sleep -s 3
        exit
} else {
        # If running as Administrator, start script execution    
        Write-Host ($writeEmptyLine + "# Script started. Without any errors, it will need around 2 minutes to complete" + $writeSeperatorSpaces + $currentTime)`
        -foregroundcolor $foregroundColor1 $writeEmptyLine 
}

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Allow ICMP (ping) through Windows Firewall for IPv4 and IPv6

# Allow ICMP IPv4
try {
    Get-NetFirewallRule -Name $allowIcmpV4FirewallRuleName -ErrorAction Stop | Out-Null
} catch {
    New-NetFirewallRule -Name $allowIcmpV4FirewallRuleName -DisplayName $allowIcmpV4FirewallRuleDisplayName -Description $allowIcmpV4FirewallRuleDescription -Protocol ICMPv4 -IcmpType 8 `
    -Enabled True -Profile Any -Action Allow | Out-Null
}

# Allow ICMP IPv6
try {
    Get-NetFirewallRule -Name $allowIcmpV6FirewallRuleName -ErrorAction Stop | Out-Null
} catch {
    New-NetFirewallRule -Name $allowIcmpV6FirewallRuleName -DisplayName $allowIcmpV6FirewallRuleDisplayName -Description $allowIcmpV6FirewallRuleDescription -Protocol ICMPv6 -IcmpType 8 `
    -Enabled True -Profile Any -Action Allow | Out-Null
}

Write-Host ($writeEmptyLine + "# ICMP allowed trough Windows Firewall for IPv4 and IPv6" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Enable Remote Desktop (RDP) and enable Windows Firewall rule

Import-Module NetSecurity
(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1) | Out-Null
(Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null

# Enable firewall rule for RDP 
try {
    Get-NetFirewallRule -DisplayName $allowRdpDisplayName -Enabled true -ErrorAction Stop | Out-Null
} catch {
    Set-NetFirewallRule -DisplayName $allowRdpDisplayName -Enabled true -PassThru | Out-Null
}

Write-Host ($writeEmptyLine + "# Remote Desktop enabled" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine 

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Enable secure RDP authentication Network Level Authentication (NLA)

Set-ItemProperty -Path $rdpRegKeyPath -name $rdpRegKeyName -Value 1 | Out-Null

Write-Host ($writeEmptyLine + "# Secure RDP authentication Network Level Authentication enabled" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Enable Remote Management (for RSAT tools and Windows Admin Center) and enable Windows Firewall rules

# Enable WinRM
Enable-PSRemoting -Force | Out-Null

# Enable remote authentication acceptance
Enable-WSManCredSSP -Role server -Force | Out-Null

# Enable firewall rules for remote management
try {
    Get-NetFirewallRule -DisplayGroup $wmiFirewallRuleDisplayGroup -Enabled true -ErrorAction Stop | Out-Null
} catch {
    Set-NetFirewallRule -DisplayGroup $wmiFirewallRuleDisplayGroup -Enabled true -PassThru | Out-Null
}

try {
    Get-NetFirewallRule -DisplayGroup $remoteEventLogFirewallRuleDisplayGroup -Enabled true -ErrorAction Stop | Out-Null
} catch {
    Set-NetFirewallRule -DisplayGroup $remoteEventLogFirewallRuleDisplayGroup -Enabled true -PassThru | Out-Null
}

Write-Host ($writeEmptyLine + "# Remote Management enabled" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Enable User Account Control (UAC)

Set-ItemProperty -Path $uacRegKeyPath -Name $uacRegKeyName -Value 1 -Type DWord | Out-Null

 Write-Host ($writeEmptyLine + "# User Access Control (UAC) enabled" + $writeSeperatorSpaces + $currentTime)`
 -foregroundcolor $foregroundColor2 $writeEmptyLine
 
## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable RDP printer mapping

Set-ItemProperty -Path $rdpPrinterMappingRegKeyPath -Name $rdpPrinterMappingRegKeyName -Value 1 | Out-Null

Write-Host ($writeEmptyLine + "# RDP printer mapping disabled" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable IE security for Administrators

Set-ItemProperty -Path $adminIESecurityRegKeyPath -Name $adminIESecurityRegKeyName -Value 0 | Out-Null

# Stop and start Windows explorer process
Stop-Process -Name $windowsExplorerProcessName | Out-Null

Write-Host ($writeEmptyLine + "# IE Enhanced Security Configuration for the Administrator disabled" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable Windows Admin Center pop-up

Set-ItemProperty -Path $serverManagerRegKeyPath -Name $wacPopPupKeyName -Value 1 | Out-Null

Write-Host ($writeEmptyLine + "# Windows Admin Center pop-up is disabled" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable Server Manager at logon

Get-ScheduledTask -TaskName $scheduledTaskNameServerManager | Disable-ScheduledTask | Out-Null

Write-Host ($writeEmptyLine + "# Server Manager disabled at startup" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable guest account

net user guest /active:no | Out-Null

Write-Host ($writeEmptyLine + "# Guest account disabled" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Disable Hibernation

powercfg.exe /h off

Write-Host ($writeEmptyLine + "# Hibernation disabled" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set Windows Diagnostic level (Telemetry) to Security (no Windows diagnostic data will be sent)

New-ItemProperty -Path $windowsDiagnosticLevelRegKeyPath -Name $windowsDiagnosticLevelRegKeyName -PropertyType "DWord" -Value 0 -Force | Out-Null

Write-Host ($writeEmptyLine + "# Windows Diagnostic level (Telemetry) set to Security" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set the Interactive Login to "Do not display the last username"

Set-ItemProperty -Path $interActiveLogonRegKeyPath -Name $interActiveLogonRegKeyName -Value 1 | Out-Null

Write-Host ($writeEmptyLine + "# Interactive Login set to - Do not display last user name" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set Folder Options

Set-ItemProperty -Path $folderOptionsRegKeyPath -Name  $folderOptionsHiddenRegKeyName -Value 1 | Out-Null
Set-ItemProperty -Path $folderOptionsRegKeyPath -Name  $folderOptionsHideFileExtRegKeyName -Value 0 | Out-Null
Set-ItemProperty -Path $folderOptionsRegKeyPath -Name $folderOptionsShowSuperHiddenRegKeyName -Value 0 | Out-Null
Set-ItemProperty -Path $folderOptionsRegKeyPath -Name $folderOptionsHideDrivesWithNoMediaRegKeyName -Value 0 | Out-Null
Set-ItemProperty -Path $folderOptionsRegKeyPath -Name $folderOptionsSeperateProcessRegKeyName -Value 1 | Out-Null
Set-ItemProperty -Path $folderOptionsRegKeyPath -Name $folderOptionsAlwaysShowMenusRegKeyName -Value 1 | Out-Null

# Stop and start Windows explorer process
Stop-Process -processname $windowsExplorerProcessName -Force | Out-Null

Write-Host ($writeEmptyLine + "# Folder Options set" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set volume label of C: to OS

$drive = Get-WmiObject win32_volume -Filter "DriveLetter = 'C:'"
$drive.Label = $cDriveLabel
$drive.put() | Out-Null

Write-Host ($writeEmptyLine + "# Volumelabel of C: set to $cDriveLabel" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set Time Zone (UTC+01:00)

Set-TimeZone -Name $timezone

Write-Host ($writeEmptyLine + "# Timezone set to $timezone" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set Power Management to High Performance, if it is not currently the active plan

try {
    $highPerf = powercfg -l | ForEach-Object {if($_.contains($powerManagement)) {$_.split()[3]}}
    $currPlan = $(powercfg -getactivescheme).split()[3]
    if ($currPlan -ne $highPerf) {powercfg -setactive $highPerf}
    Write-Host ($writeEmptyLine + "# Power Management set to $powerManagement" + $writeSeperatorSpaces + $currentTime)`
    -foregroundcolor $foregroundColor2 $writeEmptyLine
} catch {
    Write-Warning -Message ($writeEmptyLine + "# Unable to set power plan to $powerManagement" + $writeSeperatorSpaces + $currentTime)`
    -foregroundcolor $foregroundColor1 $writeEmptyLine
}

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Set language to En-US and keyboard to Belgian (Period)

if ($currentLangAndKeyboard -eq "0409:00000409") {
        $langList = New-WinUserLanguageList en-US
        $langList[0].InputMethodTips.Clear()
        $langList[0].InputMethodTips.Add($keyboardInputMethod) 
        Set-WinUserLanguageList $langList -Force
        Write-Host ($writeEmptyLine + "# Keybord set to Belgian Period" + $writeSeperatorSpaces + $currentTime)`
        -foregroundcolor $foregroundColor2 $writeEmptyLine
} else {
	    Write-Host ($writeEmptyLine + "# Keybord all ready set to Belgian Period" + $writeSeperatorSpaces + $currentTime)`
        -foregroundcolor $foregroundColor2 $writeEmptyLine
}

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Create the C:\Temp folder, if it does not exist.

if (!(test-path $tempFolder))
{
New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null
}

Write-Host ($writeEmptyLine + "# $tempFolder folder available" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Remove description of the Local Administrator Account

Set-LocalUser -Name $administratorName -Description ""

Write-Host ($writeEmptyLine + "# Description removed from Local Administrator Account" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor2 $writeEmptyLine

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Restart server to apply all changes, five seconds after running the last command

Write-Host ($writeEmptyLine + "# This server will restart to apply all changes" + $writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine

Start-Sleep -s 5
Restart-Computer -ComputerName localhost

## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
