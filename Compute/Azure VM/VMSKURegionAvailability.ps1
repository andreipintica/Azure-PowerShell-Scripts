<#
    .SYNOPSIS
    This PowerShell Script takes a list of Virtual Machine SKUs from a CSV and Regions specified as an array in script and gets a list of what Virtual Machine SKUs are supported in the specified Regions. This script will provide output of the results in both the PowerShell Console as well as a CSV output in the same directory the script is executed from.
    
    .COMPONENT
    Requires Azure Az PowerShell module
    
   .INSTRUCTIONS 
    Download Get-VMRegionAvailability.ps1 and VMSKUs.csv
    Edit VMSKUs.csv to include the Virtual Machine SKUs you want to test.
    Edit Get-VMRegionAvailability.ps1 to include the Regions you want to test Virtual Machine SKU availability against.
    Open PowerShell, navigate to script directory, and connect to Azure leveraging Connect-AZAccount
    If wanting to select a different subscription, run Get-AZSubscription and then Select-AZSubscription to change Subscription.
    Execute the script using .\Get-VMRegionAvailability.ps1. A Windows File Dialog filtering on CSV appears in the same folder the script was executed from. Choose the CSV containing the list of Virtual Machine SKUs.
    The results are provided in the PowerShell Console.
    An output CSV is also generated and stored in the same folder the script was executed from. The location is specified at the bottom of the PowerShell Console.
    .NOTES
    Name: VMSKURegionAvailability.ps1
    Version: 1.0.0
    Author: Andrei Pintica (@AndreiPintica)
#>

# Replace $Region Array with the following if you want to check all regions: $Regions = (Get-AzLocation).Location
$Regions = @(
    'WestEurope',
    'NorthEurope'
)

function Get-SHDOpenFileDialog {
    [cmdletbinding()]
    param (
        [string]$InitialDirectory = "$Env:USERPROFILE",
        [string]$Title = "Please Select A file",
        [string]$Filter = "All files (*.*)| *.*",
        [switch]$MultiSelect
    )
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog 
    $FileBrowser.InitialDirectory = "$InitialDirectory"
    $FileBrowser.Filter = "$Filter"
    $FileBrowser.Title = "$Title"
    if ($MultiSelect) {
        $FileBrowser.Multiselect = $true
    } else {
        $FileBrowser.Multiselect = $false
    }
 
    $FileBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true })) | Out-Null
    $FileBrowser.Filenames
    $FileBrowser.dispose()
}

$scriptPath = $MyInvocation.MyCommand.Path
$scriptFolder = Split-Path $scriptPath -Parent
$ExportFile = $scriptFolder + '\' + 'output.csv'

$filename = Get-SHDOpenFileDialog -Title "Select the CSV file" -InitialDirectory $scriptFolder -Filter "CSV Files (*.csv)| *.csv"
$VMSKUsCSV = Import-Csv $filename

$exportData = @()

foreach ($Region in $Regions)
{
    Write-Host "Checking for VM SKU Availability in $Region"
    $RegionData = Get-AzComputeResourceSKU -Location $Region | Where-Object {$_.ResourceType -eq 'VirtualMachines' -and $_.Restrictions.ReasonCode -ne 'NotAvailableForSubscription'}

    foreach ($VMSku in $VMSKUsCSV)
    {
        $exportObj = New-Object PSObject
        if ($RegionData.Name -contains $VMSku.Name)
        {
            Write-Host "$($VMSku.Name) Available in $Region" -ForegroundColor Green
            $exportObj | Add-Member NoteProperty -Name "Region" -Value $Region
            $exportObj | Add-Member NoteProperty -Name "SKU" -Value $VMSku.Name
            $exportObj | Add-Member NoteProperty -Name "Available" -Value 'Yes'
        }
        else 
        {
            Write-Host "$($VMSku.Name) Not available in $Region" -ForegroundColor Red
            $exportObj | Add-Member NoteProperty -Name "Region" -Value $Region
            $exportObj | Add-Member NoteProperty -Name "SKU" -Value $VMSku.Name
            $exportObj | Add-Member NoteProperty -Name "Available" -Value 'No'
        }
        $exportData = $exportData += $exportObj
    }
}
$exportData | Export-Csv -Path $ExportFile -NoTypeInformation
Write-Host "Output CSV generated at the following location: $ExportFile" -ForegroundColor Yellow