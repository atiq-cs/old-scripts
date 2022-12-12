<#
.SYNOPSIS
  dd-wrt Flash process helper into the router
.DESCRIPTION
  Date: 06/19/2011
  Timed wait instead of manual checking and waiting
  Utilize delay binary for sync/timed wait instead of manually checking router

.PARAMETER Action
  Single or regular flash

.EXAMPLE
  Flash-ddwrt.ps1 Single

.NOTES
  Demonstrations,
  - pause implementation using Raw Key Input from Powershell
#>

[CmdletBinding()] Param (
  [Parameter(Mandatory=$true)] [ValidateSet('Single', 'Long')]
    [string] $Action
)

function pause {
    Write-Host -NoNewline "Press any key to continue ...`r"
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host -NoNewline  "`r                             "
    Write-Host -NoNewline  "`r"
}

$waitInterval = 33

# Reusable Stage: HardReset for single flash and long flash
function StageHardReset() {
    "1st stage`n========================================="
    "Please hold the reset button for 30 seconds"
    pause
    .\Delay.exe $waitInterval

    "`n2nd stage`n========================================="
    "Please hold the reset button for 30 seconds after unplugging power cord."
    pause
    .\Delay.exe $waitInterval

    "`n3rd stage`n========================================="
    "Please hold the reset button for 30 seconds after plugging in the power cord."
    pause
    .\Delay.exe $waitInterval
}

# Single Flash, prev name: `Flash-ddwrt-Single.ps1`
function FlashSingle() {
    "*************** HARD RESET 30-30-30 ****************"
    StageHardReset()
    "`nStages complete!"
}


# Long Flash
function FlashLong() {
    "Now login to GUI and upload a new firmware. After done"
    pause

    "Now wait for 3 minutes. Lights should return to normal."
    .\Delay.exe 3:0
    "Power Cycle Period`n========================================="
    "Unplug the power cord and then hold the reset button for 30 seconds"
    pause
    .\Delay.exe $waitInterval

    "OS BOOT Period`n========================================="
    "Now wait for 2 minutes. Lights should return to normal."
    .\Delay.exe 2:0


    "*************** Final HARD RESET 30-30-30 ****************"
    FlashSingle()
    "`nStages complete! Now login to GUI and upload a new firmware. And then run this script again!"
}


# Start of Main function
function Main() {
    switch ($Action) {
        "Single" { FlashSingle }
        "Long" { FlashLong }
        default {
            'Invalid command line argument: ' + $Action
            return
        }  
    }
}

Main
