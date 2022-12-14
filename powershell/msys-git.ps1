<#
.SYNOPSIS
  Invoke msys git cmd shell

.DESCRIPTION
  Created 2015

.EXAMPLE

.NOTES
  Manually changed Windows size to 140:36

  At present, git binary works just fine with Powershell. Hence, msys git
  cmd shell is deprecate IMO.

  Demonstrations,
  - Environment Variables

#>

# Turns out this setting location does not work.
# Hence, modifying D:\ProgramFiles_x86\msysgit\git-cmd.bat instead
# Push-Location
# Set-Location F:\Sourcecodes\git_ws
$MSysEnv = "${Env:ProgramFiles}\Git\git-cmd.exe"

# I have a `HOST_TYPE` Variable in my shells to identify which workstation I am at
# Personal Notebook
if ($HOST_TYPE.Equals("PC_NOTEBOOK")) {
  $MSysEnv = 'C:\PFilesX64\Git\git-cmd.exe'
}
# Office Workstation
elseif ($HOST_TYPE.Equals("OFFICE_WS")) {
  $MSysEnv = '${ProgramFiles(x86)}\Git\git-cmd.exe'
}

if (Test-Path $MSysEnv) {
  # set a preferred location
  pushd
  Set-Location D:\git_ws
  Start-Process $MSysEnv
  popd
  # restore powershell's location
}
else {
  Write-Host -ForegroundColor Red "Please install msysgit and run again!`r`n"
}

# Pop-Location
