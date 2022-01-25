<#
.Description
You're unable to complete a remote desktop protocol (RDP) connection to the VM and you receive the error: 
"The trust relationship between this workstation and the primary domain failed".
.Info
The Active Directory Secure Channel between this VM and the primary domain is broken. This error shows that the machine can't establish a 
secure communication with a domain controller in its domain, because the secret password isn't set to the same value in the domain controller.
#>

#Check the connectivity to the domain controller run cmd.exe
set | find /i "LOGONSERVER"

#Check the health of the secure channel
Test-ComputerSecureChannel -verbose

#Repair the secure channel
Test-ComputerSecureChannel -Repair

#If the secure channel is not repaired, reset the machine password.

$cred = Get-Credential
Invoke-Command -ComputerName "Server01" -ScriptBlock {Reset-ComputerMachinePassword -Credential $using:cred}

#Remove the VM from the domain
'Remove-Computer -UnjoinDomaincredential Domain01\Admin01 -PassThru -Verbose -Restart'

#Re-join the domain
'Add-Computer -ComputerName Server01 -LocalCredential Server01\Admin01 -DomainName Domain02 -Credential Domain02\Admin02 -Restart -Force'
