<#
    .SYNOPSIS
    Sets virtual machine size
    
    .COMPONENT
    Requires Azure Az PowerShell module
    
   .Parameter Name
    Specifies the name of the virtual machine
    
    .Parameter Size
     Specifies the new size of the virtual machine
        
    .Parameter ResourceGroupName
    Specifies the name of the resource group of the virtual machine
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Standard_DS1_v2','Standard_DS2_v2','Standard_DS3_v2','Standard_DS4_v2','Standard_DS5_v2')]
    [string]$Size
)

Import-Module Az.Compute

try{
    $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction Stop
    $vm.HardwareProfile.VmSize = $Size

    Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -Force -ErrorAction Stop
    Update-AzVM -VM $vm -ResourceGroupName $ResourceGroupName -ErrorAction Stop
    Start-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction Stop

    $ret = Get-AzVMSize -ResourceGroupName $ResourceGroupName -VMName $Name -ErrorAction Stop

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
