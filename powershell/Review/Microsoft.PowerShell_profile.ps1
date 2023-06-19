<#
.SYNOPSIS
Initialize powershell environment
.DESCRIPTION
Initialize and provide frequently access methods

Optimized way to do this would be to declare an env Variable containing ps sc dir and based on
the name of the dir we decide what type of workstation it is and the names

Goals:
- reduce code in profile file
.EXAMPLE
Run `Console` from Win Run Dialog

.NOTES

#>

$PHOST = 'matrix'

# get the last part of path
function get-diralias ([string] $loc) {
  # check if we are in our home script dir; yes: return grave sign
  if ($loc.Equals($Env:PS_SC_DIR)) { return "~" }
    
  # if it ends with \ that means we are in root of drive
  # in that case return drive
  if ($loc.EndsWith("\")) { return $loc.Substring(0, $loc.Length-1) }
  # for ref
  #if (($lastindex = [int] $loc.lastindexof('\')) -ne -1) { return $loc.Substring(0, $lastindex) }
    
  # Otherwise return only the dir name
  $lastindex = [int] $loc.lastindexof('\') + 1
  return $loc.Substring($lastindex)
}

# Set prompt
function prompt {
    return "[atiq@" + $PHOST + " $(get-diralias($(get-location)))]$ "
}

# Global definition script path
$HOST_TYPE = "PC_NOTEBOOK"

if (Test-path 'D:\Code\office_marker.txt') {
  # Set-ExecutionPolicy -Scope CurrentUser Unrestricted
  # In some workplaces this might be required
  # Set-ExecutionPolicy Bypass -Scope Process
  $HOST_TYPE = "OFFICE_WS"
}
# Variable test for sinc site, only consider virtual sinc site
elseif (Test-path X:\bin\sinc_site_true.conf) {
    Set-ExecutionPolicy Bypass -Scope Process
    $HOST_TYPE = "VSINC_SERVER_2008"
}

# Set sourcecode drive, usually in my systems I use a separate drive for source
# Will be over-riden by office net check as long as single PC is used
$PS_SC_DRIVE="D:"
if ($HOST_TYPE.Equals("PC_NOTEBOOK")) {
  $SC_DIR = "git_ws\fftsys_ws\PowerShell"
}
elseif ($HOST_TYPE.Equals("OFFICE_WS")) {
  $SC_DIR = "Code\fftsys_ws\PowerShell"
  $PHOST = 'fb'
}
elseif ($HOST_TYPE.Equals("VSINC_SERVER_2008")) {
  $PS_SC_DRIVE="X:"
  $SC_DIR = "git_ws\fftsys_ws\PowerShell"
}
$Env:PS_SC_DIR = $PS_SC_DRIVE + '\' + $SC_DIR

# My intension is to keep this file small
function ss() {
  if ($args.Count -lt 1) {
    return "Please provide correct commandline"
  }
  elseif ($args.Count -eq 1) {
    & "$Env:PS_SC_DIR\ss.ps1" $args
  }
  else {
    <#$cmd = $args[0]
    echo "cmd: `"$cmd`""
    $cargs = [string]$args
    # echo "cargs: `"$cargs`""
    $cargs = $cargs.Substring($cmd.Length-1)
    # remove remaining spaces
    $cargs = $cargs.TrimStart()#>
    # echo "cargs: `"$cargs`""
    #if ($args.Count -ge 2) {
      #   Write-Host "Command line may not work appropriately with provided number of arguments."
      #Write-Host "Sending param 0 " $args[0] " and rest" $cargs
    #}
    #& "$Env:PS_SC_DIR\ss.ps1" $args[0] $cargs
    #& "$Env:PS_SC_DIR\ss.ps1" (, $args)
    # Start-Job -filepath ss.ps1 -arg (,$args)
    # $sspath = $Env:PS_SC_DIR+"\ss.ps1"
    # Write-Host $sspath
    # Invoke-Command -FilePath $sspath -ArgumentList (,$args)
    # Invoke-Command -ArgumentList (,$args) -ScriptBlock { ss }
    # Write-Host "now args: $args"
    $saArgs = $args[0 .. ($args.Count)]
    # Write-Host "now args: $saArgs"
    #$args.Remove(1)
    #Write-Host "now args: $args"
    & "$Env:PS_SC_DIR\ss.ps1" $saArgs
    # ss.ps1 $saArgs
  }
  return ""
}
