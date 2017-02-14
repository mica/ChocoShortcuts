# Chocolatey Shortcuts v0.2
# https://github.com/mica/ChocoShortcuts/

param([Parameter(Position = 0)] [string]$App = $App, [string]$Opt)
$WDir = (Get-Location).Path
function Header {
    Write-Host '  ║' -ForegroundColor DarkGreen -NoNewline
    Write-Host ' Chocolatey Shortcuts' -ForegroundColor Green -NoNewline
    Write-Host ' ║' -ForegroundColor DarkGreen
    Write-Host '  ╙──────────────────────╜' -ForegroundColor DarkGreen
}
function y {
    Write-Host $Args -NoNewline -ForegroundColor Yellow
}
function w {
    Write-Host $Args -NoNewline
}
function Check {
    Clear-Host; Header
    if ($App -eq '') {
        'Launch this script via the shortcuts that were created on the desktop at installaion';''
        (w 'Enter ')+(y '1 ')+'to regenerate those shortcuts to a folder of your choice'
        (w 'Enter a ')+(y 'package ID ')+'to manage it sans shortcut'
        (w 'Or press ')+(y 'Enter ')+'to exit'
        $Entry = Read-Host "`n"
        if ($Entry -eq '') {
            Exit
        }
        elseif ($Entry -eq '1') {
            Add-Type -AssemblyName System.Windows.Forms
            $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
                Description = "Choose an inital location for your shortcuts folder`nYou may move or rename it any time"
            }
            [void]$FolderBrowser.ShowDialog()
            $InstallDir = $FolderBrowser.SelectedPath
            if ($InstallDir -eq '') {
                Check
            }
            else {
                $WScriptShell = New-Object -ComObject WScript.Shell
                $Shortcut = $WScriptShell.CreateShortcut("$InstallDir\+Add Package Shortcuts.lnk")
                $Shortcut.TargetPath = 'CMD'
                $Shortcut.Arguments = "/C PowerShell `"SL -PSPath `'%CD%`'; `$Path = (GL).Path; SL ~; Start PowerShell -Verb RunAs -Args \`"-NoProfile -ExecutionPolicy Unrestricted `"SL -PSPath `'`"`$Path`"`'; & `'`"%ChocolateyInstall%\lib\ChocoShortcuts\Tools\ChocoShortcuts.ps1`"`' 1`"\`"`""
                $Shortcut.IconLocation = '%ProgramData%\chocolatey\choco.exe'
                $Shortcut.Save()
                $Shortcut = $WScriptShell.CreateShortcut("$InstallDir\+Check for Package Updates.lnk")
                $Shortcut.TargetPath = 'CMD'
                $Shortcut.Arguments = "/C PowerShell `"SL -PSPath `'%CD%`'; `$Path = (GL).Path; SL ~; Start PowerShell -Verb RunAs -Args \`"-NoProfile -ExecutionPolicy Unrestricted `"SL -PSPath `'`"`$Path`"`'; & `'`"%ChocolateyInstall%\lib\ChocoShortcuts\Tools\ChocoShortcuts.ps1`"`' 2`"\`"`""
                $Shortcut.IconLocation = '%ProgramData%\chocolatey\choco.exe'
                $Shortcut.Save()
                Clear-Host; Header
                "Shortcuts have been created in $InstallDir";''
                (w 'Enter ')+(y '1 ')+'to open the folder'
                (w 'Or press ')+(y 'Enter ')+'to exit'
                $Entry = Read-Host "`n"
                if ($Entry -eq '1') {
                    Invoke-Item $InstallDir
                    Exit
                }
                else {
                    Exit
                }
            }
        }
        else {
            $App = $Entry
            Check
        }
    }
    elseif ($App -eq '1') {
        AddNew
    }
    elseif ($App -eq '2') {
        UpdateCheck
    }
    "Checking Chocolatey.org for $App..."
    $Check = (choco upgrade $App --noop -r) -split '\|'
    if ($Check -join '' -match 'not found with') {
        Clear-Host; Header
        "$App was not found on Chocolatey.org"
        '  Either the repository is inaccessible' 
        '  Or your shortcut''s package ID is invalid';''
        (w 'Enter ')+(y '1 ')+"to check again for $App on Chocolatey.org"
        (w 'Enter ')+(y '2 ')+"to delete the $App shortcut and create a new one"
        (w 'Or press ')+(y 'Enter ')+'to exit'
        $Entry = Read-Host "`n"
        if ($Entry -eq '1') {
            Check
        }
        elseif ($Entry -eq '2') {
            Remove-Item ".\$App.lnk"
            Clear-Host; Header
            AddNew
        }
        else {
            Exit
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
    Clear-Host; Header
    "$App is not installed";''
    (w 'Enter ')+(y '1 ')+"to install $Avail"
    (w 'Enter ')+(y '2 ')+'to install with options'
    (w 'Or press ')+(y 'Enter ')+'to exit'
    $Entry = Read-Host "`n"
    if ($Entry -eq '1') {
        Clear-Host; Header
        Invoke-Expression "choco install $App $Opt -r -y";''
        (w 'Press ')+(y 'Enter ')+'to exit'; Read-Host
        Exit
    }
    elseif ($Entry -eq '2') {
        Clear-Host; Header
        "Your shortcut is configured to install using:"
        Write-Host "  choco install $App -y -r $Opt" -ForegroundColor Cyan;''
        (w 'Enter additional ')+(y 'options')+''
        (w 'Or press ')+(y 'Enter ')+'to cancel'
        $Entry = Read-Host "`n"
        if ($Entry -eq '') {
            Install
        }
        else {
            $ExtOpt = $Entry
            (w 'Enter ')+(y '1 ')+"to begin installation with: $ExtOpt"
            (w 'Or press ')+(y 'Enter ')+'to cancel'
            $Entry = Read-Host "`n"
            if ($Entry -eq '') {
                Install
            }
            elseif ($Entry -eq '1') {
                Clear-Host; Header
                Invoke-Expression "choco install $App $Opt $ExtOpt -r -y";''
                (w 'Press ')+(y 'Enter ')+'to exit'; Read-Host
                Exit
            }

        }

        
    }
    elseif ($Entry -eq '') {
        Exit
    }
    else {
        Install
    }
}
function UpToDate {
    Clear-Host; Header
    "$App $Curr is installed";''
    '  No updates are available';''
    (w 'Enter ')+(y '2 ')+"to uninstall $App"
    (w 'Or press ')+(y 'Enter ')+'to exit'
    $Entry = Read-Host "`n"
    if ($Entry -eq '2') {
        Clear-Host; Header
        choco uninstall $App -r -a -x -y;''
        (w 'Press ')+(y 'Enter ')+'to exit'; Read-Host
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
    Clear-Host; Header
    "$App $Curr is installed";''
    "  The $Avail update is available";''
    (w 'Enter ')+(y '1 ')+'to install the update'
    (w 'Enter ')+(y '2 ')+"to uninstall $App"
    (w 'Or press ')+(y 'Enter ')+'to exit'
    $Entry = Read-Host "`n"
    if ($Entry -eq '1') {
        Clear-Host; Header
        choco upgrade $App -r -y;''
        (w 'Press ')+(y 'Enter ')+'to exit'; Read-Host
        Exit
    }
    elseif ($Entry -eq '2') {
        Clear-Host; Header
        choco uninstall $App -r -a -x -y;''
        (w 'Press ')+(y 'Enter ')+'to exit'; Read-Host
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
    'Create new shortcuts for installing, updating, or uninstalling packages';''
    (w 'Enter one or more comma separated ')+(y 'package ID')+(w ', optionally, w/ ')+(y 'options ')+'(excluding -y and -r)'
    (w 'Enter ')+(y '1 ')+'to search for package IDs on the Chocolatey.org repository'
    (w 'Enter ')+(y '2 ')+'to generate shortcuts for all currently installed packages'
    (w 'Or press ')+(y 'Enter ')+'to exit'
    $Entry = Read-Host "`n"
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
    Clear-Host; Header
    ForEach ($Item in $Entry -split ',') {
        $Items = $Item.Split('',[System.StringSplitOptions]::RemoveEmptyEntries)
        $Package = $Items[0]
        $Params = " -Opt `'" + ($Items[1..$Items.Length] -join ' ' -replace "`'","`'`'") + "`'"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut("$WDir\$Package.lnk")
        $Shortcut.TargetPath = 'CMD'
        $Shortcut.Arguments = "/C PowerShell `"SL -PSPath `'%CD%`'; `$Path = (GL).Path; SL ~; Start PowerShell -Verb RunAs -Args \`"-NoProfile -ExecutionPolicy Unrestricted `"SL -PSPath `'`"`$Path`"`'; & `'`"%ChocolateyInstall%\lib\ChocoShortcuts\Tools\ChocoShortcuts.ps1`"`' $Package $Params`"\`"`""
        $Shortcut.IconLocation = '%ProgramData%\chocolatey\choco.exe'
        $Shortcut.Save()
    }
    "Shortcuts have been created in $WDir";''
    (w 'Enter ')+(y '1 ')+'to open the folder'
    (w 'Enter ')+(y '2 ')+'to create another shortcut'
    (w 'Or press ')+(y 'Enter ')+'to exit'
    $Entry = Read-Host "`n"
    if ($Entry -eq '1') {
        Invoke-Item $WDir
        Clear-Host; Header
        AddNew
    }
    elseif ($Entry -eq '2') {
        Clear-Host; Header
        AddNew
    }
    elseif ($Entry -eq '') {
        Exit
    }
    else {
        Clear-Host; Header
        AddNew
    }
}
function Search {
    Clear-Host; Header
    (w 'Enter your ')+(y 'search terms')+''
    (w 'Or press ')+(y 'Enter ')+'to cancel';''
    $Search = Read-Host
    if ($Search -eq '') {
        Clear-Host; Header
        AddNew
    }
    else {
        Clear-Host; Header
        "Searching for ""$Search"""       
        $Results = choco list $Search -r
        if ($Results -eq $null) {
            Clear-Host; Header
            "No results for ""$Search"""
            (w 'Press ')+(y 'Enter ')+'to cancel'; Read-Host
            Search
        }
        else {
            Clear-Host; Header
            "Search results for ""$Search"":";''
            $Results -replace '\|',' (v' -replace '$',')';'' 
            AddNew
        }
    }
}
function UpdateCheck {
    Clear-Host; Header
    'Checking Chocolatey.org for updates...'
    $Outdated = choco outdated -r | Where-Object {$_ -notmatch '.install'}
    if ($Outdated[3] -eq $null) {
        Clear-Host; Header
        'No updates are available';''
        (w 'Press ')+(y 'Enter ')+'to exit'; Read-Host
        Exit
    }
    else {
        $Updates = ForEach ($Package in $Outdated[3..($Outdated.Length)]) {
            $Package -replace '\|(\d*\.)*\d*\|',' v' -replace '\|\D*$'
        }
        if ($Updates -isnot [system.array]) {
            Clear-Host; Header
            'An update is available:';''
            "  $Updates";''
            (w 'Enter ')+(y '1 ')+'to install the update'
            (w 'Or press ')+(y 'Enter ')+'to exit'
            $Entry = Read-Host "`n"
            if ($Entry -eq '1') {
                Clear-Host; Header                
                choco upgrade ($Updates -replace ' v.*$') -r -y;''
                (w 'Press ')+(y 'Enter ')+'to exit'; Read-Host
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
    Clear-Host; Header
    'The following updates are available:';''
    $Updates;''
    (w 'Enter ')+(y '1 ')+'to install all updates'
    (w 'Enter ')+(y '2 ')+'to select updates to install'
    (w 'Or press ')+(y 'Enter ')+'to exit'
    $Entry = Read-Host "`n"
    if ($Entry -eq '1') {
        Clear-Host; Header
        'Installing:'
        $Updates;''
        ForEach ($Package in $Updates) {
            choco upgrade ($Package -replace ' v.*$') -r -y
        }
        '';'Installation complete';''
        (w 'Press ')+(y 'Enter ')+'to exit'; Read-Host
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
    Clear-Host; Header
    'Enter the comma separated numbers of one or more updates to install:';''
    ForEach ($Package in $Updates) {
        $Selector++
        (w ' ')+(y $Selector)+". $Package"
    }
    '';(w 'Or press ')+(y 'Enter ')+'to cancel'
    $Entry = Read-Host "`n"
    if ($Entry -eq '') {
        $Selector = 0
        UpdateAll
    }
    elseif ($Entry -notmatch '[^\d\s,]') {
        $Number = ForEach ($Selector in ($Entry -split ',' -replace '\s')) {
            $Selector - 1 -as [int]
        }
        Clear-Host; Header
        'Installing:'
        $Updates[$Number];''
        ForEach ($Package in ($Updates[$Number] -replace ' v\d.*$')) {
            choco upgrade $Package -r -y
        }
        '';'Installation complete';''
        (w 'Press ')+(y 'Enter ')+'to exit'; Read-Host
        Exit
    }
    else {
        $Selector = 0
        UpdateSelect
    }
}
Check
