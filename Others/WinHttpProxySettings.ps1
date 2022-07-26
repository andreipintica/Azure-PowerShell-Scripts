
<#
.SYNOPSIS
Gets configuration for the WinHTTP proxy
.DESCRIPTION
The Get-WinHttpProxySettings cmdlet outputs the configuration of the
WinHTTP proxy. It detects whether the computer is setup for a per-machine
or a per-user setup.
.PARAMETER Context
LocalMachine or CurrentUser. Without this parameter, the cmdlet checks the
computer configuration to determine which one to output.
.EXAMPLE
Get-WinHttpProxySettings -Context LocalMachine
Outputs the local machine configuration, even if the computer is setup to
use the user one.
.INPUTS
None. You cannot pipe anything to ths cmdlet.
.OUTPUTS
WinHttpProxySettings. A PSCustomObject with the following fields:
Version: the version of the WinHttpSettings object
Counter: increased every time the object is modified
ConfigFlags: which settings to use. Cf; Set-WinHttpProxySettings
Proxy: the proxy to use, in the form 'name:port'
Bypass: a semicolon-separated list of host bypassing the proxy
AutoConfig: the address of a .Pac file.
ProxySettingsPerUser: true if the user settings are used.
Context: origin (LocalMachine,CurrentUser) of the record.
.COMPONENT 
ProxySettingsPerUser = 0

uses no proxy
netsh reset => resets LM,LM32
netsh set => sets LM,LM32, removes CU INext proxy
ProxySettingsPerUser = 1

uses CU proxy
netsh reset => resets LM,LM32
netsh set => sets LM,LM32
ProxySettingsPerUser = 2

uses CU proxy
netsh reset => resets LM,LM32, copy CU INext proxy > CU proxy
netsh set => sets LM,LM32
Change CU proxy => sets CU INet proxy
.NOTES
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

Documentation
https://docs.microsoft.com/en-us/sysinternals/downloads/procmon
https://securelink.be/blog/windows-proxy-settings-explained/
https://docs.microsoft.com/en-us/windows/desktop/api/Winhttp/ns-winhttp-__unnamed_struct_3
https://github.com/vbfox/proxyconf/blob/master/README.md
https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/managing-bit-flags-part-1
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_enum
#>


function Get-WinHttpProxySettings {
    param(
        [ValidateSet('LocalMachine', 'CurrentUser', 'LocalMachineWoW64')]
        [string[]]$Context
    )

    #Region Declarations
    [flags()]
    enum winhttpflags {
        None = 0
        alwayson = 1  # this flag is always on. it will be removed for display
        manual = 2    # uses the 'proxy' field
        auto = 4      # uses the 'autoconfig' field
        detect = 8    # uses proxy auto-discovering protocol
    }
    
    $RegLocations = @{
        ProxySettingsPerUser = @{
            Path = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings'
            Name = 'ProxySettingsPerUser'
        }
        CurrentUser          = @{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
            Name = 'DefaultConnectionSettings'
        }
        LocalMachine         = @{
            Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
            Name = 'WinHttpSettings'
        }
        LocalMachineWoW64    = @{
            Path = 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
            Name = 'WinHttpSettings'
        }
    }

    function _idx($inc = 4, $ind = [ref]$idx) {
        # INTERNAL: outputs current index value and increases it
        $ind.Value
        $ind.Value += $inc
    }

    function _decodeString([int]$Start, [byte[]]$ByteArray, [System.Text.Encoding]$Encoding = [System.Text.Encoding]::ASCII) {
        # INTERNAL: decodes a byte array
        $enc = $Encoding
        $strLen = $ByteArray[$Start]
        $str_ba = $ByteArray[($Start + 4) ..($Start + 4 - 1 + $strLen)]
        $enc.GetString($str_ba)
        _idx $strLen | Out-Null
    }

    if ( -not ( Get-TypeData -TypeName WinHttpProxySettings)) {
        Update-TypeData -TypeName WinHttpProxySettings -DefaultDisplayPropertySet ConfigFlags, Proxy, ByPass, AutoConfig
    }
    #EndRegion Declarations

    try {
        $SettingsLocation = $RegLocations['ProxySettingsPerUser']
        $ProxySettingsPerUser = ( Get-ItemPropertyValue @SettingsLocation ) -ne 0
    }
    catch { $ProxySettingsPerUser = $true}

    if ( -not $PSBoundParameters.Context) {
        if ($ProxySettingsPerUser) {
            $Context = 'CurrentUser'
        }
        else {
            $Context = 'LocalMachine'
        }
    }

    foreach ($ctx in $Context) {
        $idx = 0

        try {
            $SettingsLocation = $RegLocations[$ctx]
            $RawConfig = Get-ItemPropertyValue @SettingsLocation -ErrorAction Stop
        }
        catch {
            $RawConfig = 18, 00, 00, 00, 00, 00, 00, 00, 01, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
        }
        $Config = @{
            PSTypeName           = 'WinHttpProxySettings'
            Version              = $RawConfig[(_idx)]
            Counter              = $RawConfig[(_idx)]
            ConfigFlags          = [winhttpflags]($RawConfig[(_idx)] - 1) # we remove 1 because we don't want to display the "stuck bit"
            Proxy                = _decodeString (_idx) $RawConfig
            Bypass               = _decodeString (_idx) $RawConfig
            AutoConfig           = _decodeString (_idx) $RawConfig
            ProxySettingsPerUser = $ProxySettingsPerUser
            Context              = $ctx
        }

        [PSCustomObject]$Config
    }
}


