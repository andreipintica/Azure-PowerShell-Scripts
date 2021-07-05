<#
.SYNOPSIS
Install os from WIM File using Dism.
.DESCRIPTION
Install os from WIM File using Dism and removing appxpackage after instalation. After the task is done the script will unmount the wim file and double remove the desired AppXPackages.
.EXAMPLE
Run script.

.NOTES
Name: OS_DISM_Wim-install
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
#>

dism /mount-wim /wimfile:C:\temp\!W10_1909\install.wim /mountdir:C:\temp\!W10_1909\MOUNT /index:1
dism /image:C:\Temp\!W10_1909\Mount /Get-ProvisionedAppxPackages > AppXPackages.txt

dism /image:C:\Temp\!W10_1909\Mount /Remove-ProvisionedAppxPackage /PackageName:Microsoft.MicrosoftOfficeHub_18.1901.1141.0_neutral_~_8wekyb3d8bbwe
dism /image:C:\Temp\!W10_1909\Mount /Remove-ProvisionedAppxPackage /PackageName:Microsoft.Office.OneNote_16001.11126.20076.0_neutral_~_8wekyb3d8bbwe
dism /image:C:\Temp\!W10_1909\Mount /Remove-ProvisionedAppxPackage /PackageName:Microsoft.SkypeApp_14.35.152.0_neutral_~_kzf8qxf38zg5c

dism /unmount-wim /mountdir:C:\Temp\!W10_1909\Mount /commit

dism /online /Get-ProvisionedAppxPackages > AppXPackages.txt
dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.MicrosoftOfficeHub_18.1901.1141.0_neutral_~_8wekyb3d8bbwe
dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.Office.OneNote_16001.11126.20076.0_neutral_~_8wekyb3d8bbwe
dism /online /Remove-ProvisionedAppxPackage /PackageName:Microsoft.SkypeApp_14.35.152.0_neutral_~_kzf8qxf38zg5c