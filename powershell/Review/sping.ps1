<# Date: 06/15/2011 17:55:07
 # Author: Atiq
 # Desc:

 # Usage Example:
        .\SAPing -t opendns
        .\SAPing google
        .\SAPing 8.8.2.2
        .\SAPing 1


 # Usage behavior
    1. yahoo.com etc are not valid. only google and opendns

 # References:
    1. Get Infterface name using this command "Get-WmiObject Win32_NetworkAdapterConfiguration"

    2. Test-Connection: http://technet.microsoft.com/en-us/library/hh849808.aspx

    3. Ping exception catch workaround: http://blog.crayon.no/blogs/janegil/archive/2011/10/23/test_2D00_connection_2D00_error_2D00_handling_2D00_gotcha_2D00_in_2D00_powershell_2D00_2_2D00_0.aspx

 #>

function isNumeric ($x) {
    $x2 = 0
    $isNum = [System.Int32]::TryParse($x, [ref]$x2)
    return $isNum
}

# Intel G41
# Gigabyte G41mt-s2p
$DefaultSubNet = "192.168.30"

function GetSubnet {
    # Windows 8.1 in HP Pavilion G6 2218 TU
    $DefaultInterfaceName = "Hyper-V Virtual Ethernet Adapter #2"

    $DefaultInt = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $DefaultInterfaceName}

    if ($DefaultInt.IPAddress -eq $null) {
        Write-Host "Default Interface not found. Defaulting mask"
        return $DefaultSubNet
    }
    $DefaultGateway = $DefaultInt.DefaultIPGateway[0]
    #Write-Host "gateway: $DefaultGateway"
    if (! ($DefaultGateway)) {
        Write-Host "WMI Query failed!"
        exit
    }
    $lastindex = [int] $DefaultGateway.lastindexof(".")
    $sm = $DefaultGateway.Remove($lastindex)
    #Write-Host "Subnet: $sm"
    return $sm
}

function GetGateway {
    # (Get-NetIPConfiguration -InterfaceAlias "vEthernet (Realtek PCIe FE Family Controller Virtual Switch)").IPv4DefaultGateway

    $DefaultInterfaceAlias = "vEthernet (Realtek PCIe FE Family Controller Virtual Switch)"

    # | Foreach IPv4DefaultGateway

    [string] $gatewayip = (Get-NetIPConfiguration -InterfaceAlias $DefaultInterfaceAlias).IPv4DefaultGateway.NextHop

    return $gatewayip
}

function SAPing([string]$cmdSwitch, [string]$hostID) {
    try {
        # switch statement ref: http://technet.microsoft.com/en-us/library/ff730937.aspx
        switch ($cmdSwitch) {
        "-t" { Test-Connection -Count 2147483647 $hostID -ErrorAction stop }
        default {Test-Connection -Delay 3 $hostID -ErrorAction stop }
        }
    }
    catch [System.Management.Automation.ActionPreferenceStopException] {
        try {            
            throw $_.exception            
        }            
            
        catch [System.Net.NetworkInformation.PingException] {            
            "Target host is not available!"
        }            
        catch {            
            "General exception!`n"
        }            
            
    }
}

# Check arguments
$ip = ""
$cmdSwitch = ""

if ($args.Count -eq 1) {
    $ip = [string]$args
}
elseif ($args.Count -eq 2) {
    $cmdSwitch = [string]$args[0]
    $ip = [string]$args[1]
}
else {
    Write-Host "Number of command-line arguments incorrect"
    break
}

<#if ($ip -match "(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}") {
    $newip = $submask + "." + $ip
    Write-Host "IP modified to $newip"
}
exit#>

if ($ip.Equals("tawan")) {
    $ip = "192.168.2.100"
}
elseif ($ip.Equals("tadhcp")) {
    $ip = "VOIP_TA1S1O.mshome.net"
    SAPing $cmdSwitch $ip
    break
}
elseif ($ip.Equals("google")) {
    $ip = "google.com"
    SAPing $cmdSwitch $ip
    break
}
elseif ($ip.Equals("opendns")) {
    $ip = "8.8.8.8"
    SAPing $cmdSwitch $ip
    break
}
elseif ($ip.Equals("gw")) {
    $ip=GetGateway
    Write-Host "Acquired gateway ip address:" $ip
    SAPing $cmdSwitch $ip
    break
}

if (! ($ip)) {
    $submask=GetSubnet
    $ip = $submask + ".1"
}

#Select * From Win32_NetworkAdapterConfiguration Where IPEnabled = True").DefaultIPGateway[0]
# This command with filter does not work in Win 7 Enterprise 64 bit
#Get-WmiObject -Class Win32_NetworkAdapterConfiguration $_ -Filter "IPEnabled=TRUE"

#$ip -match "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"

# Regular exp ack:http://powershell.com/cs/blogs/ebook/archive/2009/03/30/chapter-13-text-and-regular-expressions.aspx 
if ($ip -match "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.)" + `
  "{3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b") {
}
elseif (isNumeric($ip)) {
    $submask=GetSubnet
    $ip = $submask + "." + $ip
    Write-Host "`r`nIP modified to $ip"
}
else {
    Write-Host "Provided ip address is invalid. Defaulting.."
    $submask=GetSubnet
    Write-Host "Defaulting to gateway ip"
    $ip = $submask + ".1"
}

SAPing $cmdSwitch $ip
