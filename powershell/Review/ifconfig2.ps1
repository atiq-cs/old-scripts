# Latest Net cmdlets documentation: https://docs.microsoft.com/en-us/powershell/module/netadapter/get-netadapter?view=win10-ps
# Date: 06/13/2011 19:23:10
# Author: Atiq
# ifconfig2 as it does not exploit cmdlet 3.0

# You have to get your interface number to make it work
# you can get your interface list using command 'gwmi Win32_NetworkAdapter'
# And then you can put the appropirate name here to make it work

# ref: http://blogs.technet.com/b/heyscriptingguy/archive/2011/10/07/use-powershell-to-identify-your-real-network-adapter.aspx\
# get all members:
# Get-WmiObject Win32_NetworkAdapterConfiguration | Get-Member -MemberType Methods | Format-List
# get all interfaces related
# gwmi win32_networkadapterconfiguration -filter 'ipenabled="true"' | %{$_.GetRelated('win32_networkadapter')}

# Previous interfaces
# my own PC I guess
#$DefaultInterfaceName = "WiMAX Network Adapter"
# PC 1, REVE office interfaces
#$DefaultInterfaceName = "Realtek PCIe GBE Family Controller"
#$DefaultInterfaceName = "Realtek RTL8139/810x Family Fast Ethernet NIC"

# PC 2, REVE office 1
# $DefaultInterfaceName = "Qualcomm Atheros AR8151 PCI-E Gigabit Ethernet Controller (NDIS 6.30)"
# $WIFIinterfaceName = "Wireless G USB Adapter"

# default interface was connected to TA previously, no TA interface in my PC
# $TAinterfaceName = "Realtek PCIe GBE Family Controller"

# Laptop, HP Pavillion G6-2218TU
$DefaultInterfaceName = "Realtek PCIe FE Family Controller"
$WIFIinterfaceName = "Intel(R) Centrino(R) Wireless-N 2230"
$TAinterfaceName = ""   # no more exists

$mask1 = "192.168.20"
$mask2 = "192.168.10"

function Show-ConsoleMessage([string]$message) {
    $ScreenLimit = 80
    $tabCount = 0
    $len = $message.Length
    if ($len > $ScreenLimit) {
        $message = $message.Substring(0, $ScreenLimit)
    }
    else {
        $tabCount = [math]::ceiling(($ScreenLimit - $len) / 8);
    }
    
    #write-Host "tabc: $tabCount, len: $len"
    write-Host -nonewline $message
    return [int]$tabCount
}

function Show-ConsoleResponse([int]$tabCount, [boolean]$isOk) {
     for ($i=1; $i -le $tabCount; $i++) {
        write-Host -nonewline "`t"
     }
     if ($isOk) {
        Write-Host -foregroundcolor green "[OK]"
     }
     else {
        Write-Host -foregroundcolor red "[Failed]"
     }
}


# This function enable/disables provided interface
function Switch-Adapter([string]$networkInterface, [bool]$isEnable) {
    $defaultInterface = gwmi win32_networkadapter | where {$_.Description -eq $networkInterface}

    if ($isEnable) {
        $tabCount = Show-ConsoleMessage "Enabling $networkInterface"
        $result = $defaultInterface.Enable()
        
         if ($result.ReturnValue -eq -0) {
            Show-ConsoleResponse $tabCount $true
         }
         else {
            Show-ConsoleResponse $tabCount $false
         }
     }
     else {
        $tabCount = Show-ConsoleMessage "Disabling $networkInterface"
        $result = $defaultInterface.Disable()
         
         if ($result.ReturnValue -eq -0) {
            Show-ConsoleResponse $tabCount $true
            
         }
         else {
            Show-ConsoleResponse $tabCount $false
         }
     }
}

