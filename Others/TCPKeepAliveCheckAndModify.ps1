<#
.SYNOPSIS
    This script will just check and display the status of the TCP
    KeepAliveTime registry key on specified servers, or servers in
    the site of the machine where the script is executed from.
.DESCRIPTION
    This script can be modified to check other registry keys, in this
    example we'll check for the existence and the value set for the
    TCP KeepAlive time, which is the time Windows will keep a TCP
    session opened (it's 2 hours by default if this key is not present).
    TCP Keep Alive Time is important to know to correctly setup the
    network equipment your Windows server will be connected to : the
    objective is to make sure that a network equipment will not close
    the TCP session before a Windows client finishes its session with
    the Windows server => all applications hosted on a Windows Server
    use Windows TCP session times, so users can experience application
    disconnections if the network equipment close the TCP session before
    they finish to work with a given application like Outlook /
    Exchange Server.
.PARAMETER Servers
    One or a list of servers, comma separated. 
    
    If you don't put any servers, the script will scan the servers in the site
    of the machine where the script is run from.
    
    NOTE: you don't need double quotes around each server name if these
    servers don't have spaces in it.
.PARAMETER CheckVersion
    This parameter will just dump the script current version.
.INPUTS
    You cannot pipe objects to that script. Just specify a list of servers
    or the script will check the servers on the current site it's run from.
.OUTPUTS
    The list of servers and the status of the TCP KeepAlive keys as well as a 
    text CSV file with the name of each server, status of each TCP KeepAkive
    keys (present or not), and if present, the value of these.
.EXAMPLE
    .\TCPKeepAliveCheckAndModify.ps1 -Servers E2016-01, E2016-02
    This will launch the script and run on servers E2016-01 and E2016-02
.EXAMPLE
    .\TCPKeepAliveCheckAndModify.ps1 -AskModify -Servers Server1, Server2
    Will launch the script on specified servers (Server1 and Server2) and ask if we modify these
.EXAMPLE
    .\TCPKeepAliveCheckAndModify.ps1
    This will launch the script and gather the registry keys on all the
    servers of the site where this script is run from.
    Output Example:
    No servers specified with the -Servers Server1, Server2, ... property, Local site is OTTAWA ... 
    about to load the Exchange cmdlets if not loaded, you MUST have Exchange Management Tools installed 
    locally, or call the script from an Exchange-enabled PowerShell host, do you want to continue ?
    [Y] Yes [N] No [?] Help (default is "No"):
.EXAMPLE
.\TCPKeepAliveCheckAndModify.ps1 -CheckVersion
This will dump the script name and current version like :
SCRIPT NAME : TCPKeepAliveCheckAndModify.ps1


.NOTES
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

#>
[CmdLetBinding(DefaultParameterSetName = "NormalRun")]
Param(
    [Parameter(Mandatory = $False, Position = 1, ParameterSetName = "NormalRun")][string[]]$Servers,
    [Parameter(Mandatory = $False, Position = 2, ParameterSetName = "NormalRun")][switch]$AskModify,
    [Parameter(Mandatory = $false, Position = 3, ParameterSetName = "CheckOnly")][switch]$CheckVersion
)

<# ------- SCRIPT_HEADER (Only Get-Help comments and Param() above this point) ------- #>
#Initializing a $Stopwatch variable to use to measure script execution
$stopwatch = [system.diagnostics.stopwatch]::StartNew()
#Using Write-Debug and playing with $DebugPreference -> "Continue" will output whatever you put on Write-Debug "Your text/values"
# and "SilentlyContinue" will output nothing on Write-Debug "Your text/values"
$DebugPreference = "Continue"
# Set Error Action to your needs
$ErrorActionPreference = "SilentlyContinue"

$ScriptName = $MyInvocation.MyCommand.Name
If ($CheckVersion) {Write-Host "SCRIPT NAME     : $ScriptName `nSCRIPT VERSION  : $ScriptVersion";exit}
# Log or report file definition
# NOTE: use $PSScriptRoot in Powershell 3.0 and later or use $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition in Powershell 2.0
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$OutputReport = "$ScriptPath\$($ScriptName)_$(get-date -f yyyy-MM-dd-hh-mm-ss).csv"
# Other Option for Log or report file definition (use one of these)
$ScriptLog = "$ScriptPath\$($ScriptName)-$(Get-Date -Format 'dd-MMMM-yyyy-hh-mm-ss-tt').txt"
<# ---------------------------- /SCRIPT_HEADER ---------------------------- #>
<# -------------------------- DECLARATIONS -------------------------- #>
$ADSite = $null
New-Alias -Name "Log" Write-Host

<# /DECLARATIONS #>
<# -------------------------- FUNCTIONS -------------------------- #>

Function Title1 ($title, $TotalLength = 100, $Back = "Yellow", $Fore = "Black") {
    $TitleLength = $Title.Length
    [string]$StarsBeforeAndAfter = ""
    $RemainingLength = $TotalLength - $TitleLength
    If ($($RemainingLength % 2) -ne 0) {
        $Title = $Title + " "
    }
    $Counter = 0
    For ($i=1;$i -le $(($RemainingLength)/2);$i++) {
        $StarsBeforeAndAfter += "*"
        $counter++
    }
    
    $Title = $StarsBeforeAndAfter + $Title + $StarsBeforeAndAfter
    Write-Host $Title -BackgroundColor $Back -foregroundcolor $Fore
    Write-Host
    
}
Function LogRed ($Message){
    Write-Host $message -ForegroundColor Red
}

Function LogGreen ($message){
    Write-Host $message -ForegroundColor Green
}

Function LogYellow ($message){
    Write-Host $message -ForegroundColor Yellow
}

Function LogBlue ($message){
    Write-Host $message -ForegroundColor Blue
}
<# /FUNCTIONS #>
<# -------------------------- EXECUTIONS -------------------------- #>
# Getting local site name

If ($Servers -eq $null) {
    $ADSite = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite().Name
    $Message = "No servers specified with the -Servers Server1, Server2, ... property, Local site is $ADSite ... about to load the Exchange cmdlets if not loaded, you MUST have Exchange Management Tools installed locally, or call the script from an Exchange-enabled PowerShell host, do you want to continue ?"
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","help";
    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No","help";
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($Yes,$no);
    $answer = $host.UI.PromptForChoice($caption,$message,$choices,1)
    
    switch ($answer){
        0 {LogGreen "Continuing Script..."; Start-Sleep -Seconds 3}
        1 {LogRed "Exiting Script..."; exit}
    }

    Title1 "Preparing the environment"

    $CheckSnapin = (Get-PSSnapin | Where {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.E2010"} | Select Name)
    if($CheckSnapin -like "*Exchange.Management.PowerShell*"){
        LogGreen "Exchange Snap-in already loaded, continuing...." -ForegroundColor Green
    }
    Else{
        LogYellow "Loading Exchange Snap-in Please Wait..."
        Try{
            Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction Stop
        }
        Catch {
            LogRed "NO EXCHANGE SNAPPINS PRESENT ON THIS MACHINE. PLEASE SPECIFY -Servers <Server1, Server2, ...> OR RUN THE SCRIPT FROM A MACHINE WHERE EXCHANGE MANAGEMENT TOOLS ARE INSTALLED !"
            exit
        }
    }
    Title1 "Getting Exchange Servers list"
    $ExchServers = Get-ExchangeServer | Where-Object {$_.Site -match $ADSite}
    Foreach ($Item in $ExchServers){
        [string[]]$Servers += $Item.name
    }
}

$Servers | out-host

#Connect to Each server that it finds from above and open the KeepAliveTime registry key if it exists and record the value.
Title1 "TCP KeepAlive registry Key settings"

$FullReport = @()


#File Output parameters for report output
$OutputFilePath = "$($env:userprofile)\Documents"
$OutPutReportName = "TCPKeepAliveTimeReport" + "-" + (Get-Date).ToString("MMddyyyyHHmmss") + ".csv"
$OutPutFullReportPath = $OutputFilePath + "\" + $OutPutReportName

if ($Servers.count -gt 0){
Title1 "Parsing all Exchange servers..."
#Connect to Each server that it finds from above and open the KeepAliveTime registry key if it exists and record the value.
foreach ($Server in $Servers){
Title1 "Parsing Server $($Server)"
$EXCHServer = $Server
$OpenReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$EXCHServer)
$RegKeyPath = 'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
$RegKey = $OpenReg.OpenSubKey($RegKeyPath)
$TCPKeepAlive = $RegKey.GetValue('KeepAliveTime')
$Exists = if($TCPKeepAlive){$true} else {$false}

#Dump the scripts findings into an object.
$Report = [PSCustomObject]@{
    "Server Name" = $EXCHServer;
    "Key Present" = $Exists;
    "TCP Keep Alive Time" = $TCPKeepAlive}

#Write the output to a report file
Title1 "Writing in report on path $OutPutFullReportPath"
        $Report | Export-Csv ($OutPutFullReportPath) -Append -NoTypeInformation
    } 
        }
            else
    {

    Write-Host "Found 0 Exchange Servers, Exiting Script..." -ForegroundColor Red 
    Write-Host " "
    Write-Host " "
    Write-Host "Press Any Key To Continue ..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

   
    Exit 
        }
#Asks if you'd like to change the TCP Keep Alive Times.
If ($AskModify){
Title1 "-AskModify parameter was specified"
    $Message = "Do You Want To Create And Or Modify The TCP KeepAliveTime Registry Key?"
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","help";
    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No","help";
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($Yes,$no);
    $answer = $host.UI.PromptForChoice($caption,$message,$choices,1)

        switch ($answer){
        0 {Write-Host "Continuing Script As You Have Confirmed That You Want To Create And Or Modify The TCP KeepAliveTime Registry Key"; Start-Sleep -Seconds 5}
        1 {Write-Host "Exiting Script..."; notepad $OutPutFullReportPath ;exit}
            }

    $TimeValue = Read-Host 'How Many Milliseconds Do You Want The TCP Keep Alive Time Set Too? Default is 1,800,000ms (30 minutes)'
    $DefaultValue = "1800000"
    $KeyName = "KeepAliveTime"


    $counter = 0
            foreach ($Server in $Servers){
                $Counter++
                Write-progress -Activity "Changing Server..." -Status "$Server" -PercentComplete (($counter/$Servers.count)*100)
                Write-Host "Changing Server $Server ..." -ForegroundColor Red
                $EXCHServer = $Server
                $BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$EXCHServer)
                $SubKey = $BaseKey.OpenSubkey("SYSTEM\CurrentControlSet\Services\Tcpip\Parameters",$true)
            
                if ($TimeValue){
                Write-host "Time Value = $TimeValue"
                    $SubKey.SetValue($KeyName, $TimeValue, [Microsoft.Win32.RegistryValueKind]::DWORD)
                }
                Else
                {
                write-host "Time Value = $Default"
                    $SubKey.SetValue($KeyName, $DefaultValue, [Microsoft.Win32.RegistryValueKind]::DWORD)
                }
            }

     Write-Host 'Each Server That Had Its TCP Keep Alive Time Value Changed Will Require A Reboot For The Changes To Take Affect.`n To check the new values, run the script again to dump the report of current key value`nPress ANY key ...' -ForegroundColor Green
     $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

<# /EXECUTIONS #>
<# -------------------------- CLEANUP VARIABLES -------------------------- #>

<# /CLEANUP VARIABLES#>
<# ---------------------------- SCRIPT_FOOTER ---------------------------- #>
#Stopping StopWatch and report total elapsed time (TotalSeconds, TotalMilliseconds, TotalMinutes, etc...
$stopwatch.Stop()
$msg = "`n`nThe script took $([math]::round($($StopWatch.Elapsed.TotalSeconds),2)) seconds to execute..."
Write-Host $msg
$msg = $null
$StopWatch = $null
<# ---------------- /SCRIPT_FOOTER (NOTHING BEYOND THIS POINT) ----------- #>