<#
.SYNOPSIS
  AMP Stack Service Commands
.DESCRIPTION
  Date: 07/06/2011
  Automate Services: httpd and mysql for now

.EXAMPLE
  Wamp start

.NOTES
  Prev name: IIS.ps1
  Replace service cmdlets with Linux service commands for Linux.
#>

# TODO: use Param
$cmd = [string] $args

if ($cmd -eq "" -or $cmd.ToLower().Equals("start")) {
  Write-Host -NoNewline "Starting service Apache`t"
  # "World Wide Web Publishing Service"
  Start-Service -DisplayName Apache2.2
  echo "[OK]"
  
  Write-Host -NoNewline "Starting service MySQL`t"
  Start-Service -DisplayName MySQL
  echo "[OK]"
}
elseif ($cmd.ToLower().Equals("stop")) {
  Stop-Service -DisplayName Apache2.2
  Stop-Service -DisplayName MySQL
}
elseif ($cmd.ToLower().Equals("restart")) {
  # stop
  Stop-Service -DisplayName Apache2.2
  Stop-Service -DisplayName MySQL
  # start
  Start-Service -DisplayName Apache2.2
  Start-Service -DisplayName MySQL
}
else {
    echo "Please check command line arguments."
}
