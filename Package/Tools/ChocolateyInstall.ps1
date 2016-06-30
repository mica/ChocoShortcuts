$InstallDir = [Environment]::GetFolderPath('Desktop')+'\Chocolatey Shortcuts'

Install-ChocolateyShortcut `
  -ShortcutFilePath "$InstallDir\+Add Package Shortcuts.lnk" `
  -TargetPath 'powershell.exe' `
  -Arguments "-Command `"`$WDir = Get-Location | Select-Object -ExpandProperty Path; Start-Process powershell.exe -Verb RunAs -ArgumentList \`"-NoProfile -ExecutionPolicy Unrestricted -Command `"```$App = `'1`'; Set-Location `'`"`$WDir`"`'; `& `'`"%ChocolateyInstall%\lib\ChocoShortcuts\Tools\ChocoShortcuts.ps1`"`'`"\`"`"" `
  -IconLocation '%ProgramData%\chocolatey\choco.exe' `

Install-ChocolateyShortcut `
  -ShortcutFilePath "$InstallDir\+Check for Package Updates.lnk" `
  -TargetPath 'powershell.exe' `
  -Arguments "-Command `"`$WDir = Get-Location | Select-Object -ExpandProperty Path; Start-Process powershell.exe -Verb RunAs -ArgumentList \`"-NoProfile -ExecutionPolicy Unrestricted -Command `"```$App = `'2`'; Set-Location `'`"`$WDir`"`'; `& `'`"%ChocolateyInstall%\lib\ChocoShortcuts\Tools\ChocoShortcuts.ps1`"`'`"\`"`"" `
  -IconLocation '%ProgramData%\chocolatey\choco.exe' `

Invoke-Item $InstallDir