<#
.SYNOPSIS
Get Excell version remote OS Windows 10 Enterprise .
.DESCRIPTION
Get Excell version remote for a specific set of computernames running OS Windows 10 Enterprise from txt file.The txt file must contain only the computernames. 
The computernames result (output) will be exported as a csv file.
.NOTES
Name: Excell_version_OS_W10E
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
#>


Get-ADComputer "C:\Temp\computernames.txt" -Filter * -properties Name,DistinguishedName, DNSHostName, OperatingSystem, Username
foreach ($computer in (Get-Content C:\temp\computernames1.txt)){
 write-verbose "Working on $computer..." -Verbose
 reg query "HKEY_CLASSES_ROOT\Excel.Application\CurVer"
 }
Export-CSV Select-Object Name,DistinguishedName, DNSHostName, OperatingSystem, Username | C:\Temp\exportcomputernames.csv


 
