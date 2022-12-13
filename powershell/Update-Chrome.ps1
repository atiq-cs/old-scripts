<#
.SYNOPSIS
  Update Google Chrome using logout script

.DESCRIPTION
  Date: 06/11/2011

.EXAMPLE
  Update-Software.ps1 -component ffmpeg

.NOTES
  Manual procedure of chrome update
#>

$uninstallGCPath="$Env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Google Chrome\Uninstall Google Chrome.lnk"

if (Test-Path $uninstallGCPath) {
    cp $uninstallGCPath ungc.lnk
    echo "Google Chrome update request has been queued."
    echo "Uninstall will be performed during logout."
    echo "Update will be performed on next login."
}
else {
    echo "Error! Google Chrome uninstaller shortcut doesn't exist!"
}

<# And, we had this in `logout.ps1` to run the uninstall binary,

# Uninstall Google Chrome if requested
$uninstallGCPath="$env:PS_SC_DIR\ungc.lnk"

if (Test-Path $uninstallGCPath) {
  Write-Host "Processing Google Chrome uninstall request"
  & $uninstallGCPath
}
#>
