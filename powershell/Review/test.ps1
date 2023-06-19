$installedapps = get-AppxPackage AdobeSystemsIncorporated.AdobeReader

$aumidList = @()
foreach ($app in $installedapps)
{
    foreach ($id in (Get-AppxPackageManifest $app).package.applications.application.id)
    {
        $aumidList += $app.packagefamilyname + "!" + $id
    }
}

$aumidList


<# From Setup.ps1 (which we just dropped)
# run this command by pasting on the shell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine

# Just another test command
echo "test guinea pig" | Select-String "test" -quiet
----
$stream = [System.IO.StreamWriter] "e:\svnws\WordList\Barron Word DB format.txt"

$FPath = "e:\svnws\WordList\Barron Word DB.txt"

Get-Content $FPath | Foreach-Object {
    $line = [string] $_
    $line = " "+$line
     $stream.WriteLine($line)
}

$stream.close()

global variable test

$DefaultInterfaceName = "Realtek RTL8139/810x Family Fast Ethernet NIC"
$WIFIinterfaceName = "Wireless G USB Adapter"
$mask1 = "192.168.16"
$mask2 = "192.168.10"
[int]$global:len = 0

# This function enable/disables provided interface
function Switch-Adapter([string]$networkInterface, [bool]$isEnable) {
    $defaultInterface = gwmi win32_networkadapter | where {$_.Description -eq $networkInterface}

    [int] $tabCount = 0
    
    if ($global:len -ne 0) {
        $tabCount =  [int] ($networkInterface.Length-$global:len) / 8;
        write-Host "tabc: $tabCount"
    }
    else {
        $global:len = $networkInterface.Length
    }
    
    if ($isEnable) {
        write-Host -nonewline "Enabling $networkInterface"
        $result = $defaultInterface.Enable()
         if ($result.ReturnValue -eq -0) {
            for ($i=1; $i -le $tabCount; $i++) {
                write-Host -nonewline "`t"
            }
            echo "`t`t[OK]"
         }
         else {
            Write-Host -foregroundcolor red "`t`t[Failed]"
         }
     }
     else {
        write-Host -nonewline "Disabling $networkInterface"
        $result = $defaultInterface.Disable()
         if ($result.ReturnValue -eq -0) {
            for ($i=1; $i -le $tabCount; $i++) {
                write-Host -nonewline "`t"
            }

            echo "`t`t[OK]"
         }
         else {
         
            Write-Host -foregroundcolor red "`t`t[Failed]"
         }
     }
}

function ShowInterfaceInfo([string]$networkInterface) {
    $defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $networkInterface}
    
    <#if ($defaultInterface.IPAddress -eq $null) {
        $defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $networkInterface}
        echo "No interface is found. Check if the interface is disabled or cable is disconnected!"
        break
    }#>
    
    <#$intName = $defaultInterface.Description
    echo "$intName Settings`n===================================================="
    $curIP = $defaultInterface.IPAddress[0]
    $gateway = $defaultInterface.DefaultIPGateway[0]
    $pridns = $defaultInterface.DNSServerSearchOrder[0]
    $secdns = $defaultInterface.DNSServerSearchOrder[1]

    if ($networkInterface.Equals("Wireless G USB Adapter")) {
        echo "Connection`t:`tWiFI Wireless"
    }
    elseif (echo $curIP | select-string $mask1) {
        echo "ISP Name`t:`tCONNECTBD Ltd, Internet Service"
    }
    else {
        echo "ISP Name`t:`tAdvance Technology Computers Ltd"
    }
    echo "IP Address`t:`t$curIP"
    echo "Gateway IP`t:`t$gateway"
    echo "Primary DNS`t:`t$pridns"
    echo "Secondary DNS`t:`t$secdns"
}
<#function ShowInterfaceInfo([string]$networkInterface) {
    $interfaceIndex = (gwmi Win32_NetworkAdapter | where {$_.Name -eq $networkInterface}).InterfaceIndex
    $defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq $interfaceIndex}
    $intName = $defaultInterface.Description
    $curIP = $defaultInterface.IPAddress[0]
    $gateway = $defaultInterface.DefaultIPGateway[0]
    $pridns = $defaultInterface.DNSServerSearchOrder[0]
    $secdns = $defaultInterface.DNSServerSearchOrder[1]
    echo "Interface Name`t:`t$intName"
    echo "IP Address`t:`t$curIP"
    echo "Gateway IP`t:`t$gateway"
    echo "Primary DNS`t:`t$pridns"
    echo "Secondary DNS`t:`t$secdns"
}#>

<#function Change-AdapterSettings([string]$networkInterface, [string]$ip, [string]$gateway, [string]$dns1, [string]$dns2, [bool] $setgateway) {
    #$ip = "192.168.10.12"
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
        echo "Interface is not found. Check if the interface is disabled or unplugged."
        break
    }

    if (! $NetInterface) {
        echo "Interface for $networkInterface not found."
        break
    }
    $ret = $NetInterface.EnableStatic($ip, $subnetmask).ReturnValue
    if ($ret -ne 0) { echo "An error occurred setting subnet mask code: $ret" }
    echo "IP: $ip"
    echo "Subnet Mask: $subnetmask"
    if ($setgateway) {
        $ret = $NetInterface.SetGateways($gateway).ReturnValue
        if ($ret -ne 0) { echo "An error occurred setting gateway, code: $ret" }
        else { echo "Gateway: $gateway" }
    }
    $ret = $NetInterface.SetDNSServerSearchOrder($dns).ReturnValue
    if ($ret -ne 0) { echo "DNS: error occurred. Code: $ret and dns: $dns" }
    else { echo "DNS: $dns" }
    $ret = $NetInterface.SetDynamicDNSRegistration($registerDns).ReturnValue
    if ($ret -ne 0) { echo "An error occurred setting register dns. Code: $ret" }
    echo "Dynamic DNS: Enabled"
}