function ShowInterfaceInfo([string]$networkInterface) {
    $defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $networkInterface}
    
    if ($defaultInterface.IPAddress -eq $null) {
        $defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $networkInterface}
        Write-Host "No interface is found. Check if the interface is disabled or cable is disconnected!"
        break
    }
    
    $intName = $defaultInterface.Description
    Write-Host "$intName Settings`n======================================================"
    $curIP = $defaultInterface.IPAddress[0]
    if ($defaultInterface.DefaultIPGateway -ne $null) {
        $gateway = $defaultInterface.DefaultIPGateway[0]
    }
    else {
        $gateway = "null"
    }
    $pridns = $defaultInterface.DNSServerSearchOrder[0]
    $secdns = $defaultInterface.DNSServerSearchOrder[1]

    if ($networkInterface.Equals($WIFIinterfaceName)) {
        Write-Host "Connection`t:`tWiFI Wireless"
    }
    elseif ($networkInterface.Equals($TAinterfaceName)) {
        Write-Host "Connection`t:`tTA Interface"
    }
    elseif (select-string -inputobject $curIP -pattern $mask1) {
    #elseif (Write-Host $curIP | select-string $mask1) {
        Write-Host "ISP Name`t:`tCONNECTBD Ltd, Internet Service"
    }
    else {
        Write-Host "ISP Name`t:`tAdvance Technology Computers Ltd"
    }
    Write-Host "IP Address`t:`t$curIP"
    Write-Host "Gateway IP`t:`t$gateway"
    Write-Host "Primary DNS`t:`t$pridns"
    Write-Host "Secondary DNS`t:`t$secdns"
}

<#function ShowInterfaceInfo([string]$networkInterface) {
    $interfaceIndex = (gwmi Win32_NetworkAdapter | where {$_.Name -eq $networkInterface}).InterfaceIndex
    $defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq $interfaceIndex}
    $intName = $defaultInterface.Description
    $curIP = $defaultInterface.IPAddress[0]
    $gateway = $defaultInterface.DefaultIPGateway[0]
    $pridns = $defaultInterface.DNSServerSearchOrder[0]
    $secdns = $defaultInterface.DNSServerSearchOrder[1]
    Write-Host "Interface Name`t:`t$intName"
    Write-Host "IP Address`t:`t$curIP"
    Write-Host "Gateway IP`t:`t$gateway"
    Write-Host "Primary DNS`t:`t$pridns"
    Write-Host "Secondary DNS`t:`t$secdns"
}#>

function Change-AdapterSettings([string]$networkInterface, [string]$ip, [string]$gateway, [string]$dns1, [string]$dns2, [bool] $setgateway) {
    #$ip = "192.168.10.37"
    $subnetmask = "255.255.255.0"
    #$gateway = "192.168.10.1"
    #$dns1 = "202.51.183.6"
    #$dns2 = "202.51.183.7"
    $registerDns = "TRUE"
 
    #$dns = $dns1
    $dns = $dns1, $dns2
    $ret = 0
    
    $NetInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $networkInterface}
    
    if ($NetInterface.IPAddress -eq $null) {
        Write-Host "Interface is not found. Check if the interface is disabled or unplugged."
        break
    }

    if (! $NetInterface) {
        Write-Host "Interface for $networkInterface not found."
        break
    }
    $ret = $NetInterface.EnableStatic($ip, $subnetmask).ReturnValue
    if ($ret -ne 0) { Write-Host "An error occurred setting subnet mask code: $ret" }
    Write-Host "IP: $ip"
    Write-Host "Subnet Mask: $subnetmask"
    if ($setgateway) {
        $ret = $NetInterface.SetGateways($gateway).ReturnValue
        if ($ret -ne 0) { Write-Host "An error occurred setting gateway, code: $ret" }
        else { Write-Host "Gateway: $gateway" }
    }
    $ret = $NetInterface.SetDNSServerSearchOrder($dns).ReturnValue
    if ($ret -ne 0) { Write-Host "DNS: error occurred. Code: $ret and dns: $dns" }
    else { Write-Host "DNS: $dns" }
    $ret = $NetInterface.SetDynamicDNSRegistration($registerDns).ReturnValue
    if ($ret -ne 0) { Write-Host "An error occurred setting register dns. Code: $ret" }
    Write-Host "Dynamic DNS: Enabled"
}

function ShowHelp([string] $preamble) {
    Write-Host "$preamble `r`nUsage:"
    Write-Host "`t1. ifconfig`t`t`t:`tdisplays default LAN Interface info"
    Write-Host "`t2. ifconfig TA`t`t`t:`tdisplays TA Interface info"
    Write-Host "`t3. ifconfig swisp/swwifi/vpn`t:`tmodifies default LAN Interface, changes mask, gateway"
    Write-Host "`t4. ifconfig swwifi`t`t:`tdisable default LAN Interface, enable"
    Write-Host "`t3. ifconfig wan/lan/rec TA`t:`tmodifies TA Interface"
    Write-Host "`t4. ifconfig wan/rec linksys`t:`tmodifies TA Interface"
    Write-Host "`t5. ifconfig enable/disable eth0/wifi/vta`n`nhttp://saos.co.in`nSAOS(c) 2013`n"
}

