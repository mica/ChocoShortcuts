# Chocolatey Shortcuts v0.1
# https://github.com/mica/ChocoShortcuts/

function Check {
    if ($App -eq $null) {
        $Header
        'Launch this script via shortcuts to manage Chocolatey packages'
        ''
        'Enter [1] to generate the initial "Add" and "Check" shortcuts'
        'Or press [Enter] to exit'
        $Entry = Read-Host
        if ($Entry -eq '1') {
            Add-Type -AssemblyName System.Windows.Forms
            $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
                Description = "Choose a folder for your Chocolatey shortcuts`r`nMove or rename it anytime "+[char]0x2013+" it's portable!"
            }
            [void]$FolderBrowser.ShowDialog()
            $InstallDir = $FolderBrowser.SelectedPath
            if ($InstallDir -eq '') {
                Clear-Host
                Check
            }
            else {
                $WScriptShell = New-Object -ComObject WScript.Shell
                $Shortcut = $WScriptShell.CreateShortcut("$InstallDir\+Add Package Shortcuts.lnk")
                $Shortcut.TargetPath = 'powershell.exe'
                $Shortcut.Arguments = "-Command `"`$WDir = Get-Location | Select-Object -ExpandProperty Path; Start-Process powershell.exe -Verb RunAs -ArgumentList \`"-NoProfile -ExecutionPolicy Unrestricted -Command `"```$App = `'1`'; Set-Location `'`"`$WDir`"`'; `& `'`"%ChocolateyInstall%\lib\ChocoShortcuts\Tools\ChocoShortcuts.ps1`"`'`"\`"`""
                $Shortcut.IconLocation = '%ProgramData%\chocolatey\choco.exe'
                $Shortcut.Save()
                $Shortcut = $WScriptShell.CreateShortcut("$InstallDir\+Check for Package Updates.lnk")
                $Shortcut.TargetPath = 'powershell.exe'
                $Shortcut.Arguments = "-Command `"`$WDir = Get-Location | Select-Object -ExpandProperty Path; Start-Process powershell.exe -Verb RunAs -ArgumentList \`"-NoProfile -ExecutionPolicy Unrestricted -Command `"```$App = `'2`'; Set-Location `'`"`$WDir`"`'; `& `'`"%ChocolateyInstall%\lib\ChocoShortcuts\Tools\ChocoShortcuts.ps1`"`'`"\`"`""
                $Shortcut.IconLocation = '%ProgramData%\chocolatey\choco.exe'
                $Shortcut.Save()
                Clear-Host
                $Header
                "Shortcuts have been created in $InstallDir"
                ''
                'Enter [1] to open the folder'
                'Or press [Enter] to exit'
                $Entry = Read-Host
                if ($Entry -eq '1') {
                    Invoke-Item $InstallDir
                    Exit
                }
                else {
                    Exit
                }
            }
        }
        elseif ($Entry -eq '') {
            Exit
        }
        else {
            Clear-Host
            Check
        }
    }
    elseif ($App -eq '1') {
        $Header
        AddNew
    }
    elseif ($App -eq '2') {
        UpdateCheck
    }
    $Header
    "Checking Chocolatey.org for $App..."
    $Check = (choco upgrade $App -noop -r) -split '\|'
    if ($Check -join '' -match 'not found with') {
        Clear-Host
        $Header
        "$App was not found on Chocolatey.org"
        'Either the repository was inaccessible' 
        'Or your shortcut has an incorrect package ID'
        ''
        'Enter [1] to try again'
        "Enter [2] to delete the $App shortcut and create a new one"
        'Or press [Enter] to exit'
        $Entry = Read-Host
        if ($Entry -eq '1') {
            Clear-Host
            Check
        }
        elseif ($Entry -eq '2') {
            Remove-Item ".\$App.lnk"
            Clear-Host
            $Header
            AddNew
        }
    }
    elseif ($Check -join '' -match 'would have'){
        $Avail = (choco list $App -e -r) -replace '^.*\|','v'
        Install
    }
    elseif ($Check[1] -eq $Check[2]) {
        $Curr = 'v' + $Check[1]
        UpToDate
    }
    elseif ($Check[1] -ne $Check[2]) {
        $Curr = 'v' + $Check[1]
        $Avail = 'v' + $Check[2]
        Update
    }
}

function Install {
    Clear-Host
    $Header
    "$App is not installed"
    ''
    "Enter [1] to install $Avail" 
    'Or press [Enter] to exit'
    $Entry = Read-Host
    if ($Entry -eq '1') {
        Clear-Host
        $Header
        choco install $App -y
        Read-Host "`r`nPress [Enter] to exit"
        Exit
    }
    elseif ($Entry -eq '') {
        Exit
    }
    else {
        Install
    }
}

function UpToDate {
    Clear-Host
    $Header
    "$App $Curr is installed"
    'No updates are available'
    ''
    "Enter [2] to uninstall $App"
    'Or press [Enter] to exit'
    $Entry = Read-Host
    if ($Entry -eq '2') {
        Clear-Host
        $Header
        choco uninstall $App -y -x -a
        Read-Host "`r`nPress [Enter] to exit"
        Exit
    }
    elseif ($Entry -eq '') {
        Exit
    }
    else {
        UpToDate
    }
}

function Update {
    Clear-Host
    $Header
    "$App $Curr is installed"
    "The $Avail update is available"
    ''
    "Enter [1] to update $App"
    "Enter [2] to uninstall $App"
    'Or press [Enter] to exit'
    $Entry = Read-Host
    if ($Entry -eq '1') {
        Clear-Host
        $Header
        choco upgrade $App -y
        Read-Host "`r`nPress [Enter] to exit"
        Exit
    }
    elseif ($Entry -eq '2') {
        Clear-Host
        $Header
        choco uninstall $App -y -x -a
        Read-Host "`r`nPress [Enter] to exit"
        Exit
    }
    elseif ($Entry -eq '') {
        Exit
    }
    else {
        Update
    }
}

