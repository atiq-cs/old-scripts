<#
.SYNOPSIS
  Disguise files in specified location as if they are hidden in front of eyes!
  Also provide ways to restore/unmask them

.DESCRIPTION
  Created 2012 Jun

.EXAMPLE

.NOTES
  Deactivated extentsion: dext
  Rename files with that extension
  In the end, also deny users to access specified location through icacls

  Demonstrations,
  - Cleaning up file extensions
  - Recursive renames

#>

param(
  [parameter(Mandatory=$true)]
  [string] $action,
  [string] $expLoc,
)

# This is the extension all files are appended with
$suffixExt=".dext"

#######################################################################################################
#####################    Function Definition Starts       #####################################
#######################################################################################################

# Recursively append extension to file names; ignore directories inside
function AppendExtension([string] $targetDir) {
  if (Test-Path $targetDir) {
    Get-ChildItem -Recurse $targetDir | %{
      if ($_.PSIsContainer) {
        Write-Host "Ignoring directory`: `""$_.fullName"`""
      }
      else {
        $oldFileName = $_.fullName
        $newFileName = $oldFileName + $suffixExt
        if ($oldFileName.EndsWith($suffixExt)) {
          Write-Host "$oldFileName should not be renamed."
        }
        elseif (Test-Path $newFileName) {
          # Remove-Item $newFileName
          Write-Host "Another $newFileName already exists!"
          # Rename-Item $oldFileName $newFileName
        }
        else {
          Try {
            Rename-Item $oldFileName $newFileName
          }
          Catch {
            Write-Host "Caught exception`: old name = $oldFileName"
            Write-Host "Caught exception`: old name = $newFileName`r`n"
          }
        }
      }
    }
  }
  else {
    Write-Host -ForegroundColor DarkRed "Entx: directory $targetDir doesn't exist"
  }
}

# Recursively remove suffix from file names; ignore directories inside
function CleanExtension([string] $targetDir) {
  if (Test-Path $targetDir) {
    Get-ChildItem -Recurse $targetDir | %{
      if ($_.PSIsContainer) {
        Write-Host "Ignoring directory`: `"" $_.fullName"`""
      }
      else {
        $oldFileName = $_.fullName
        $newFileName = $oldFileName.Substring(0, $oldFileName.Length - $suffixExt.Length)
        if ($oldFileName.EndsWith($suffixExt) -eq $false) {
          Write-Host "$oldFileName should not be renamed."
        }
        elseif (Test-Path $newFileName) {
          # Remove-Item $newFileName
          Write-Host "Another $newFileName already exists!"
        }
        else {
          Rename-Item $oldFileName $newFileName
        }
      }
    }
  }
  else {
    Write-Host -ForegroundColor DarkRed "Entx: directory $targetDir doesn't exist"
  }
}

#####################    Function Definition Ends       #####################################
#######################################################################################################

# dissemble
if ($action.Equals("dsm")) {
  # AppendExtension("$expLoc\Music Videos")
  AppendExtension("$expLoc")
  icacls $expLoc /deny Users:F
  Write-Host "Dissemble procedure complete"
}

#unmask
elseif ($action.Equals("umsk")) {
  icacls $expLoc /grant Users:F
  CleanExtension("$expLoc")
  Write-Host "Unmasking procedure complete"
}
# unravel a secondary stash
elseif ($action.Equals("mov")) {
  # change this if you have a secondary hidden cache
  $expLoc = "F:\Ent\pristine\99\Eng mov"
  if (Test-Path $expLoc) {
    explorer $expLoc
  }
  else {
    Write-Host "Specified path does not exist!"
  }
}
elseif ($action.Equals("open")) {
  if (Test-Path $expLoc) {
    explorer $expLoc
  }
  else {
    Write-Host "Directory does not exist!"
  }
}
elseif ($action.Equals("gc")) {
  $gcCacheDir=${env:LOCALAPPDATA} + "\Google\Chrome\User Data\Default\Cache"
  if (Test-Path $gcCacheDir) {
    explorer $gcCacheDir
  }
  else {
    Write-Host "Cache directory does not exist!"
  }
}
# guess this script was abused for some application invokation as well
elseif ($action.Equals("tvc")) {
  $PlayerExe = "C:\Program Files\Total Video Converter\tvp.exe"
  if (Test-Path $PlayerExe) {
    & $PlayerExe
  }
  else {
    Write-Host "Cache directory does not exist!"
  }
}
else {
  Write-Host "`nEntx: Wrong command-line argument! Please check arguments.`n"
}
