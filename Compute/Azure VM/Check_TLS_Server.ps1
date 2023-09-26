<#
.SYNOPSIS
Check the TLS version using Run Command from Azure Portal on the affected virtual machine.
.DESCRIPTION
If the Windows Guest Agent is running and working as intended, we can use this powershell script to verify the TLS settings and the .NET Framework version for WinRM.
.NOTES
The script is provided 'as is' and without warranty of any kind. 
TLS 1.3 is only supported in Windows Server 2022 and later.
Author: Andrei Pintica (@AndreiPintica)
#>

        Function Get-RegValue {
    [CmdletBinding()]
    Param
    (
        # Registry Path
        [Parameter(Mandatory = $true,
            Position = 0)]
        [string]
        $RegPath,

        # Registry Name
        [Parameter(Mandatory = $true,
            Position = 1)]
        [string]
        $RegName
    )
    $regItem = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Ignore
    $output = "" | select Path, Name, Value
    $output.Path = $RegPath
    $output.Name = $RegName

    If ($regItem -eq $null) {
        $output.Value = "Not Found"
    }
    Else {
        $output.Value = $regItem.$RegName
    }
    $output
}

$regSettings = @()
$regKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server'
$regSettings += Get-RegValue $regKey 'Enabled'
$regSettings += Get-RegValue $regKey 'DisabledByDefault'
$regKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
$regSettings += Get-RegValue $regKey 'Enabled'
$regSettings += Get-RegValue $regKey 'DisabledByDefault'
$regKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server'
$regSettings += Get-RegValue $regKey 'Enabled'
$regSettings += Get-RegValue $regKey 'DisabledByDefault'
$regKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server'
$regSettings += Get-RegValue $regKey 'Enabled'
$regSettings += Get-RegValue $regKey 'DisabledByDefault'
$regSettings 
