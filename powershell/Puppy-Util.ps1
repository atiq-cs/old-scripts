<#
.SYNOPSIS
  Disable/Enable selected puppy image from USB Disk
.DESCRIPTION
  Date: 02/03/2013
  Supports following types
  - slacko puppy
  - fedora
  - brs_live (default) ?

.PARAMETER imageName
  Select an image to deply to USB Disk

.PARAMETER driverLetter
  USB driver letter

.EXAMPLE
  Puppy-Util -a disable -si bl -ud L
  Puppy-Util -a disable -si sp -ud L
  Puppy-Util -a enable -si bl -ud L
  Puppy-Util -a enable -si sp -ud L

.NOTES
  some dup code from bottom removed
#>

Param(
    [Parameter(Mandatory=$true)]
    [alias("a")]
    [string]$action,
    [Parameter(Mandatory=$true)]
    [alias("si")]
    [string]$imageName,
    [Parameter(Mandatory=$true)]
    [alias("ud")]
    [string]$driverLetter)


if ($action.Equals("disable")) {
    Write-Host "Action`t`t: Disable image"
}
elseif ($action.Equals("enable")) {
    Write-Host "Action`t`t: Enable image"
}
else {
    Write-Host "`Puppy-Util: Action invalid. Wrong command-line argument! Please check action argument.`n"
    break
}

# Disable BRS_LIVE Image
if ($imageName.Equals("bl")) {
    $brsLoc=$driverLetter + ":\brs_live528"
}
elseif ($imageName.Equals("sp")) {
    $brsLoc=$driverLetter + ":\slacko542"
}
elseif ($imageName.Equals("fc")) {
    $brsLoc=$driverLetter + ":\fc18"
}
else {
    Write-Host "`Puppy-Util: Image name not valid. Wrong command-line argument! Please check action argument.`n"
    break
}

Write-Host "Target Dir`t: $brsLoc`n"

if ((Test-Path -path $brsLoc -pathtype leaf) -or !(Test-Path $brsLoc)) {
    Write-Host "Please provide proper directory name of puppy image.`n"
    break
}

# Move files to the directory first
if ($action.Equals("disable")) {

    ls "$driverLetter`:\" | %{
        $fileName = $_.fullName

        if (Test-Path -path $fileName -pathtype leaf) {
            Move-Item $fileName $brsLoc
        }
    }
    sleep 1
}

$i = 0

ls $brsLoc | %{
    $i++
    [bool] $shouldRename = $true
    $oldName = $_.fullName

    if ($action.Equals("disable")) {
        $newName = "$brsLoc\"+$_+".dext"
        $shouldNotRename = $oldName.EndsWith(".dext")
    }
    elseif ($action.Equals("enable")) {
        $oldName = $_.fullName
        $shouldNotRename = !($oldName.EndsWith(".dext"))
        if ($shouldNotRename -eq $false) {
            #$newName = $oldName -replace 'something.*','something'
            $newName = $oldName.Substring(0,$oldName.LastIndexOf(".dext"))
            #$newName = $oldName.TrimEnd(".dext")
        }
    }

    if ($shouldNotRename) {
        Write-Host "$i.`t$oldName should not be renamed."
    }
    elseif (Test-Path $newName) {
        Remove-Item $newName
        Rename-Item $oldName $newName
    }
    else {
        Rename-Item $oldName $newName
    }

}

if ($action.Equals("enable")) {
    Move-Item "$brsLoc\*" "$driverLetter`:\"
}
