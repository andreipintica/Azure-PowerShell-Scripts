<# 
.SYNOPSIS 
    Script to automate downloading the Compute IP address ranges (including SQL ranges) used by the Microsoft Azure Datacenters region wise and add to windows firewall outbound rules. 
    A new xml file will be uploaded every Wednesday (Pacific Time) with the new planned IP address ranges. 
    New IP address ranges will be effective on the following Monday (Pacific Time). Please execute this script every Monday to add the latest IP ranges to the firewall rule. 
        Region List
        ======================
        <Region Name="useast">
        <Region Name="useast ">
        <Region Name="uswest">
        <Region Name="usnorth">
        <Region Name="europenorth">
        <Region Name="uscentral">
        <Region Name="asiaeast">
        <Region Name="asiasoutheast">
        <Region Name="ussouth">
        <Region Name="japanwest">
        <Region Name="japaneast">
        <Region Name="brazilsouth">
        <Region Name="australiaeast">
        <Region Name="australiasoutheast">
        <Region Name="indiacentral">
        <Region Name="indiawest">
        <Region Name="indiasouth">
    
.DESCRIPTION 
Script to automate downloading the Compute IP address ranges (including SQL ranges) used by the Microsoft Azure Datacenters region wise and add to windows firewall outbound rules. 
    A new xml file will be uploaded every Wednesday (Pacific Time) with the new planned IP address ranges. 
    New IP address ranges will be effective on the following Monday (Pacific Time). Please execute this script every Monday to add the latest IP ranges to the firewall rule. 
        Region List
        ======================
        <Region Name="useast">
        <Region Name="useast ">
        <Region Name="uswest">
        <Region Name="usnorth">
        <Region Name="europenorth">
        <Region Name="uscentral">
        <Region Name="asiaeast">
        <Region Name="asiasoutheast">
        <Region Name="ussouth">
        <Region Name="japanwest">
        <Region Name="japaneast">
        <Region Name="brazilsouth">
        <Region Name="australiaeast">
        <Region Name="australiasoutheast">
        <Region Name="indiacentral">
        <Region Name="indiawest">
        <Region Name="indiasouth">
.EXAMPLE 
    
    .\AzDCIPRanges.ps1 -region "useast"
#> 

param( 
     # The name of the storage account to enumerate. 
    [Parameter(Mandatory = $true)] 
    [string]$region
    
) 
$wfdn = Get-NetFirewallRule -Direction Outbound | where {$_.DisplayName -like "AZDCIPRange-*$region"}
if ($wfdn -ne $null) {Remove-NetFirewallRule -DisplayName AZDCIPRange-$region}
$WebResponse = Invoke-WebRequest https://www.microsoft.com/en-in/download/details.aspx?id=41653
[String]$wbrs = $WebResponse
$flname=$wbrs.Substring($wbrs.IndexOf('PublicIPs'),22)
$url = "https://download.microsoft.com/download/0/1/8/018E208D-54F8-44CD-AA26-CD7BC9524A8C/$flname"
[xml]$xml = (new-object System.Net.WebClient).DownloadString($url)
$iplist = $xml.AzurePublicIpAddresses.Region |   Where {$_.Name -eq $region} | Foreach {$_.iprange}  
$RemoteIPrange = ""
foreach ($ip in $iplist)
{
 $RemoteIPrange+= $ip.Subnet + ","
}
netsh advfirewall firewall add rule name="AZDCIPRange-$region" dir="out" remoteip=$RemoteIPrange action="allow" 