function AddNew {
    'Create new shortcuts for installing/updating/uninstalling packages:'
    ''
    'Enter the [ID] of one or more (comma separated) packages'
    'Enter [1] to search Chocolatey.org for package IDs'
    'Enter [2] to make shortcuts for all currently installed packages'
    'Or press [Enter] to exit'
    $Entry = Read-Host
    if ($Entry -eq '1') {
        Search
    }
    elseif ($Entry -eq '2') {
        $Entry = (choco list -l -r | Where-Object {$_ -notmatch '.install'}) -replace '\|.*$' -join ','
        Generate
    }
    elseif ($Entry -eq '') {
        Exit
    }
    else {
        Generate
    }

}

function Generate {
    Clear-Host
    $Header
    ForEach ($Package in $Entry -split ',' -replace '\s') {
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut("$WDir\$Package.lnk")
        $Shortcut.TargetPath = 'powershell.exe'
        $Shortcut.Arguments = "-Command `"`$WDir = Get-Location | Select-Object -ExpandProperty Path; Start-Process powershell.exe -Verb RunAs -ArgumentList \`"-NoProfile -ExecutionPolicy Unrestricted -Command `"```$App = `'$Package`'; Set-Location `'`"`$WDir`"`'; `& `'`"%ChocolateyInstall%\lib\ChocoShortcuts\Tools\ChocoShortcuts.ps1`"`'`"\`"`""
        $Shortcut.IconLocation = '%ProgramData%\chocolatey\choco.exe'
        $Shortcut.Save()
    }
    "Shortcuts have been created in $WDir"
    ''
    'Enter [1] to open the folder'
    'Enter [2] to create more shortcuts'
    'Or press [Enter] to exit'
    $Entry = Read-Host
    if ($Entry -eq '1') {
        Invoke-Item $WDir
        Clear-Host
        $Header
        AddNew
    }
    elseif ($Entry -eq '2') {
        Clear-Host
        $Header
        AddNew
    }
    elseif ($Entry -eq '') {
        Exit
    }
    else {
        Clear-Host
        $Header
        AddNew
    }
}

function Search {
    Clear-Host
    $Header
    $Search = Read-Host 'Search for packages'
    if ($Search -eq '') {
        Clear-Host
        $Header
        AddNew
    }
    else {
        (choco list $Search -r) -replace '\|',' (v' -replace '$',')'
        AddNew
    }
}

function UpdateCheck {
    Clear-Host
    $Header
    'Checking Chocolatey.org for updates...'
    $Outdated = choco outdated -r | Where-Object {$_ -notmatch '.install'}
    if ($Outdated[3] -eq $null) {
        Clear-Host
        $Header
        'No updates are available'
        Read-Host "`r`nPress [Enter] to exit"
        Exit
    }
    else {
        $Updates = ForEach ($Package in $Outdated[3..($Outdated.Length)]) {
            $Package -replace '\|(\d*\.)*\d*\|',' v' -replace '\|\D*$'
        }
        if ($Updates -isnot [system.array]) {
            Clear-Host
            $Header
            'An update is available:'
            $Updates
            ''
            'Enter [1] to update'
            'Or press [Enter] to exit'
            $Entry = Read-Host
            if ($Entry -eq '1') {
                Clear-Host
                $Header                
                choco upgrade -y ($Updates -replace ' v.*$')
                Read-Host "`r`nPress [Enter] to exit"
                Exit
            }
            else {
                Exit
            } 
        }
        else {
            UpdateAll
        }
    }
}

function UpdateAll {
    Clear-Host
    $Header
    'The following updates are available:'
    $Updates
    ''
    'Enter [1] to update all packages'
    'Enter [2] to select packages to update'
    'Or press [Enter] to exit'
    $Entry = Read-Host
    if ($Entry -eq '1') {
        Clear-Host
        $Header
        'Installing the following updates:'
        $Updates
        ''
        ForEach ($Package in $Updates) {
            choco upgrade -y ($Package -replace ' v.*$')
        }
        ''
        'Updates are complete'
        Read-Host "`r`nPress [Enter] to exit"
        Exit
    }
    elseif ($Entry -eq '2') {
        UpdateSelect
    }
    elseif ($Entry -eq '') {
        Exit
    }
    else {
        UpdateAll
    }
}

function UpdateSelect {
    Clear-Host
    $Header
    'Enter the (comma separated) numbers of one or more packages'
    ''
    ForEach ($Package in $Updates) {
        $Selector++
        "[$Selector] $Package"
    }
    ''
    'Or press [Enter] to go back'
    $Entry = Read-Host
    if ($Entry -eq '') {
        $Selector = 0
        UpdateAll
    }
    elseif ($Entry -notmatch '[^\d\s,]') {
        $Number = ForEach ($Selector in ($Entry -split ',' -replace '\s')) {
            $Selector - 1 -as [int]
        }
        Clear-Host
        $Header
        'Installing the following updates:'
        $Updates[$Number]
        ''
        ForEach ($Package in ($Updates[$Number] -replace ' v\d.*$')) {
            choco upgrade -y $Package
        }
        ''
        'Updates are complete'
        Read-Host "`r`nPress [Enter] to exit"
        Exit
    }
    else {
        $Selector = 0
        UpdateSelect
    }
}
$WDir = Get-Location | Select-Object -ExpandProperty Path
$Header = @'
 Chocolatey Shortcuts
~~~~~~~~~~~~~~~~~~~~~~~
'@
Check