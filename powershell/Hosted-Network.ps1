<#
.SYNOPSIS
  Create Virtual Network Wifi using Hosted Network
.DESCRIPTION
  Date: 08/17/2013
  Automation to create a cmd script and to run it in priveleged mode

.EXAMPLE
  Hosted-Network start
  Hosted-Network stop

.NOTES
  TODO: replace cmd part with powershell RunAs cmd

tag: windows-only
#>

param(
    [parameter(Mandatory=$true)]
    [string] $action
)

$outputFilePath = $(get-location).path + "\tmp.txt"

if (Test-Path $outputFilePath) {
    Remove-Item $outputFilePath
}

if ($action.Equals("start")) {
    Write-Host "Connecting to elevated prompt.."
    # Write-Host "Starting elevated command prompt with hosted network"
    #$argumentString = "/k " + $(get-location).path + "\hosted-network-assist-elevated.cmd"
    #Start-Process cmd -Verb Runas -ArgumentList $argumentString -ErrorAction 'stop'
    $argumentString = "/c netsh wlan set hostednetwork mode=allow ssid=sa_windows_team key=PASS & netsh wlan start hostednetwork > " + $outputFilePath
    # "cmd.exe /c net stop serviceName > output.txt
    Start-Process cmd -Verb Runas -ArgumentList $argumentString -ErrorAction 'stop'
    sleep 1
    Get-Content $outputFilePath
    break
}

if ($action.Equals("stop")) {
    Write-Host "Connecting to elevated prompt.."
    $argumentString = "/c netsh wlan stop hostednetwork > " + $outputFilePath
    # "cmd.exe /c net stop serviceName > output.txt
    Start-Process cmd -Verb Runas -ArgumentList $argumentString -ErrorAction 'stop'
    sleep 1
    Get-Content $outputFilePath
    break
}

if ($action.Equals("info")) {
    netsh wlan show hostednetwork
    break
}

if ($action.Equals("restart")) {
    Write-Host "Connecting to elevated prompt.."
    # $argumentString = "/c netsh wlan stop hostednetwork `& timeout 4 `& netsh wlan start hostednetwork > " + $outputFilePath
    $argumentString = "/c netsh wlan stop hostednetwork > " + $outputFilePath + " `& timeout 4 `& netsh wlan start hostednetwork > " + $outputFilePath
    # "cmd.exe /c net stop serviceName > output.txt
    Start-Process cmd -Verb Runas -ArgumentList $argumentString -ErrorAction 'stop'
    sleep 5
    Get-Content $outputFilePath
    break
}
