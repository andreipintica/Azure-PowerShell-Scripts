<#
.SYNOPSIS
Filter Windows 10 clients for specific OS Version.
.DESCRIPTION
Filter Windows 10 clients for specific OS Version.
.EXAMPLE
Run script.

.NOTES
Name: w10version
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
#>

Get-ADComputer -filter {operatingsystem -like "Windows 10*" -and OperatingSystemVersion -like '*1809*' } -Properties OperatingSystemVersion|select name,OperatingSystemVersion