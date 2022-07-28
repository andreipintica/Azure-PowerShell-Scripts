# Installing Hyper-V

Install-WindowsFeature -Name Hyper-V -ComputerName <computer_name> -IncludeManagementTools - -Restart

Get-WindowsFeature -ComputerName <computer_name>