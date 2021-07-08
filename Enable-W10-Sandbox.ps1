<#
.SYNOPSIS
Activate Virtualization (VTx) on the laptop from OS using HP BIOS Settings Utility.
.DESCRIPTION
This script was inspired from https://www.danielengberg.com/hp-bios-configuration-utility-sccm/ 
.EXAMPLE
1. Open PowerShell as an administrator.
2. Run the script.

.NOTES
Name: Enable-W10-Sandbox
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
#>

Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online
