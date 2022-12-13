<#
.SYNOPSIS
  Update depot_tools using SVN
.DESCRIPTION
  Date: 06/22/2011
  This tools comes as part of chromium/v8 project

.EXAMPLE
  Update-SVN.ps1

.NOTES
  It's here for historical significance
#>

$prepath = $Env:Path
$depopath = "$env:PS_SC_DRIVE\Sourcecodes\Chrome\depot_tools"
$olddepopath = "$env:PS_SC_DRIVE\Sourcecodes\Chrome\depot_tools_before_update"

# Based on Env:Path from System
$Env:Path = "%SystemRoot%\system32\WindowsPowerShell\v1.0\;C:\Program Files\Common Files\Microsoft Shared\Windows Live;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Program Files\Windows Live\Shared;$olddepopath"

# Not sure why we would need to wait 5 seconds before running `svn update`
#.\Delay.exe 5
svn update $depopath

# restore path
$Env:Path = $prepath
