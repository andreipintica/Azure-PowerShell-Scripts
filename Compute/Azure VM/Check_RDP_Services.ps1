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

$services = $s1,$s2,$s3,$s4,$s5,$s6,$s7,$s8,$s9,$s10,$s11

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
