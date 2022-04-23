<#
.SYNOPSIS
Creates a VM.
.DESCRIPTION
Create a VM with desired OS.
.EXAMPLE
Parameter Name - Specifies a name for the virtual machine.
Parameter ResourceGroupName - Specifies the name of a resource group
Parameter Location - Specifies the location for the virtual machine
Parameter AdminCredential - The administrator credentials for the VM
Parameter DataDiskSizeInGb - Specifies the sizes of data disks in GB
Parameter EnableUltraSSD - Enables UltraSSD disks for the vm
Parameter Image - The friendly image name upon which the VM will be built
Parameter AllocationMethod - The IP allocation method for the public IP which will be created for the VM
Parameter SecurityGroupName - The name of a new (or existing) network security group (NSG) for the created VM to use, if is not specified, a name will be generated
Parameter SubnetName - The name of a new (or existing) subnet for the created VM to use, if is not specified, a name will be generated
Parameter VirtualNetworkName - The name of a new (or existing) virtual network for the created VM to use, if is not specified, a name will be generated
Parameter Size - The Virtual Machine Size, if is not specified the dafil size for VM it will be Standard_D2s_V3.


.NOTES
Requires Azure Az PowerShell module
Requires Library script AzureAzLibrary.ps1
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [pscredential]$AdminCredential,
    [string]$ResourceGroupName,
    [int]$DataDiskSizeInGb,
    [switch]$EnableUltraSSD,
    [ValidateSet('Win2016Datacenter', 'Win2012R2Datacenter', 'Win2012Datacenter', 'Win2008R2SP1', 'UbuntuLTS', 'CentOS', 'CoreOS', 'Debian', 'openSUSE-Leap', 'RHEL', 'SLES')]
    [string]$Image = "Win2016Datacenter",
    [ValidateSet('Static', 'Dynamic')]
    [string]$AllocationMethod,
    [string]$Location,
    [string]$SecurityGroupName,
    [string]$SubnetName,
    [string]$VirtualNetworkName,
    [string]$Size = 'Standard_D2s_V3'
)

Import-Module Az.Compute

try{
    [string[]]$Properties = @('Name','StatusCode','ResourceGroupName','Id','VmId','Location','ProvisioningState','DisplayHint')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Credential' = $AdminCredential
                            'Name' = $Name
                            'Image' = $Image
                            'EnableUltraSSD' = $EnableUltraSSD}

    if([System.String]::IsNullOrWhiteSpace($ResourceGroupName) -eq $false){
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
    }
    if([System.String]::IsNullOrWhiteSpace($Location) -eq $false){
        $cmdArgs.Add('Location',$Location)
    }
    if([System.String]::IsNullOrWhiteSpace($SecurityGroupName) -eq $false){
        $cmdArgs.Add('SecurityGroupName',$SecurityGroupName)
    }
    if([System.String]::IsNullOrWhiteSpace($SubnetName) -eq $false){
        $cmdArgs.Add('SubnetName',$SubnetName)
    }
    if([System.String]::IsNullOrWhiteSpace($VirtualNetworkName) -eq $false){
        $cmdArgs.Add('VirtualNetworkName',$VirtualNetworkName)
    }
    if([System.String]::IsNullOrWhiteSpace($AllocationMethod) -eq $false){
        $cmdArgs.Add('AllocationMethod',$AllocationMethod)
    }
    if($PSBoundParameters.ContainsKey('Size') -eq $true){
        $cmdArgs.Add('Size',$Size)
    }
    if($DataDiskSizeInGb -gt 0){
        $cmdArgs.Add('DataDiskSizeInGb',$DataDiskSizeInGb)
    }
                            
    $ret = New-AzVM @cmdArgs | Select-Object $Properties
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