if ($args.Count -eq 1) {
    $cmd = $args[0]
    if($cmd.Equals("swisp")) {
        $ip1 = "12"
        $ip2 = "12"
        $dns1 = "8.8.8.8", "4.2.2.3"
        $dns2 = "202.51.183.6", "202.51.183.7"

        $ipArray = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $DefaultInterfaceName}).IPAddress
        if ($ipArray -eq $null) {
            echo "Interface is not found. Check if the interface is disabled."
            break
        }
        $curIP = $ipArray[0]

        if (echo $curIP | select-string $mask1) {
            echo "Changing to subnet $mask2"
            Change-AdapterSettings $DefaultInterfaceName "$mask2.$ip2" "$mask2.1" $dns2[0] $dns2[1] $true
        }
        else {
            echo "Changing to subnet $mask1"
            Change-AdapterSettings $DefaultInterfaceName "$mask1.$ip1" "$mask1.1" $dns1[0] $dns1[1] $true
        }
        ping 8.8.8.8
        break
    }
    elseif($cmd.Equals("swwifi")) {
        $defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $DefaultInterfaceName}
        
        # if default is not enabled, switch to default
        if ($defaultInterface.IPAddress -eq $null) {
            Switch-Adapter $WIFIinterfaceName $false
            Switch-Adapter $DefaultInterfaceName $true
        }
        else {
            Switch-Adapter $DefaultInterfaceName $false
            Switch-Adapter $WIFIinterfaceName $true
        }
        break
        
    }
    elseif($cmd.Equals("help")) {
        echo "Usage: ifconfig or ifconfig sw`n`nhttp://saosx.com`nSAOSX(c) 2011`n"
        break
    }
    else {
        echo "Wrong commandline: '$cmd'. Should be 'swisp' or 'swwifi'`n"
    }
}
elseif ($args.Count -eq 2) {
    $cmd1 = $args[0]
    $cmd2 = $args[1]
    $TAinterfaceName = "Realtek PCIe GBE Family Controller"
    
    if ($cmd2.Equals("TA")) {
        # Network Settings, 1 for wan, 2 for lan
        $dns = "8.8.8.8", "4.2.2.3"
        
        if($cmd1.Equals("wan")) {
            $ip = "1"
            $mask = "192.168.2"
            #$curIP = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq 11}).IPAddress[0]
            echo "Changing to subnet $mask"
            Change-AdapterSettings $TAinterfaceName "$mask.$ip" "$mask1.1" $dns[0] $dns[1] $false
            ping "$mask.100"
            Start Chrome "$mask.100"
            break
        }
        elseif($cmd1.Equals("lan")) {
            $ip = "10"
            $mask = "192.168.123"
            #$curIP = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq 11}).IPAddress[0]
            echo "Changing to subnet $mask"
            Change-AdapterSettings $TAinterfaceName "$mask.$ip" "$mask.1" $dns[0] $dns[1] $false
            ping "$mask.1"
            Start Chrome "$mask.1"
            break
        }
        elseif($cmd1.Equals("rec")) {
            $ip = "1"
            $mask = "192.168.1"
            # $curIP = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq 11}).IPAddress[0]
            # echo "Changing to subnet $mask"
            Change-AdapterSettings $TAinterfaceName "$mask.$ip" "$mask.1" $dns[0] $dns[1] $false
            ping "$mask.100"
            break
        }
        else {
            echo "Wrong first commandline: '$cmd1'. Can only be lan or wan"
        }
    }
    elseif ($cmd2.Equals("linksys")) {
        # Network Settings, 1 for wan, 2 for lan
        $dns = "8.8.8.8", "4.2.2.3"
        
        if($cmd1.Equals("wan")) {
            $ip = "1"
            $mask = "192.168.13"
            #$curIP = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq 11}).IPAddress[0]
            echo "Changing to subnet $mask"
            Change-AdapterSettings $TAinterfaceName "$mask.$ip" "$mask1.1" $dns[0] $dns[1] $false
            ping "$mask.10"
            Start Chrome "$mask.10"
            break
        }
        elseif($cmd1.Equals("rec")) {
            $ip = "1"
            $mask = "192.168.1"
            #$curIP = (Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.InterfaceIndex -eq 11}).IPAddress[0]
            echo "Changing to subnet $mask"
            Change-AdapterSettings $TAinterfaceName "$mask.$ip" "$mask.1" $dns[0] $dns[1] $false
            ping "$mask.1"
            break
        }
        else {
            echo "Wrong first commandline: '$cmd1'. Can only be lan or wan"
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
    # Wireless Interface
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

if ($defaultInterface.IPAddress -eq $null) {
    $defaultInterface = Get-WmiObject Win32_NetworkAdapterConfiguration | where {$_.Description -eq $WIFIinterfaceName}
    if ($defaultInterface.IPAddress -eq $null) {
        echo "No interface is found. Check if the interface is disabled or cable is disconnected!"
    }
    else {
        ShowInterfaceInfo($WIFIinterfaceName);
    }
}
else {
    ShowInterfaceInfo($DefaultInterfaceName);
}

echo ""
#>
