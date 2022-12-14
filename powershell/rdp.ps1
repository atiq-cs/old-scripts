<#
.SYNOPSIS
  Remote Connetion Tool, activate VPN using PanGPS and connect using `mstsc`
.DESCRIPTION
  Supports a few actions for connecting to remove workstation and facilitate checking status.
  Note: dependency on Palo Alto Network VPN Tool and Miscrosoft TSC

.PARAMETER Command
  Specifies what to do. Currently, two options are available,
  1. connect
  2. status
  3. NetStatusFix
.EXAMPLE
  Connect to remote workstation.
  rdp.ps1

  To check status,
  rdp.ps1 status

  Fix internet status in Windows,
  rdp.ps1 NetStatusFix

.NOTES
  * NetStatusFix is a demo that fixes outlook connection problem due to WiFi net switch
  - demos PanGPS
  - demos mstsc cmd line
  ToDo,
  - support uppercase variations for $Command later

#>

param( [string] $Command = 'connect' )

# Global Vars
$VPNServiceName = 'PanGPS'
$VPNServiceTitle = 'Palo Alto Networks GlobalProtect'
# Check connection, replace with internal hostname which is only accessible through VPN
$WSHostName = 'username.internal.corp.com'
$DefaultRDPPath = 'D:\Docs\Default.rdp'

<#
.SYNOPSIS
VPN Service Status
.DESCRIPTION
Reports VPN Service Status
.EXAMPLE
IsVPNServiceStarted
#>
function IsVPNServiceStarted() {
  return ((Get-Service -Name $VPNServiceName).Status -eq 'Running')
}

function Main() {
  switch ( $Command ) {
    'connect' {
      if (! (IsVPNServiceStarted)) {
        Write-Host -ForegroundColor Red 'Please start service:' $VPNServiceTitle
        return
      }
      if (Test-Connection -Quiet $WSHostName) { mstsc $DefaultRDPPath }
      else { Write-Host -ForegroundColor Red 'Not connected to remote machine yet!' }
    }
    'status' {
      if (! (IsVPNServiceStarted)) {
        'Service: ' + $VPNServiceTitle + ' is stopped!'
        return
      }
      if (Test-Connection -Quiet $WSHostName) { 'Ready to connect!' }
      else { Write-Host -ForegroundColor Red 'Not connected to remote machine!' }
    }
    'NetStatusFix' {
      if ($null -eq (Get-NetConnectionProfile)) {
        Write-Host -ForegroundColor Red 'Please connect to WiFi and then run the script!'
        return
      }
      $WiFiSSID = (Get-NetConnectionProfile).Name
      Stop-Process -Name outlook
      netsh wlan disconnect
      netsh wlan connect name=$WiFiSSID
      Start-Process Outlook
    }
    default {
      'Unknown command line argument: ' + $Command + ' provided!'
    }
  }
}

# Entry Point
Main
