<#
.SYNOPSIS
Sort VM Size - Azure VM.
.DESCRIPTION
Sort VM size.
.EXAMPLE
# example: Size minimum 32 CPU and maximum 64 GB ram
get-vmsize -cpu_min 32 -ram_max 64

# example: max 2 cpu, accelerated network supported
get-vmsize -cpu_max 2 -net_support

# example: max 2 cpu, iops > 6000
get-vmsize -cpu_max 2 -iops_min 6000 

# Count VM 16 cpu max, ssd, net and crypt
$(get-vmsize -cpu_max 16 -net_support -crypt_support -ssd_support).Count

# RECOMMENDED SIZES
get-vmsize -cpu_max 2 -ram_min 6 -iops_min 6000 -net_support -crypt_support -ssd_support
get-vmsize -cpu_min 4 -cpu_max 4 -ram_min 8 -iops_min 12000 -net_support -crypt_support -ssd_support
get-vmsize -cpu_min 8 -cpu_max 8 -ram_min 16 -iops_min 24000 -net_support -crypt_support -ssd_support
get-vmsize -iops_min 12000 -cpu_max 16 -ram_max 32 -net_support -crypt_support -ssd_support

#PRICE
get-vmsize -cpu_max 2 -ram_min 6 -iops_min 6000 -net_support -crypt_support -ssd_support -verbose -price_max 160
get-vmsize -cpu_min 4 -cpu_max 4 -ram_min 8 -iops_min 12000 -net_support -crypt_support -ssd_support -price_max 300 -verbose
get-vmsize -cpu_min 8 -cpu_max 8 -ram_min 16 -iops_min 24000 -net_support -crypt_support -ssd_support -price_max 500 -verbose
get-vmsize -iops_min 12000 -cpu_max 16 -ram_min 32 -ram_max 48 -net_support -crypt_support -ssd_support -price_max 600 -verbose

.NOTES
The script can also run in Cloud Shell Console.
#>

function get-vmprice()
{
    param($name, $region="westeurope", $currency="EUR" )

    $query = "currencyCode='" + "$currency" + "'&`$filter=serviceName eq 'Virtual Machines' and armRegionName eq '" + "$region" + "' and priceType eq 'Consumption' and serviceFamily eq 'Compute' and endswith(productName, 'Windows')  and armSkuName eq '" + "$name" + "'"
    $query = $query.Replace(' ','%20')
    $query = $query.Replace("'",'%27')

    $uri = "https://prices.azure.com/api/retail/prices?$query"
    $webReq = Invoke-WebRequest -Uri  "$uri" | ConvertFrom-Json
    $items = $webReq.Items

    foreach ( $item in $items)
    {
        if ( ! ($item.skuName -match "Low" -or $item.skuName -match "Spot") )
        {
            [math]::Round([float]$item[0].unitPrice * 730,2)
        }
    }
}

function get-vmsize()
{
    Param($cpu_min=0, $cpu_max=1024, $ram_min=0, $ram_max=1024, $iops_min=0, $iops_max=100000, $price_max=0, [switch]$crypt_support, [switch]$net_support, [switch]$ssd_support, [switch]$verbose, $region="westeurope")

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
        $ssd =  $($size.Capabilities | where { $_.Name -eq "PremiumIO" }).Value

        if ( ($cpu -ge $cpu_min) -and ($cpu -le $cpu_max) -and ($ram -ge $ram_min) -and ($ram -le $ram_max) -and ($iops -ge $iops_min) -and ($iops -le $iops_max) )
        {
            if ( !$crypt_support -or $crypt -eq "True" )
            {
                if ( !$net_support -or $net -eq "True" )
                {   
                
                    if ( !$ssd_support -or $ssd -eq "True" )
                    {   
                        if ( $price_max -gt 0 )
                        {
                            $namesize = $size.Name
                            $prix = get-vmprice -name $namesize 
                            if ($prix -eq $null ) { $prix=999999 }
                        }

                        if ( $price_max -eq 0 -or $prix -le $price_max )
                        {
                            if ( $verbose )
                            {
                                echo "$name $cpu $ram $iops $prix"
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
    }
}
