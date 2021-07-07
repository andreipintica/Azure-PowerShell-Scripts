<#
.SYNOPSIS
Verify remote the users added in the Administrators group.
.DESCRIPTION
This script will display the users from the local Administrators group.
.NOTES
Name: verify-admin-remote
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

The computername must be joined in the domain.
#>

invoke-command {
$members = net localgroup administrators | 
 where {$_ -AND $_ -notmatch "command completed successfully"} | 
 select -skip 4
New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = "Administrators"
 Members=$members
 }
} -computer  W10-Workstation -HideComputerName | 
Select * -ExcludeProperty RunspaceID