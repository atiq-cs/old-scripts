# Date: 08/09/2013 00:51:15
# Author: Atiq

<#  Example UI sample
    set color
    (Get-Host).UI.RawUI.ForegroundColor = "DarkGreen"
    
    # set window position, could not change :(
    $b = (Get-Host).UI.RawUI.WindowPosition
    $b.Width = 5
    $b.Height = 5
    (Get-Host).UI.RawUI.WindowPosition = $b #>
    
    <# automate when necessary, I prefer shortcut that's best tuned for now 
    # set buffersize
    $b = (Get-Host).UI.RawUI.BufferSize
    $b.Width = 110
    $b.Height = 3000
    (Get-Host).UI.RawUI.BufferSize = $b
    
    # Tweak is necessary to make object compatible it's why we use $b
    $b = (Get-Host).UI.RawUI.WindowSize
    $b.Width = 110
    $b.Height = 50
    (Get-Host).UI.RawUI.WindowSize = $b #>
#>

function ResizeConsole([string] $title, [int] $width, [int] $height) {
    # Get console UI
    $cUI = (Get-Host).UI.RawUI

    $cUI.WindowTitle = $title

    # change buffer size, otherwise error
    $b = $cUI.BufferSize
    $b.Width = $width
    $b.Height = 5000
    $cUI.BufferSize = $b

    # change window height and width
    $b = $cUI.WindowSize
    $b.Width = $width
    $b.Height = $height
    $cUI.WindowSize = $b
}

ResizeConsole "SA Matrix Workstation" 100 26
