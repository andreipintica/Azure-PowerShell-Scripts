<#
.SYNOPSIS
Find the hostname of a Hyper-V VM
.DESCRIPTION
If you are running a virtual machine (VM) on Hyper-V, sometimes you want to know on which Hyper-V host this VM is running. If you don’t have access to the Hyper-V host, you need to find that information from within the virtual machines operating system
.NOTES
The scripts is displaying the information under the following registry key
Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters
#>

Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters"  | Select-Object HostName 

