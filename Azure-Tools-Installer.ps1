<#
.SYNOPSIS
Install Azure Tools.
.DESCRIPTION
First, you will need to install the Windows Package Manager (WinGet), if you don’t have winget already on your machine.Azure tools are installed using WinGet when setting up a new developer or administrator workstation. This also includes things like the Azure CLI or Azure PowerShell.
If you want to install the tools that I'm not using them, just delete the # from the starting line.
.NOTES
Name: Azure-Tools-Installer
Version: 1.0.0
Author: Andrei Pintica (@AndreiPintica)
#>

##### Install Azure Tools
winget install Microsoft.AzureStorageExplorer
# winget install Microsoft.AzureStorageEmulator
winget install Microsoft.AzureFunctionsCoreTools
winget install Microsoft.AzureDataStudio
# winget install Microsoft.AzureCosmosEmulator
# winget install Microsoft.azure-iot-explorer
winget install Microsoft.Bicep
winget install Microsoft.AzureCLI
# winget install Microsoft.ServiceFabricRuntime

##### Install AzCopy v10
Invoke-WebRequest -Uri "https://aka.ms/downloadazcopy-v10-windows" -OutFile AzCopy.zip -UseBasicParsing
Expand-Archive ./AzCopy.zip ./AzCopy -Force
mkdir "$home/AzCopy"
Get-ChildItem ./AzCopy/*/azcopy.exe | Move-Item -Destination "$home\AzCopy\AzCopy.exe"
$userenv = [System.Environment]::GetEnvironmentVariable("Path", "User")
[System.Environment]::SetEnvironmentVariable("PATH", $userenv + ";$home\AzCopy", "User")

##### Install PowerShell 7 and Azure PowerShell
winget install Microsoft.PowerShell
pwsh.exe
Install-Module Az

##### Install Windows Terminal
winget install Microsoft.WindowsTerminal

##### Install Git
winget install Git.Git
winget install GitHub.cli

##### Install Visual Studio Code
winget install Microsoft.VisualStudioCode

##### VS Code Extensions:
code --install-extension AzurePolicy.azurepolicyextension
code --install-extension ms-azuretools.vscode-azureresourcegroups
code --install-extension ms-azuretools.vscode-azurestorage
code --install-extension ms-azuretools.vscode-azurevirtualmachines
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-vscode-remote.remote-ssh-edit
code --install-extension ms-vscode-remote.remote-ssh-explorer
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
code --install-extension ms-vscode.azure-account
code --install-extension ms-vscode.azurecli
code --install-extension ms-vscode.powershell
code --install-extension ms-vscode.vscode-node-azure-pack
code --install-extension ms-vsliveshare.vsliveshare
code --install-extension ms-vsonline.vsonline
code --install-extension msazurermtools.azurerm-vscode-tools