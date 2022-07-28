Set-Location c:\
Clear-Host

Enter-PSSession -ComputerName hvcore

Get-NetFirewallRule -DisplayName *replica*

Enable-NetFirewallRule -DisplayName "Hyper-V-Replica - HTTPS-Listener (TCP inbound)"

Enable-NetFirewallRule -DisplayName "Hyper-V-Replica - HTTP-Listener (TCP inbound)"