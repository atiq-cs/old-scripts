<#
.SYNOPSIS
  Find out the ATA device's new IP with hostname "VOIP_TA1S1O.mshome.net"
.DESCRIPTION
  Date: 12/22/2011
  Utilize ICMP Requests and Response (as heart beat) to know when the device comes back alive
  Response return object contains the new IP
  And Open the Web CMS of the device on Google Chrome

.PARAMETER IsFixedIP
  Whether a static IP should be assigned

.EXAMPLE
  Find-ATA.ps1 -IsFixedIP $True

.NOTES
  Demonstrations,
  - do while syntax in PS
  - Network actions: System.Net.NetworkInformation.Ping

  Refs
  - MSFT Ping
     https://learn.microsoft.com/en-us/dotnet/api/system.net.networkinformation.ping
  - MSFT PingReply:
     https://learn.microsoft.com/en-us/dotnet/api/system.net.networkinformation.pingreply
     https://learn.microsoft.com/en-us/dotnet/api/system.net.networkinformation.pingreply.address
#>

[CmdletBinding()] Param (
  [Parameter(Mandatory=$true)]
    [bool] $IsFixedIP
)


# Start of Main function
function Main() {
  # Not sure what this default value is about!
  $hostName="VOIP_TA1S.mshome.net"

  if ($IsFixedIP) {     # Fixed IP
    $hostName = "192.168.2.100"
  }
  else {
    # Covers Modified, Default firmware
    $hostName = "VOIP_TA1S1O.mshome.net"
  }
  
  $ping = new-object System.Net.NetworkInformation.Ping  
  Write-Host "ATA hostname:`t$hostName"
  
  do {
      $pingReply = $null
      
      try {
          $pingReply = $Ping.Send("$hostName")
      }
      catch {
          Write-Host -nonewline "Destination not reachable! "
      }
      Write-Host "Waiting for device to be up.."
      Start-Sleep -s 1
  } while ($pingReply.status -ne "Success");

  $hostIP = $pingReply.Address

  Write-Host "ATA device came online with IP: $hostIP"
  Start-Sleep -s 5

  if($args.Count -ge 1 -and $cmd.Equals("def")) {
      $hostName = "VOIP_TA1S1O.mshome.net:9999"
  }
  
  Start Chrome $hostName
  
  Write-Host
}

Main