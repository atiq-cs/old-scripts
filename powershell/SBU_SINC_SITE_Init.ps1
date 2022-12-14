<#
.SYNOPSIS
  Initialization script for custom powershell for use at SBU SINC Sites

.DESCRIPTION
  Updated 2014-2015
  Copy over only the sinc site required modules

.EXAMPLE

.NOTES
  Demonstrations,
  - Version Control Integration
  - Subversion usage along with a script despite the upgrade to git (mostly commented out)
  - Powershell UI properties through `ResizeConsole`

#>

#######################################################################################################
#####################     Functions Definitions Start      #####################################
#######################################################################################################

# function only for sinc site
function FixSINCEnvPath() {
  $PSPath = $Env:Path
  # remove MOLECULAR EVOLUTIONARY GENETICS ANALYSIS 
  $PSPath = $PSPath.replace("C:\Program Files (x86)\MEGA6;","")
  $PSPath = $PSPath.replace("C:\Program Files (x86)\Common Files\Intel\Shared Libraries\redist\intel64\compiler;","")
  $PSPath = $PSPath.replace("C:\Program Files (x86)\Common Files\Intel\Shared Libraries\redist\ia32\compiler;","")
  $PSPath = $PSPath.replace("C:\Program Files (x86)\Caminova\Document Express DjVu Plug-in\;","")
  $PSPath = $PSPath.replace("C:\Program Files\Citrix\Virtual Desktop Agent\;","")
  $PSPath = $PSPath.replace("C:\Program Files (x86)\Accelrys\Accelrys Draw 4.1\\lib;","")
  $PSPath = $PSPath.replace("C:\Program Files (x86)\Common Files\Intuit\QBPOSSDKRuntime;","")
  $PSPath = $PSPath.replace("C:\Program Files (x86)\QuickTime\QTSystem\;","")
  $PSPath = $PSPath.replace("C:\Program Files (x86)\PharosSystems\Core;","")
  $PSPath = $PSPath.replace("C:\Program Files\MATLAB\R2014a\bin;","")
  $PSPath = $PSPath.replace("C:\Program Files\MATLAB\R2014a\bin\win64;","")
  $PSPath = $PSPath.replace("C:\Program Files\SASHome\Secure\ccme4;","")
  $PSPath = $PSPath.replace("C:\Program Files\SASHome\x86\Secure\ccme4;","")
  $PSPath = $PSPath.replace("C:\Program Files (x86)\Citrix\system32;","")
  $PSPath = $PSPath.replace("C:\texlive\2014\bin\win32;","")
  $PSPath = $PSPath.replace("C:\Program Files (x86)\Asymptote;","")
  $PSPath = $PSPath.replace("C:\Program Files (x86)\Common Files\Citrix\System32;","")
  $PSPath = $PSPath.replace("C:\Program Files (x86)\SSH Communications Security\SSH Secure Shell;","")
  $PSPath = $PSPath.replace("C:\texlive\2013\bin\win32;","")
  $PSPath = $PSPath.replace("C:\app\rgonzalez\product\11.2.0\client_1;","")
  $PSPath = $PSPath.replace("C:\app\oracle\product\11.2.0\client_1\bin;","")

  $Env:Path = $PSPath
  if (! $PSPath.StartsWith("C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;")) {
    Write-Host "System path changed!"
  }
}

# Settings for virtual SINC site
function ApplyVSINCSettings() {
  # Only to change title
  # (Get-Host).UI.RawUI.WindowTitle = "SA VSINC Matrix Workstation"
  ResizeConsole "SA VSINC Matrix Workstation" 9999 185 45

  # Setting for V Sinc
  Write-Host "Applying Virtual SINC Site settings for $Env:username"
}

<#
Obsolete for now
function ApplyOfficeSettings() {
  ResizeConsole "SA SINC Workstation" 160 40

  # Setting for office
  if (SingleInstanceRunning) {
    Write-Host "Applying office settings on REVE Workstation for $Env:username"
  }

  # Attempt log-in if internet is set true  
  if($NET_STATUS) {
    if (LoginNotDone) {
      .\hk-LogIn.ps1
    }
    elseif (SingleInstanceRunning) {
      Write-Host "Already logged into hajirakhata.`n"
    }
  }
  else {
    Write-Host "Login skipped"
  }
}
#>

# Currently only updates fftsys_ws repository using git
function UpdateCoreRepo() {
  # Add git path if necessary
  # $Env:Path += ";"+$GitPath

  # update scripts if internet is available and day is a new day
  if ($NET_STATUS) {
    git pull origin master
    # .\svn.ps1 up 1
    Write-Host " "
    <#.\svn.ps1 up 1 | tee-object -filepath svnlog.txt
    #.\svn.ps1 up 1 > svnlog.txt
    
    if (cat svnlog.txt | select-string "revision") {
      Write-Host " "
    # if svn up is successful update state and date file
      if ($UPDATEDONE.Equals("FALSE")) {
        echo "$CurDate" > date.txt
        $UPDATEDONE = "TRUE"
      }
    }#>
  }
  else {
    Write-Host "Scripts not updated. Internet is not available."
  }
}


  <# Deprecated because we moved to MS Store App version of skype
   Let's get skype as well
  if ($HOST_TYPE.Equals("ORACLE_WS")) {
    # ss instead of start because in sinc site notepad++ is local
    # but this causes the script to stop execution after this point
    # ss notepad++
    # Write-Host "Starting skype"
    Start-Process-Single "skype" "Skype" "${env:ProgramFiles(x86)}\Skype\Phone\Skype.exe"
  }#>

