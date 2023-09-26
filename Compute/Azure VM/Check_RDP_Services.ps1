<#
.SYNOPSIS
Check Windows services at the guest operating system level using the Run Command command in Azure Portal on the affected virtual machine on which the RDP connection is not working.
.DESCRIPTION
If the Windows Guest Agent is running and working as intended, we can use this powershell script to verify multiple windows services that might affect the RDP.
.NOTES
The script is provided 'as is' and without warranty of any kind. 
Author: Andrei Pintica (@AndreiPintica)
#>

$s1 = Get-Service -Name TermService

$s2 = Get-Service -Name RpcSs

$s3 = Get-Service -Name DcomLaunch

$s4 = Get-Service -Name RpcEptMapper

$s5 = Get-Service -Name Dnscache

$s6 = Get-Service -Name Dhcp

$s7 = Get-Service -Name LSM

$s8 = Get-Service -Name Netlogon

$s9 = Get-Service -Name nsi

$s10 = Get-Service -Name ProfSvc

$s11 = Get-Service -Name LanmanWorkstation

$s12 = Get-Service -Name BFE
$s13 = Get-Service -Name WinHttpAutoProxySvc

$services = $s1,$s2,$s3,$s4,$s5,$s6,$s7,$s8,$s9,$s10,$s11,$s12,$13

foreach($service in $services)

{

Write-Host "The status of Service $($service.DisplayName) is $($service.Status)"

if( $service.Status -ne "Running")

{

Write-Host ""

Write-Host "---Please consider starting service $($service.DisplayName). by running Start-service $($service.Name)"

Write-Host ""

}

}
