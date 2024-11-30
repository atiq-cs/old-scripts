<#
.SYNOPSIS
Initialize Powershell Core Environment with my Script
.DESCRIPTION
Purposes:
 1. Initialize variables; set network status
 2. Fix first time situations when profile does not exist, git is not installed
 3. Set net
.PARAMETER
No parameter yet
.EXAMPLE
powershell -NoExit Init.ps1
.NOTES
Usually runs from a shortcut file.
#>

param(
    [string]
    $psConsoleType = ''
)

function InitializeScript([string] $m_netstatfile) {
  # in case of an unclean shutdown
  $global:netstatfile = $m_netstatfile
  if (Test-Path $m_netstatfile) { Remove-Item $m_netstatfile }
  $global:NET_STATUS = $false
  # Go home; required to call any script from fftsys_ws\powershell directory
  cd $Env:PS_SC_DIR
}

<#
.SYNOPSIS
First time, we need to set this on a new computer
.EXAMPLE
deleteTests
#>
function FixProfile([string] $ScriptDrive) {
  $Env:PS_SC_DIR = $ScriptDrive+"\git_ws\fftsys_ws\Powershell"
  if (! (Test-Path $profile)) {
    # $ProfileDir = $Env:HOMEDrive + $Env:HOMEPATH + "\Documents\WindowsPowerShell"
    $ProfileDir = $profile.Remove($profile.LastIndexOf("\"), $profile.Length-$profile.LastIndexOf("\"));
    # Bug Fix, if my documents location changed this is required
    if (! (Test-Path $ProfileDir)) { New-Item -ItemType directory -Path $ProfileDir }
    $RepoProfileDir = $Env:PS_SC_DIR+"\Microsoft.PowerShell_profile.ps1"
    if (! (Test-Path $RepoProfileDir)) {
      $RepoProfileDir
      Write-Host "Please fix repository powershell profile path for import. Please check value of ScriptDrive."
      break
    }
    Copy-Item $RepoProfileDir $profile
    Write-Host "Profile $profile added. Please update host type in profile and run powershell again."
    break
  }
}

function FixGit() {
  $EXEPATH = $Env:PFilesX64 + '\git'
  if (! (Test-Path "$EXEPATH")) {
    Write-Host "Please install Git"
    break
  }
  if ($Env:Path.EndsWith(';')) { $Env:Path = $Env:Path.Substring(0,$Env:Path.Length-1) }
  $GitPath = "$EXEPATH\cmd"
  # Add path if already not added by system
  $Env:Path +=  ';' + $GitPath
  $Env:EXEPATH = $EXEPATH
  # for msysgit most prob.
  $Env:HOME = $Env:PS_SC_DIR

  # Generate gitconfig
  $gitEmail = 'EMAIL_ADDR'
  <# git pushes from fb are done in dev-vm, this is useless
  if ($HOST_TYPE.Equals("OFFICE_WS")) {
    $gitEmail = 'WORK_EMAIL_ADDR'
  }#>
  # Set $CORP_PROXY_URL

  if ((git config --global user.email) -ne $gitEmail) {
    git config --global user.email $gitEmail
    git config --global user.name 'FULL_NAME'
  }
  if ($HOST_TYPE.Equals("OFFICE_WS")) {
    git config --global http.proxy $CORP_PROXY_URL
  }
}

# Update Internet Status; whether internet is reachable or not
# Result is stored in variable $NETSTATUS
function GetInternetNetStatus() {
  $clnt = new-object System.Net.WebClient
  $url = "http://saos.azurewebsites.net/Downloads/net.txt"
  [bool] $res = $false

  try {
    $clnt.DownloadFile($url,$netstatfile)
    if (SingleInstanceRunning) {
      if ($HOST_TYPE.Equals("VSINC_SERVER_2008")) { Write-Host "`r`n" }
      Write-Host -NoNewline "Connected to World Wide Inter-network"
    }
  }
  catch [Net.WebException] {
    #Write-Host $_.Exception.ToString()
    if (SingleInstanceRunning) {
      Write-Host -foregroundcolor red "Could not reach world wide internetwork!`n"
    }
  }

  if (Test-Path $netstatfile) {
    $tmpText = $(cat $netstatfile)
    if ($tmpText.Equals("on")) {
      if (SingleInstanceRunning) {
        Write-Host -NoNewline " [powered by "
        Write-Host -NoNewline -foregroundcolor green "saosx.com"
        Write-Host "]"
      }
      $res = $true
    }
    elseif ($tmpText | Select-String "Recharge Your Banglalion Acccount") {
      Write-Host -NoNewline " ["
      Write-Host -NoNewline -foregroundcolor red "Banglalion not active yet"
      Write-Host "]"
      Remove-Item $netstatfile
    }
    else {
      Write-Host " [debug] retrieved file is damanged. Please check connection."
    }
    Remove-Item $netstatfile
  }
  return $res
}

function ResizeConsole([string] $title, [int] $history_size, [int] $width, [int] $height) {
  # Get console UI
  $cUI = (Get-Host).UI.RawUI

  $cUI.WindowTitle = $title
  # Debug
  # Write-Host "Requested height " $height " width " $width " buffer size " $history_size

  # change buffer size first, because next dim change depends on it
  <#$b = $cUI.BufferSize
  $b.Width = $width
  $b.Height = $history_size
  $cUI.BufferSize = $b #>
  # Sometimes, Window Size and buffer size conflict because window size cannot be bigger than buffer size, swapping the statements help
  # Seems like it also requires fixing the console.lnk shortcut in the system
  #   shortcut ops moved here: 'apply-settings.ps1', https://github.com/atiq-cs/OldScripts/wiki/Misc-Scripts
  (Get-Host).UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size -Property @{Width=$width; Height=$history_size}
  (Get-Host).UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size -Property @{Width=$width; Height=$height}

  # change window height and width
  <# $b = $cUI.WindowSize
  $b.Width = $width
  $b.Height = $height
  $cUI.WindowSize = $b #>
}

<# Fix this function if used, it is obsolete
function return type should be host type if can be relevant

function NotDetectedOfficeNetwork() {
  $res = $true
  # In case we don't use wifi we should use ping reply from gateway like 192.168.20.1
  # In some cases gateway might not reply; then we can check for a secondary gateway

  $wifi_bssid_list=netsh wlan sh net mode=bssid
  # assuming wifi is enabled
  # wifi check is required as long as separate PC has not been bought
  if ($wifi_bssid_list | Select-String "no wireless interface") {
    # Detect using LAN
    # Gateway IP for lan
    $GatewayIP = "192.168.20.1"
    # ref: http://blogs.technet.com/b/heyscriptingguy/archive/2012/02/24/use-powershell-to-test-connectivity-on-remote-servers.aspx
    if (Test-Connection -Cn $GatewayIP -BufferSize 16 -Count 1 -ea 0 -quiet) {
      $res = $false
    }
  }
  elseif (($wifi_bssid_list | Select-String REVE) -Or ($wifi_bssid_list | Select-String VPN_TP-LINK_8th_Floor)) {
     $res = $false
  }
  return $res
}#>

<#
.SYNOPSIS
Settings for Home or Work or any other place
.DESCRIPTION
When a new test is added int the test API, create a new test on the portal with the url to execute the test. When a test is removed, disable it on the azure portal.
.PARAMETER IsWorkPlace
Need to be changed if we want to support more workstations.
.EXAMPLE
ApplyWSSettings
ApplyWSSettings $true
#>
function ApplyWSSettings([bool] $IsWorkPlace = $false) {
  # As we are getting "Unable to modify shortcut error", doing this from here; run only in office, I can't change the console properties in Win8 there
  # if ($Env:SESSIONNAME -And $Env:SESSIONNAME.StartsWith('RDP')) { }
  # if ($PSVersionTable.PSEdition -eq 'Core') { }
  $screen_width = 3840
  $screen_height = 2160

  # Get display proportionat size: CurrentHorizontalResolution, CurrentVerticalResolution
  # Since NVidia CUDA installation and driver updates we now have more than one video controller
	# Handle cases that some systems only have one Video Display
  # Only Powershell (Windows Desktop) has GWMI
  if ($PSVersionTable.PSEdition -eq 'Desktop') {
	  $screen_obj = (GWMI win32_videocontroller)[0]
	  if (! $screen_obj) { $screen_obj = (GWMI win32_videocontroller) }
    $screen_width = [convert]::ToInt32([string] ($screen_obj.CurrentHorizontalResolution))
    $screen_height = [convert]::ToInt32([string] ($screen_obj.CurrentVerticalResolution))
  }

  # 10 24 is okay for aspect ratio 16:9
  # 9 22 for 1366x768

  # Resolution: 1920x1080, default aspect ratio, approx result: 198, 33.75
  # This resolution should not be default anymore
  if ($screen_height -eq 1080 -And $screen_width -eq 1920) {
    $console_width = $screen_width/8.27586206896552
    $console_height = $screen_height/32
  }
  # Aspect Ratio: 5:4 - HSL library monitor, approx result 155, 40
  elseif (($screen_height*5) -eq ($screen_width*4)) {
    $console_width = [int] ($screen_width/10)
    $console_height = [int] ($screen_height/21)
  }
  # Current notebook: 3840x2160, aspect ratio (16:9), expected result approx, 294 37
  else {
    $console_width = $screen_width/13
    $console_height = $screen_height/59
  }

  # Write-Host "debug width $screen_width height $screen_height"
  # Write-Host "debug width $console_width height $console_height"
  $WSTitle = $(if ($psConsoleType -eq 'ML' ) { "Machine Learning Workstation" } else { $(if ($IsWorkPlace) { "FB Workstation" } else { "Matrix Workstation" }) })
  ResizeConsole $WSTitle 9999 $console_width $console_height
  Write-Host -NoNewline "Applying settings on "
  Write-Host -NoNewline $WSTitle -foregroundcolor Blue
  # ref https://stackoverflow.com/q/2085744
  Write-Host " for" $Env:UserName "`r`n"

  # For Workplace docu from past
  # As we are getting "Unable to modify shortcut error", doing this from here; run only in office,
  # I can't change the console properties in Win8 there
  # Banglalion info is no more required. Besides it is not working still I have come to US
  # if(SingleInstanceRunning -and $NET_STATUS) { .\Show-Blpackageinfo.ps1 }
}

# Check whether it is a new day after last login
function LoginNotDone() {
  # [bool] $updateDone = $true
  # required for hajirakhata login
  # hajirakhata login checks if it is set to false to satisfy final condition

  $CurDate = [int] $(Get-Date).Day

  if (! (Test-Path date.txt)) { "32" | Out-File .\date.txt }
  $PreDate = [int] $(cat date.txt)

  if ($CurDate -ne $PreDate) {
    # Update Login Status
    # Login manually if hk-login fails
    $CurDate | Out-File .\date.txt
    return $true
  }
  return $false
}

# Currently only updates fftsys repository using git
function UpdateCoreRepo() {
  # update scripts if internet is available # not required: and day is a new day
  if ($NET_STATUS) {
    git pull origin master
    Write-Host " "
  }
  else {
    Write-Host "Scripts not updated. Internet is not available."
  }
}

function ShowGadgets() {
  # Display weather update
  if ($NET_STATUS) {
    .\Weather-Update
  }
  else {
    Write-Host "Weather info retrieval skipped`n"
  }
}

# This should be improved
function StartCustomPrcoesses() {
  if($NET_STATUS) {
    # Shame this 64 bit chrome is installed in 32 bit program files
    if ($HOST_TYPE.Equals("PC_NOTEBOOK") -or $HOST_TYPE.Equals("OFFICE_WS") -or $HOST_TYPE.Equals("CS_GRAD_LAB_1227")) {
      # Start-Process-Single 'chrome' 'Google Chrome' "${Env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe" $false
		Start-Process-Single 'chrome' 'Google Chrome' ''
		Start-Process-Single 'notepad++' 'Notepad++' ''
		if ($HOST_TYPE.Equals("OFFICE_WS")) {
			Start-Process-Single 'outlook' 'MS Outlook' ''
			# Because EXE and MSI custom installation option isn't available
			Start-Process-Single 'teams' 'MS Teams crap..' 'C:\Users\v-mdra\AppData\Local\Microsoft\Teams\Update.exe' $false @('--processStart', 'Teams.exe')
			# C:\Users\v-mdra\AppData\Local\Microsoft\Teams\Update.exe --processStart "Teams.exe"
		}
    }
    elseif ($HOST_TYPE.Equals("VSINC_SERVER_2008")) {
      Start-Process-Single "iexplore" "Internet Explorer" "C:\Program Files\Internet Explorer\iexplore.exe" $false
      # Start-Process iexplore
    }
  }
  else {
    Write-Host "Starting processes skipped."
    return
  }
  <# Fix Program Files for x86, residential PC is x86
  if (${Env:PROCESSOR_ARCHITECTURE}.Equals("x86")) {
    ${Env:ProgramFiles(x86)} = $Env:ProgramFiles
    Write-Host "Var set to" ${Env:ProgramFiles(x86)}
  }#>
}

# Support for IsRegAppPath = False, not required anymore
function Start-Process-Single([string] $ProcessRunCommand, [string] $ProcessName, [string] $ProcessPath, [bool] $IsRegAppPath = $true, [string[]] $pArgs) {
  if (Get-Process $ProcessRunCommand -ErrorAction SilentlyContinue) {
    Write-Host "$ProcessName is already running"
  }
  elseif ($IsRegAppPath) {
    Write-Host "Starting $ProcessName"
    # this for fb dev-vm
    if ($ProcessRunCommand -eq 'chrome') { Start-Process $ProcessRunCommand --ignore-certificate-errors }
    else { Start-Process $ProcessRunCommand }
    # some time for monster chrome to consume resources
    if ($ProcessRunCommand -eq 'chrome') { Start-Sleep 2 }
  }
  elseif ((Test-Path "$ProcessPath")) {
    Write-Host "Starting $ProcessName"
	if ($pArgs) { Start-Process -FilePath $ProcessPath -ArgumentList $pArgs }
	else {Start-Process $ProcessPath}
  }
  else {
    Write-Host "$ProcessName is not installed."
  }
}

<#
    In future selectively choose what paths should be in global var
#>
function UpdateVisualStudioDevToolsPath() {
  # C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\Microsoft SDKs\F#\3.0\Framework\v4.0\;C:\Program Files (x86)\Microsoft Visual Studio 11.0\VSTSDB\Deploy;C:\ProgramFiles (x86)\Microsoft Visual Studio 11.0\Common7\IDE\;C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\BIN;C:\Program Files (x86)\Microsoft Visual Studio11.0\Common7\Tools;C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Windows\Microsoft.NET\Framework\v3.5;C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\VCPackages;C:\Program Files (x86)\HTML Help Workshop;C:\Program Files (x86)\Microsoft Visual Studio 11.0\Team Tools\Performance Tools;C:\Program Files (x86)\Windows Kits\8.0\bin\x86;C:\Program Files (x86)\Microsoft SDKs\Windows\v8.0A\bin\NETFX 4.0 Tools;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\;
  # in future
  # Update path environment variable for Visual Studio Tools
  if (Test-Path "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\BIN") {
    Write-Host "Initialized Visual Studio 11.0 Tools"
    # VS 2012
    $Env:path += ";C:\Program Files\Microsoft Visual Studio 10.0\VSTSDB\Deploy;C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE\;C:\Program Files\Microsoft Visual Studio 10.0\VC\BIN;C:\Program Files\Microsoft Visual Studio 10.0\Common7\Tools;C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Windows\Microsoft.NET\Framework\v3.5;C:\Program Files\Microsoft Visual Studio 10.0\VC\VCPackages;C:\Program Files\HTMLHelp Workshop;C:\Program Files\Microsoft Visual Studio 10.0\Team Tools\Performance Tools;C:\Program Files\Microsoft SDKs\Windows\v7.0A\bin\NETFX 4.0 Tools;C:\Program Files\Microsoft SDKs\Windows\v7.0A\bin"

    # VS 2010
    # $Env:path += ";C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files (x86)\Microsoft SDKs\F#\3.0\Framework\v4.0\;C:\Program Files (x86)\Microsoft Visual Studio 11.0\VSTSDB\Deploy;C:\ProgramFiles (x86)\Microsoft Visual Studio 11.0\Common7\IDE\;C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\BIN;C:\Program Files (x86)\Microsoft Visual Studio11.0\Common7\Tools;C:\Windows\Microsoft.NET\Framework\v4.0.30319;C:\Windows\Microsoft.NET\Framework\v3.5;C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\VCPackages;C:\Program Files (x86)\HTML Help Workshop;C:\Program Files (x86)\Microsoft Visual Studio 11.0\Team Tools\Performance Tools;C:\Program Files (x86)\Windows Kits\8.0\bin\x86;C:\Program Files (x86)\Microsoft SDKs\Windows\v8.0A\bin\NETFX 4.0 Tools;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\"
  }
}

[bool] $isSinglePS=$false
function SingleInstanceRunning()
{
  $isSinglePS = $Global:isSinglePS
  if ($isSinglePS) {
    return $isSinglePS
  }
  if (GetProcessInstanceNumber "pwsh" -lt 2) {
    $isSinglePS = $true
  }
  $Global:isSinglePS = $isSinglePS
  return $isSinglePS
}

# Get number of instances of a process
function GetProcessInstanceNumber([string]$process)
{
  @(Get-Process $process -ErrorAction 0).Count
}

#####################    Function Definition Ends       #####################################
#######################################################################################################

function Main() {
  # Set up variables for Program Files
  $Env:PFilesX64 = 'D:\PFiles_x64\choco'
  $Env:PFilesX86 = 'D:\PFiles_x86\choco'

  if (SingleInstanceRunning) {
    # When powershell profile is not fixed, this has to be set manually for first time
    # FixProfile "C:"
    # FixProfile "D:"
    FixGit
  # Add Matrix PS dir to Path
  $Env:Path +=  ';' + $Env:PS_SC_DIR
    if ($HOST_TYPE.Equals("VSINC_SERVER_2008")) { FixSINCEnvPath }
  }
  else {
    $n = GetProcessInstanceNumber "powershell"
    Write-Host -NoNewline "Initializing powershell instance $n.."
  }

  # Initialization function; cannot run until profile and svn has been fixed
  # Initialization operations like deleting files before starting
  InitializeScript "${Env:PS_SC_DIR}\tmp.txt"
  $NET_STATUS = GetInternetNetStatus

  <#
  No need to detect REVE's network anymore
  # temporarily override $matrix variable with office net availability checking
  # later we will turn this off when we buy separate PC
  if ($NET_STATUS) {
    # this is broken: variable $IS_MATRIX is obsolete
    $HOST_TYPE = NotDetectedOfficeNetwork
    # Write-Host "[debug] value of host type" $HOST_TYPE
  }
  #>

  # Apply settings
  if ($HOST_TYPE.Equals("OFFICE_WS")) {
    ApplyWSSettings $true
  }
  elseif ($HOST_TYPE.Equals("VSINC_SERVER_2008")) { ApplyWSSettings "vsync" }
  else { ApplyWSSettings }

  if (SingleInstanceRunning) {
    # Update Repository
    UpdateCoreRepo
    # for some reason it keeps failing if I put it after 'ss help'
    if ($psConsoleType -eq 'ML') {
      $Env:Path += ';D:\PFiles_x64\choco\python3;D:\PFiles_x64\choco\python3\Scripts'
    }
    elseif ($psConsoleType -eq 'MS-Speech') { .\Speech-Initialize }

    # Current gadgets are weather gadget
    # ShowGadgets
    # Start other most frequently opened processes
    StartCustomPrcoesses
  }
  else {
    Write-Host  "`t`t`[Ready`]"
  }
  # Currently updates to add visual studio 2012 tools with Windows SDK
  # UpdateVisualStudioDevToolsPath

  # Show brief help
  ss help
}

Main