<#
.SYNOPSIS
Sets WinHTTP proxy settings
.DESCRIPTION
The Set-WinHttpProxySettings cmdlet is a replacement for netsh winhttp set
proxy, with the added option of setting the autoconfig filed (normally only
set when copying the WinINet settings)
.PARAMETER Context
LocalMachine or CurrentUser. Without this parameter, the cmdlet checks the
computer configuration to determine which one to mmodify.
.PARAMETER ConfigFlags
Can be one or a set from manual, autoconfig and detect.
Manual: uses the Proxy field.
Autoconfig: Uses the autoconfig field.
AutoDetect: uses the proxy discovery protocol.
.PARAMETER Proxy
The proxy to set-up
.PARAMETER Bypass
A semicolon-separated list of hosts that will not use the proxy. You can
use '<LOCAL>' for all local addresses.
.PARAMETER AutoConfig
The address of a PAC file.
.PARAMETER Version
The version of the WinHttpSettings record. Internal.
.PARAMETER PassThru
If set, returns the options just set.
.EXAMPLE
Set-WinHttpProxySettings -Proxy proxy:8080 -Bypass '<local>' -ConfigFlags manual
 Sets the proxy for all calls, but the ones to the local addresses.
.EXAMPLE
Set-WinHttpProxySettings -Proxy 'proxy:8080' -Bypass '<local>;local.intra' -AutoConfig 'http://proxy/proxy.pac' -ConfigFlags manual,detect,autoconfig
Sets the proxy for all connections, but the ones to the local addresses and to
office.intra, adds a pac configuration, sets the flags so that it tries both a .pac
resolution for the proxy, a direct connection to Proxy:8080, and falls back to
trying to autodetect the proxy.
.NOTES
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
    #>
    function Set-WinHttpProxySettings {
    param(
        [ValidateSet('LocalMachine', 'CurrentUser', 'LocalMachineWoW64')]
        [string]$Context,
        [ValidateSet('manual', 'auto', 'detect')]
        [string[]]$ConfigFlags,

        [parameter(position = 0)]
        [string]$Proxy,
        [parameter(position = 1)]
        [string]$Bypass,
        [parameter(position = 2)]
        [string]$AutoConfig,
        [ValidateSet(0x28, 0x3c, 0x46)]
        [int32]$Version = 0x46,
        [switch]$PassThru
    )

    #Region Declarations
    [flags()]
    enum winhttpflags {
        None = 0
        alwayson = 1
        manual = 2
        auto = 4
        detect = 8
    }

    $RegLocations = @{
        ProxySettingsPerUser = @{
            Path = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings'
            Name = 'ProxySettingsPerUser'
        }
        CurrentUser          = @{
            Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
            Name = 'DefaultConnectionSettings'
        }
        LocalMachine         = @{
            Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
            Name = 'WinHttpSettings'
        }
        LocalMachineWoW64    = @{
            Path = 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
            Name = 'WinHttpSettings'
        }
    }
    #EndRegion Declarations

    try {
        $SettingsLocation = $RegLocations['ProxySettingsPerUser']
        $ProxySettingsPerUser = ( Get-ItemPropertyValue @SettingsLocation ) -ne 0
    }
    catch { $ProxySettingsPerUser = $true}

    if ( -not $PSBoundParameters.Context) {
        if ($ProxySettingsPerUser) {
            $Context = 'CurrentUser'
        }
        else {
            $Context = 'LocalMachine'
        }
    }

    $SettingsLocation = $RegLocations[$Context]

    $Counter = (Get-WinHttpProxySettings -Context $Context | Select-Object -ExpandProperty Counter) + 1

    $Settings = [byte[]]$null
    $Settings += $Version, 00, 00, 00
    $Settings += $Counter, 00, 00, 00
    $Settings += ([winhttpflags]$ConfigFlags + 1), 00, 00, 00
    $Settings += [System.Text.Encoding]::ASCII.GetByteCount($Proxy), 00, 00, 00
    $Settings += [System.Text.Encoding]::ASCII.GetBytes($Proxy)
    $Settings += [System.Text.Encoding]::ASCII.GetByteCount($Bypass), 00, 00, 00
    $Settings += [System.Text.Encoding]::ASCII.GetBytes($Bypass)
    $Settings += [System.Text.Encoding]::ASCII.GetByteCount($AutoConfig), 00, 00, 00
    $Settings += [System.Text.Encoding]::ASCII.GetBytes($AutoConfig)

    switch ($Version) {
        0x3c {
            $Settings += (, 00) * 28
        }
        0x46 {
            $Settings += (, 00) * 32
        }
    }

    New-ItemProperty @SettingsLocation -PropertyType Binary -Value $Settings -Force | Out-Null
    if ($PassThru) {
        Get-WinHttpProxySettings -Context $Context
    }
}