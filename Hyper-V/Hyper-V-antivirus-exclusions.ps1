<#
.SYNOPSIS
A script to add Hyper-V antivirus exclusions.
.DESCRIPTION
A script to add Hyper-V antivirus exclusions. This script can be used for Windows Server 2016, 2019 and 2022
.EXAMPLE
.\Hyper-V-antivirus-exclusions.ps1

.NOTES
The script is required to run with Administrator rights.
Compatible with: Windows Server 2016, Windows Server 2019, Windows Server 2022.
Update the variables with your current settings
#>

#Variables

$vmFolder = "C:\temp\VMs"
$vsmpProcess = "Vmsp.exe"
$vmcomputeProcess = "Vmcompute.exe"

$global:currenttime= Set-PSBreakpoint -Variable currenttime -Mode Read -Action {$global:currenttime= Get-Date -UFormat "%A %m/%d/%Y %R"}
$foregroundColor1 = "Yellow"
$writeEmptyLine = "`n"
$writeSeperatorSpaces = " - "

## Add custom Hyper-V exclusions

Add-MpPreference -ExclusionPath $vmFolder
Add-MpPreference -ExclusionProcess $vsmpProcess
Add-MpPreference -ExclusionProcess $vmcomputeProcess

Write-Host ($writeEmptyLine + "# Custom Hyper-V exclusions added" + $$writeSeperatorSpaces + $currentTime)`
-foregroundcolor $foregroundColor1 $writeEmptyLine