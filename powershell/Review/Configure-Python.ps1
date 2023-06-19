<#
.SYNOPSIS
  Configures python env

.DESCRIPTION
  Updated 2013 and 2014
    Configures python environment into the powershell:
        1. adds python path to the environment variable
        2. change location to 

.EXAMPLE
  python.ps1 -Version 2
  python.ps1 v2

.NOTES
   Deprecated by: Init-App.ps1
   Not seeing anything to publish from this one.
#>

Param(
    [Parameter(Mandatory=$false)] [alias("-Version")] [string]$Version)

if ($Version.Equals("2") -or $Version.Equals("v2")) {
    if ($HOST_TYPE.Equals("PC_NOTEBOOK")) {
        $python_src_location = 'F:\Sourcecodes\python'
        $python_exe_path = 'D:\ProgramFiles\Python27'
    }
    elseif ($HOST_TYPE.Equals("VSINC_SERVER_2008")) {
        $python_src_location = 'X:\Sourcecode\python_ws'
        $python_exe_path = 'X:\bin\Python27'
    }
}

else {
    if ($HOST_TYPE.Equals("PC_NOTEBOOK")) {
        $python_src_location = 'F:\Sourcecodes\python\python_project_ws'
        $python_exe_path = 'D:\ProgramFiles\Python34'
    }
    elseif ($HOST_TYPE.Equals("VSINC_SERVER_2008")) {
        # $python_src_location = 'X:\Sourcecode\python_ws'
        $python_src_location = 'X:\Sourcecode\p05_git_ws\trunk\Project-05\clickstream-mining\test-code'
        $python_exe_path = 'X:\bin\Python34'
    }
}

if (Test-Path $python_src_location) { Set-Location $python_src_location }
else { Write-Host -ForegroundColor Yellow "Python source does not exist. Please fix path and change directory!`r`n"; }

if (-not (Test-Path $python_exe_path)) { Write-Host -ForegroundColor Red "Python binary does not exist. Please exe path!`r`n"; break; }

$sys_path_variable = [string] $env:Path
# Write-Host $sys_path_variable
if ($sys_path_variable.Contains($python_exe_path)) {
    python --version
    Write-Host "Path is already set!"
}
else {
    # switch to 2 from 3
    # $env:Path = $env:Path.Replace('D:\ProgramFiles\Python34', 'D:\ProgramFiles\Python27')
    $env:path += ";"+$python_exe_path
}


<#else {
    Start-Process cmd
    popd
    & "C:\Python33\python.exe" X:\python_src\BayesianNet\wordCross.py --print_cpt
}
#>
