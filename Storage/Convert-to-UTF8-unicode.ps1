<#
.SYNOPSIS
 Encode-Utf8
    
.Description
 Re-Write all files in a folder in UTF-8
.PARAMETER Source
 Directory path to recursively scan for files
.PARAMETER Destination	 
 Directory path to write files to
.Notes
Version: 1.0.1
Author: Andrei Pintica (@AndreiPintica)
#>

[CmdletBinding(DefaultParameterSetName="Help")]

Param(

   [Parameter(Mandatory=$true, Position=0, ParameterSetName="Default")]

   [string]

   $Source,



   [Parameter(Mandatory=$true, Position=1, ParameterSetName="Default")]

   [string]

   $Destination,



  [Parameter(Mandatory=$false, Position=0, ParameterSetName="Help")]

   [switch]

   $Help  

)



if($PSCmdlet.ParameterSetName -eq 'Help'){

    Get-Help $MyInvocation.MyCommand.Definition -Detailed

    Exit

}



if($PSBoundParameters['Debug']){

    $DebugPreference = 'Continue'

}



$Source = Resolve-Path $Source



if (-not (Test-Path $Destination)) {

    New-Item -ItemType Directory -Path $Destination -Force | Out-Null

}

$Destination = Resolve-Path $Destination



$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)



foreach ($i in Get-ChildItem $Source -Recurse -Force) {

    if ($i.PSIsContainer) {

        continue

    }



    $path = $i.DirectoryName.Replace($Source, $Destination)

    $name = $i.Fullname.Replace($Source, $Destination)



    if ( !(Test-Path $path) ) {

        New-Item -Path $path -ItemType directory

    }



    $content = get-content $i.Fullname



    if ( $content -ne $null ) {

        [System.IO.File]::WriteAllLines($name, $content, $Utf8NoBomEncoding)

    } else {

        Write-Host "No content from: $i"  

    }

}