if ($args.Count -eq 1) {
    $cmd = $args[0]
    if($cmd.Equals("TA")) {
        ShowInterfaceInfo($TAinterfaceName);
        <#$defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $TAinterfaceName}

        if ($defaultInterface.IPAddress -eq $null) {
            $defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $WIFIinterfaceName}
            #if ($defaultInterface.IPAddress -eq $null) {
                Write-Host "No interface is found. Check if the interface is disabled or cable is disconnected!"
            <#}
            else {
                ShowInterfaceInfo($WIFIinterfaceName);
            }
        }
        else {
            ShowInterfaceInfo($TAinterfaceName);
        }#>

        Write-Host ""
    }
    # ISP change is now automatically handled by router in load balance
    elseif($cmd.Equals("swisp")) {
        $ip1 = "24"
        $ip2 = "24"
        # Other one
        $dns1 = "202.51.183.6", "202.51.183.7"
        # Connect BD, ns2 is only reliable
        $dns2 = "202.79.16.2", "8.8.8.8"

        $ipArray = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $DefaultInterfaceName}).IPAddress
        if ($ipArray -eq $null) {
            Write-Host "Interface is not found. Check if the interface is disabled."
            break
        }
        $curIP = $ipArray[0]

        <# if we are in subnet 1 (mask1, 16 series)
        $res = [string] (select-string -inputobject $curIP -pattern $mask1)
        echo "our res: '$res'"
        $len = $res.Length
        echo "our len: $len"
        if ($len -gt 0) {#>
        
        if (select-string -inputobject $curIP -pattern $mask1) {
            Write-Host "Changing to subnet $mask2"
            Change-AdapterSettings $DefaultInterfaceName "$mask2.$ip2" "$mask2.1" $dns2[0] $dns2[1] $true
        }
        else {
            Write-Host "Changing to subnet $mask1"
            Change-AdapterSettings $DefaultInterfaceName "$mask1.$ip1" "$mask1.1" $dns1[0] $dns1[1] $true
        }
        ping 8.8.8.8
        break
    }
    elseif($cmd.Equals("swwifi")) {
        $wifiInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $WIFIinterfaceName}
        
        # if WIFI is not enabled, switch to WIFI
        if ($wifiInterface.IPAddress -eq $null) {
            Switch-Adapter $DefaultInterfaceName $false
            Switch-Adapter $WIFIinterfaceName $true
        }
        else {
            Switch-Adapter $WIFIinterfaceName $false
            Switch-Adapter $DefaultInterfaceName $true
        }
        
    }
    elseif($cmd.Equals("vpn")) {
        #$defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $DefaultInterfaceName}
        
        $vpnip = "167"
        $ip = "37"
        $mask = "192.168.10"
        $dns = "8.8.8.8", "4.2.2.3"
        $ipArray = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $DefaultInterfaceName}).DefaultIPGateway
        if ($ipArray -eq $null) {
            Write-Host "Interface is not found. Check if the interface is disabled."
            break
        }
        
        $curIP = $ipArray[0]
        
        if (select-string -inputobject $curIP -pattern $vpnip) {
            Write-Host "Changing to ADN gateway"
            # only changing gateway could be enough but not thinking of that right now...
            Change-AdapterSettings $DefaultInterfaceName "$mask.$ip" "$mask.1" $dns[0] $dns[1] $true
            ping $dns[0]
        }
        else {
            Write-Host "Changing to VPN gateway"
            Change-AdapterSettings $DefaultInterfaceName "$mask2.$ip" "$mask2.$vpnip" $dns[0] $dns[1] $true
            ping "$mask2.$vpnip"
        }
    }
    elseif($cmd.Equals("help")) {
        ShowHelp "Help for SA ifconfig"
    }
    else {
        ShowHelp "Wrong first commandline: '$cmd'. Should be 'swisp' or 'swwifi' or 'vpn' or 'wan TA' for single argument"
    }
    break
}
elseif ($args.Count -eq 2) {
    $cmd1 = $args[0]
    $cmd2 = $args[1]
    
    if ($cmd2.Equals("TA")) {
        # Network Settings, 1 for wan, 2 for lan
        $dns = "8.8.8.8", "4.2.2.3"
        
        if($cmd1.Equals("wan")) {
            $ip = "1"
            $mask = "192.168.2"
            #$curIP = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq 11}).IPAddress[0]
            Write-Host "Changing to subnet $mask"
            Change-AdapterSettings $TAinterfaceName "$mask.$ip" "$mask1.1" $dns[0] $dns[1] $false
            ping "$mask.100"
            Start Chrome "$mask.100"
            break
        }
        elseif($cmd1.Equals("lan")) {
            $ip = "10"
            $mask = "192.168.123"
            #$curIP = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq 11}).IPAddress[0]
            Write-Host "Changing to subnet $mask"
            Change-AdapterSettings $TAinterfaceName "$mask.$ip" "$mask.1" $dns[0] $dns[1] $false
            ping "$mask.1"
            Start Chrome "$mask.1"
            break
        }
        elseif($cmd1.Equals("rec")) {
            $ip = "1"
            $mask = "192.168.1"
            # $curIP = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq 11}).IPAddress[0]
            # Write-Host "Changing to subnet $mask"
            Change-AdapterSettings $TAinterfaceName "$mask.$ip" "$mask.1" $dns[0] $dns[1] $false
            ping "$mask.100"
            break
        }
        else {
            Write-Host "Wrong first commandline: '$cmd1'. Can only be lan or wan or rec"
            break
        }
    }
    elseif ($cmd2.Equals("linksys")) {
        # Network Settings, 1 for wan, 2 for lan
        $dns = "8.8.8.8", "4.2.2.3"
        
        if($cmd1.Equals("wan")) {
            $ip = "1"
            $mask = "192.168.13"
            #$curIP = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq 11}).IPAddress[0]
            Write-Host "Changing to subnet $mask"
            Change-AdapterSettings $TAinterfaceName "$mask.$ip" "$mask1.1" $dns[0] $dns[1] $false
            ping "$mask.10"
            Start Chrome "$mask.10"
            break
        }
        elseif($cmd1.Equals("rec")) {
            $ip = "1"
            $mask = "192.168.1"
            #$curIP = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq 11}).IPAddress[0]
            Write-Host "Changing to subnet $mask"
            Change-AdapterSettings $TAinterfaceName "$mask.$ip" "$mask.1" $dns[0] $dns[1] $false
            ping "$mask.1"
            break
        }
        else {
            Write-Host "Wrong first commandline: '$cmd1'. Can only be lan or wan"
        }
    }
    # Default Ethernet Interface
    elseif ($cmd1.Equals("enable") -and $cmd2.Equals("eth0")) {
        Switch-Adapter $DefaultInterfaceName $true
        break
    }
    elseif ($cmd1.Equals("disable") -and $cmd2.Equals("eth0")) {
        Switch-Adapter $DefaultInterfaceName $false
        break
    }
    # Wireless Interface
    elseif ($cmd1.Equals("enable") -and $cmd2.Equals("wifi")) {
        Switch-Adapter $WIFIinterfaceName $true
        break
    }
    elseif ($cmd1.Equals("disable") -and $cmd2.Equals("wifi")) {
        Switch-Adapter $WIFIinterfaceName $false
        break
    }
    # Voip TA Interface
    elseif ($cmd1.Equals("enable") -and $cmd2.Equals("vta")) {
        Switch-Adapter $TAinterfaceName $true
        break
    }
    elseif ($cmd1.Equals("disable") -and $cmd2.Equals("vta")) {
        Switch-Adapter $TAinterfaceName $false
        break
    }
}

$defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $DefaultInterfaceName}
if ($defaultInterface.DHCPEnabled -eq $null) {
    Write-Host "Default interface DHCP property null."
}
elseif($defaultInterface.DHCPEnabled -eq $true) {
    Write-Host "DHCP is enabled for Default LAN Interface"
    break
    # ShowInterfaceInfo($WIFIinterfaceName);
}

elseif ($defaultInterface.IPAddress -eq $null) {
    $defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $WIFIinterfaceName}
    # $defaultInterface.get
    if ($defaultInterface.IPAddress -eq $null) {
        Write-Host "No interface is found. Check if the interface is disabled or cable is disconnected!"
    }
    else {
        ShowInterfaceInfo($WIFIinterfaceName);
    }
}
else {
    ShowInterfaceInfo($DefaultInterfaceName);
}

Write-Host ""
