$dir = "$env:USERPROFILE\Desktop\Chocolatey Shortcuts"
$lnk1 = "$dir\+Add Package Shortcuts.lnk"
$lnk2 = "$dir\+Check for Package Updates.lnk"
if (Test-Path $dir) {
    if ((((Get-ChildItem $dir).Length -le 2) -and (Test-Path $lnk1) -and (Test-Path $lnk2)) -or (Get-ChildItem $dir).Length -eq 0) {
        Remove-Item $dir -Recurse
    }
}
