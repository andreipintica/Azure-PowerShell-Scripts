<#
.SYNOPSIS
    Determine if a folder exists
.DESCRIPTION
    Determine if a folder exists using the Test-Path command
.PARAMETER 
    The easiest way to do this is to use the Test-Path cmdlet. It looks for a given path and returns True if it exists, otherwise it returns False. 
.EXAMPLE
    Test-Path -Path “./andre/” -Exclude *.txt
    Test-Path -Path $PROFILE -PathType Any
.NOTES
    Script name: folder-exist
    Version:     1
    Author:      Andrei Pintica
    Contact:     @AndreiPintica

#>

$Folder = 'C:\Windows'
"Test to see if folder [$Folder]  exists"
if (Test-Path -Path $Folder) {
    "Path exists!"
} else {
    "Path doesn't exist."
}