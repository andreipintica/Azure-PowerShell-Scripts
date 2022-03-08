#This will update the NIC status

$nic = Get-AzNetworkInterface -ResourceGroupName "rgName" -Name "nicName"
Set-AzNetworkInterface -NetworkInterface $nic