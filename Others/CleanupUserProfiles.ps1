<#
.SYNOPSIS
 Cleanup User Profiles from Windows OS.
    
.Description
 Useful for terminal servers with lots of users. Removes all files and folders from the listed entires for all user profiles. It will try to detect the correct path, or if you have multiple paths, has an override parameter.
.PARAMETER Path
 The paths are already defined with default paths. If you want, you can edit/add/remove a new path.
.Notes
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
#>

Param
(
    [string]$ProfileLocation
)

Clear-Host
Write-Host 'Getting User List ...... ' -NoNewline
If ([string]::IsNullOrEmpty($ProfileLocation) -eq $false)
{
    [string]$profilePath = $ProfileLocation
}
Else
{
    [string]$profilePath = (Split-Path -Parent $env:USERPROFILE)
}

[array] $users       = Get-ChildItem -Path   $profilePath
[array] $paths       = (
                        '\AppData\Local\Microsoft\Edge\User Data\Service Worker',
                        '\AppData\Local\Microsoft\Windows\Temporary Internet Files',
                        '\AppData\Local\Microsoft\Windows\WebCache',
                        '\AppData\Local\Microsoft\Windows\WER',
                        '\AppData\Local\Microsoft\Internet Explorer\Recovery',
                        '\AppData\Local\Microsoft\Terminal Server Client\Cache',
                        '\AppData\Local\KVS\Enterprise Vault',
                        '\AppData\Local\CrashDumps',
                        '\AppData\Local\Temp',
                        '\AppData\LocalLow\Sun\Java\Deployment\cache\6.0',
                        '\AppData\Local\Microsoft\Microsoft.EnterpriseManagement.Monitoring.Console',
                        '\AppData\Roaming\Code\Cache',
                        '\AppData\Roaming\Code\CachedData',
                        '\AppData\Roaming\Code\Code Cache',
                        '\AppData\Roaming\Code\logs',
                        '\AppData\Roaming\Default\Service Worker',
                        '\AppData\Roaming\Default\Cache',
                        '\AppData\Roaming\Default\Code Cache'
                       )
Write-Host ' Complete'
Write-Host 'Scanning User Folders... ' -NoNewline
[double]$before = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$($profilePath.SubString(0,2))'" | Select -ExpandProperty FreeSpace

[int]$iCnt      = 0
[int]$UserCount = $users.Count

ForEach ($user In $users)
{
    Write-Progress -Activity 'Scanning User Folders' -Status ($user.Name).ToUpper() -PercentComplete (($iCnt / $UserCount) * 100)
    ForEach ($path In $paths)
    {
        If ((Test-Path -Path "$profilePath\$user\$path") -eq $true)
        {
            Get-ChildItem -Path "$profilePath\$user\$path" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    $iCnt++
}
Write-Host ' Complete'
[double]$after = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$($profilePath.SubString(0,2))'" | Select -ExpandProperty FreeSpace

Write-Output "".PadLeft(80, '-')
Write-Output "Before     : $( ($before           / 1GB).ToString('0.00')) GB"
Write-Output "After      : $( ($after            / 1GB).ToString('0.00')) GB"
Write-Output "Difference : $((($after - $before) / 1MB).ToString('0.00')) MB"
Write-Output "".PadLeft(80, '-')
