<#
.SYNOPSIS
Activate Virtualization (VTx) on the laptop from OS using HP BIOS Settings Utility.
.DESCRIPTION
This script was inspired from https://www.danielengberg.com/hp-bios-configuration-utility-sccm/ 
.EXAMPLE
Run script.

.NOTES
Name: Activate-BIOS-Virtualization-HP
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

There are some assumptions and prerequisites that need to be in place for this solution to work.

These include:

HP BIOS Configuration Utility
4.0.25.1 or later. The commands have changed between the different versions. Starting with 4.0.21.1, the commands for configuring new passwords and input of the existing passwords has changed from /nspwdfile and /cspwdfile to /npwdfile and /cpwdfile.
A *.bin file containing the encrypted password in your organization.
#>

$Get_BIOS_Settings = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration -ErrorAction SilentlyContinue |  % { New-Object psobject -Property @{    
   Setting = $_."Name"
   Value = $_."currentvalue"
   Available_Values = $_."possiblevalues"
   }}  | select-object Setting, Value, possiblevalues
  $VTx = $Get_BIOS_Settings | where { $_.setting -eq "Virtualization Technology (VTx)" }
  $VTx.value
 
if ($VTx.value -eq "Disable") {Write-Host " VTx it's deactivated, activating now."  -ForegroundColor Red
  C:\Temp\BiosConfigUtility64.exe /CurSetupPasswordFile:”C:\Temp\password.bin” /setvalue:"Virtualization Technology (VTx)","Enable"
  
  Write-Host " VTx is active"  -ForegroundColor Green
  }
else {write-host "VTx is already activated" -ForegroundColor Green }  