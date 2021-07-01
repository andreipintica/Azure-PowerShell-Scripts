<#
.SYNOPSIS
Find VM Model for different sizes - Azure VM.
.DESCRIPTION
Get vm model for size.
.EXAMPLE
Run the script.

.NOTES
Name: Azure-NSG-info
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)

The script can also run in Cloud Shell Console.
#> 

$exportPath = 'C:\Temp'
$nsgs = Get-AzNetworkSecurityGroup
Foreach ($nsg in $nsgs) {
    $nsgRules = $nsg.SecurityRules
    foreach ($nsgRule in $nsgRules) {
        $nsgRule | Select-Object @{n = "NSG Name"; e = { $nsg.Name -join "," } },
        @{n = "NSG Rule Type"; e = {"Custom Rule"} },
        Name, Description, Priority,
        @{n = "SourceAddressPrefix"; e = { $_.SourceAddressPrefix -join "," } },
        @{n = "SourcePortRange"; e = { $_.SourcePortRange -join "," } },
        @{n = "DestinationAddressPrefix"; e = { $_.DestinationAddressPrefix -join "," } },
        @{n = "DestinationPortRange"; e = { $_.DestinationPortRange -join "," } },
        Protocol, Access, Direction | Export-Csv "$exportPath\$($nsg.Name).csv" -NoTypeInformation -Encoding ASCII -Append
         
    }
    $defnsgRules = $nsg.DefaultSecurityRules
    foreach ($defnsgitem in $defnsgRules) {
        $defnsgitem | Select-Object @{n = "NSG Name"; e = { $nsg.Name -join "," } },
        @{n = "NSG Rule Type"; e = {"Default Rule"} },
        Name, Description, Priority,
        @{n = "SourceAddressPrefix"; e = { $_.SourceAddressPrefix -join "," } },
        @{n = "SourcePortRange"; e = { $_.SourcePortRange -join "," } },
        @{n = "DestinationAddressPrefix"; e = { $_.DestinationAddressPrefix -join "," } },
        @{n = "DestinationPortRange"; e = { $_.DestinationPortRange -join "," } },
        Protocol, Access, Direction | Export-Csv "$exportPath\$($nsg.Name).csv" -NoTypeInformation -Encoding ASCII -Append
    }
}