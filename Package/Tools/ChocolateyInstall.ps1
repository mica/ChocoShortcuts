$InstallDir = [Environment]::GetFolderPath('Desktop')+'\Chocolatey Shortcuts'
Install-ChocolateyShortcut `
  -ShortcutFilePath "$InstallDir\+Add Package Shortcuts.lnk" `
  -TargetPath 'CMD' `
  -Arguments "/C PowerShell `"SL -PSPath `'%CD%`'; `$Path = (GL).Path; SL ~; Start PowerShell -Verb RunAs -Args \`"-NoProfile -ExecutionPolicy Unrestricted `"SL -PSPath `'`"`$Path`"`'; & `'`"%ChocolateyInstall%\lib\ChocoShortcuts\Tools\ChocoShortcuts.ps1`"`' 1`"\`"`"" `
  -IconLocation '%ProgramData%\chocolatey\choco.exe'
Install-ChocolateyShortcut `
  -ShortcutFilePath "$InstallDir\+Check for Package Updates.lnk" `
  -TargetPath 'CMD' `
  -Arguments "/C PowerShell `"SL -PSPath `'%CD%`'; `$Path = (GL).Path; SL ~; Start PowerShell -Verb RunAs -Args \`"-NoProfile -ExecutionPolicy Unrestricted `"SL -PSPath `'`"`$Path`"`'; & `'`"%ChocolateyInstall%\lib\ChocoShortcuts\Tools\ChocoShortcuts.ps1`"`' 2`"\`"`"" `
  -IconLocation '%ProgramData%\chocolatey\choco.exe'
Invoke-Item $InstallDir
