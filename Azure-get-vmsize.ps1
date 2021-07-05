<#
.SYNOPSIS
Find VM Model for different sizes - Azure VM.
.DESCRIPTION
Get vm model for size.
.EXAMPLE
# example: Size minimum 32 CPU and maximum 64 GB ram
get-vmsize -cpu_min 32 -ram_max 64

# example: max 2 cpu, accelerated network supported
get-vmsize -cpu_max 2 -net_support

# example: max 2 cpu, iops > 6000
get-vmsize -cpu_max 2 -iops_min 6000 

.NOTES
The script can also run in Cloud Shell Console.
#>

function get-vmsize()
{
    Param($cpu_min=0, $cpu_max=1024, $ram_min=0, $ram_max=1024, $iops_min=0, $iops_max=100000, [switch]$crypt_support, [switch]$net_support, [switch]$verbose, $region="westeurope")
    # vCPUs MemoryGB AcceleratedNetworkingEnabled UncachedDiskIOPS

    if (! $global:vmsize )
    {
        $global:vmsize  = Get-AzComputeResourceSku  | where {$_.Locations.Contains("$region") -and $_.ResourceType.Contains("virtualMachines") }
    }

    foreach ( $size in $vmsize)
    {
        $name = $size.Name
        $cpu = [int]$($size.Capabilities | where { $_.Name -eq "vCPUs" }).Value
        $ram = [int]$($size.Capabilities | where { $_.Name -eq "MemoryGB" }).Value
        $iops = [int]$($size.Capabilities | where { $_.Name -eq "UncachedDiskIOPS" }).Value
        $crypt = $($size.Capabilities | where { $_.Name -eq "EncryptionAtHostSupported" }).Value
        $net =  $($size.Capabilities | where { $_.Name -eq "AcceleratedNetworkingEnabled" }).Value

        if ( ($cpu -ge $cpu_min) -and ($cpu -le $cpu_max) -and ($ram -ge $ram_min) -and ($ram -le $ram_max) -and ($iops -ge $iops_min) -and ($iops -le $iops_max) )
        {
            if ( !$crypt_support -or $crypt -eq "True" )
            {
                if ( !$net_support -or $net -eq "True" )
                {   
                    if ( $verbose )
                    {
                        echo "$name $cpu $ram $iops"
                    }
                    else
                    {       
                        $size.Name
                    }
                }
            }
        }
    }
}

