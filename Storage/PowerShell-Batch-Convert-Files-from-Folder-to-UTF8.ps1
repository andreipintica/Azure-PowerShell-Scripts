<#
.SYNOPSIS
A PowerShell batch scrip that convert files from a folder to UTF8.
.DESCRIPTION
Re-Write all files in a folder in UTF-8.
.NOTES
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
Should not be used with -recurse
You can use the same script to convert to UTF16, UTF32, you need to update the -Encoding from UTF8 with the desired format.
.PARAMETER Source
Directory path to recursively scan for files
.PARAMETER Destination
Directory path to write files to
.LINK 
https://www.unicode.org/faq/utf_bom.html
#>

write-host " "
$sourcePath = (get-location).path   # Use current folder as source.
# $sourcePath = "C:\Source-files"   # Use custom folder as source.
$destinationPath = (get-location).path + '\Out'   # Use "current folder\Out" as target.
# $destinationPath = "C:\UTF8-Encoded"   # Set custom target path

$cnt = 0

write-host "UTF8 convertsation from " $sourcePath " to " $destinationPath

if (!(Test-Path $destinationPath))

{
  write-host "(Note: target folder created!) "
  new-item -type directory -path $destinationPath -Force | Out-Null
}

Get-ChildItem -Path $sourcePath -Filter *.txt | ForEach-Object {
  $content = Get-Content $_.FullName
  Set-content (Join-Path -Path $destinationPath -ChildPath $_) -Encoding UTF8 -Value $content
  $cnt++
 }
write-host " "
write-host "Totally " $cnt " files converted!"
write-host " "
pause