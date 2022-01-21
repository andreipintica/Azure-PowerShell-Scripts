<#
.SYNOPSIS
 Invokes a command for the specified Azure virtual machine. 
 The acceptable commands are: Stop, Start, Restart

.COMPONENT
 Requires Module Az

.Parameter Name
 Specifies the name of the virtual machine

.Parameter ResourceGroupName
 Specifies the name of the resource group of the virtual machine
 
.Parameter Command
 Specifies the command that executed on the Azure virtual machine
 #>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [ValidateSet('Stop','Start','Restart')]
    [string]$Command
)

Import-Module Az.Compute

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false 
                            'Name' = $Name
                            'ResourceGroupName' = $ResourceGroupName
                            }
    switch ($Command){
        "Stop"{
            $cmdArgs.Add("Force",$null)
            $ret = Stop-AzVM @cmdArgs
        }
        "Start"{
            $ret = Start-AzVM @cmdArgs
        }
        "Restart"{
            $ret = Restart-AzVM @cmdArgs
        }
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
} 
