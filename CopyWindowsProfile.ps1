<#
.SYNOPSIS
    PowerShell script for copying a user profile to a new machine using ROBOCOPY.
.DESCRIPTION
    Run this script if you want to copy a user profile to a new machine. If you want to edit the predefined folder, just edit the $FoldersToCopy.
.NOTES
    Script name: CopyWindowsProfile.ps1
    URL: https://cloudopshub.net/windows10/powershell-script-for-copying-a-user-profile-to-a-new-machine/
#>

$FoldersToCopy = @(
    'Desktop'
    'Downloads'
    'Favorites'
    'Documents'
    'Pictures'
    'Videos'
    'My Program Files'
    )

$ConfirmComp = $null
$ConfirmUser = $null

while( $ConfirmComp -ne 'y' ){
    $Computer = Read-Host -Prompt 'Enter the computername from where to copy'

    if( -not ( Test-Connection -ComputerName $Computer -Count 2 -Quiet ) ){
        Write-Warning "$Computer is not online. Please retry or try another computername."
        continue
        }

    $ConfirmComp = Read-Host -Prompt "You have entered:`t$Computer`r`nIs this correct? (y/n)"
    }

while( $ConfirmUser -ne 'y' ){
    $User = Read-Host -Prompt 'Please enter the profile name from where you want to copy.'

    if( -not ( Test-Path -Path "\\$Computer\c$\Users\$User" -PathType Container ) ){
        Write-Warning "$User we didn't find any this profile on $Computer. Try again/try another profile."
        continue
        }

    $ConfirmUser = Read-Host -Prompt "The entered profile is:`t$User`r`nIs this correct? (y/n)"
    }

$SourceRoot      = "\\$Computer\c$\Users\$User"
$DestinationRoot = "C:\Users\$User"

foreach( $Folder in $FoldersToCopy ){
    $Source      = Join-Path -Path $SourceRoot -ChildPath $Folder
    $Destination = Join-Path -Path $DestinationRoot -ChildPath $Folder

    if( -not ( Test-Path -Path $Source -PathType Container ) ){
        Write-Warning "We didn't find this path`t$Source"
        continue
        }

    Robocopy.exe $Source $Destination /E /IS /NP /NFL
    }