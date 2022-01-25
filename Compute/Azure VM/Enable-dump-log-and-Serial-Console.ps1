<#
.Description
To enable dump log and Serial Console, run the following script.
#>

reg load HKLM\BROKENSYSTEM F:\windows\system32\config\SYSTEM

REM Enable Serial Console
bcdedit /store F:\boot\bcd /set {bootmgr} displaybootmenu yes
bcdedit /store F:\boot\bcd /set {bootmgr} timeout 5
bcdedit /store F:\boot\bcd /set {bootmgr} bootems yes
bcdedit /store F:\boot\bcd /ems {<BOOT LOADER IDENTIFIER>} ON
bcdedit /store F:\boot\bcd /emssettings EMSPORT:1 EMSBAUDRATE:115200

REM Suggested configuration to enable OS Dump
REG ADD "HKLM\BROKENSYSTEM\ControlSet001\Control\CrashControl" /v CrashDumpEnabled /t REG_DWORD /d 1 /f
REG ADD "HKLM\BROKENSYSTEM\ControlSet001\Control\CrashControl" /v DumpFile /t REG_EXPAND_SZ /d "%SystemRoot%\MEMORY.DMP" /f
REG ADD "HKLM\BROKENSYSTEM\ControlSet001\Control\CrashControl" /v NMICrashDump /t REG_DWORD /d 1 /f

REG ADD "HKLM\BROKENSYSTEM\ControlSet002\Control\CrashControl" /v CrashDumpEnabled /t REG_DWORD /d 1 /f
REG ADD "HKLM\BROKENSYSTEM\ControlSet002\Control\CrashControl" /v DumpFile /t REG_EXPAND_SZ /d "%SystemRoot%\MEMORY.DMP" /f
REG ADD "HKLM\BROKENSYSTEM\ControlSet002\Control\CrashControl" /v NMICrashDump /t REG_DWORD /d 1 /f

reg unload HKLM\BROKENSYSTEM
