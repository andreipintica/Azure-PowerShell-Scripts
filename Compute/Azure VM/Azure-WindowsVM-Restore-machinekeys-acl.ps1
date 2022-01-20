<#
.SYNOPSIS
 Delete machine keys stored inside the Windows VM
.DESCRIPTION
 The script it's deleting all the stored keys taking the ownership and assigning the ownership back to system. 
.NOTES
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
#>

#RESTORE MACHINEKEYS ACL
remove-module psreadline 

$folder = "C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys"
$pairkey = "C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys\f686*"

#Take ownership of the folder and its child objects
Takeown /f $folder /a /r  
takeown /f $folder /a /r /d:Y

#Take a backup of the current access levels
md c:\temp
icacls $folder /t /c > c:\temp\machinekeys_before.txt 

#disable inheritance on folder
icacls $folder /inheritance:d

#Correct perms to the MachineKeys folder
icacls $folder /c /grant "BUILTIN\Administrators:(F)"
icacls $folder /c /grant "Everyone:(R,W)"


#Correct perms to the f686 pair key
icacls $pairkey /c /grant "NT AUTHORITY\System:(F)"
icacls $pairkey /c /grant "NT AUTHORITY\NETWORK SERVICE:(R)"
icacls $pairkey /c /grant "NT Service\SessionEnv:(F)"

#enable inheritance on pair key
icacls $pairkey /inheritance:e

#Get ACL after change
icacls $folder /t /c > c:\temp\machinekeys_after.txt

#Give ownership back to SYSTEM for folder & contents
icacls $folder /setowner "NT Authority\SYSTEM" /T

#Restart the Terminal Service
Restart-Service TermService -Force
