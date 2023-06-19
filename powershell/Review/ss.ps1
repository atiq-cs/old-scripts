<#
.SYNOPSIS
Provides shortcuts to various useful commands such as going to home dir, opening frequently accessed
files.
.DESCRIPTION
ss.ps1 is tied with an alias ss from powershell profile
ToDo: may be move all 'VSINC_SERVER_2008' stuff somewhere else.
.PARAMETER clArgs
Command line arguments
.EXAMPLE
ss cd
ss help
ss powershell
ss cmd
.NOTES
Technical notes:
  Argument problem fixed
  use when number of arguments is more than one
  $cargs = $args[1 .. ($args.Count)]

What's spirited syntax stuff
 if we are providing a file path prepending things like '.\'

ncpa ref: complete list of commands ref,
 http://pcsupport.about.com/od/tipstricks/a/control-panel-command-line.htm
 and other stuffs: window update: control wuaucpl.cpl
#>

param(
  [parameter(Mandatory=$true)]
  [string[]]$clArgs
)

function Main() {
  # Message ID represents correction of syntax, that means how much
  # lazy can we remain without modifying the string and we call this
  # superstition as spirit
  $msgid = 0

  # cmd is program, whereas cargs only args
  # we know for sure alias ss passes us at least one argument
  $cmd = [string] $clArgs[0]

  # switch starts, alphabetical order
  # ss cd: go home
  if ($cmd.Equals("cd")) { Set-Location $Env:PS_SC_DIR; break }

  # ss ep: edit profile
  elseif ($cmd.Equals("ep")) {
    Write-Host "Opening file: $Env:PS_SC_DIR\Microsoft.PowerShell_profile.ps1 for edit"
    # & $Env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell_ise.exe Microsoft.PowerShell_profile.ps1
    Start-Process devenv /Edit, $Env:PS_SC_DIR\Microsoft.PowerShell_profile.ps1
    break
  }

  # not supporting in cases sensitive variations
  elseif ($cmd.Equals("eh")) {
    # npp might not be installed: take into account
    # better way could be just try to check it from app paths
    $NPPPATH = " $Env:PFilesX64\npp\notepad++.exe"
    $EditorProgram="notepad++"
    $hostsFilePath = $Env:SystemRoot+'\System32\drivers\etc\hosts'
    if (-Not (Test-Path $NPPPATH) -Or (Get-Process $EditorProgram -ErrorAction SilentlyContinue)) {
      # process is running
      Write-Host "Please close existing $EditorProgram window and run the command again to open the file with notepad++. Or check if notepad++ is installed."
      $EditorProgram="notepad"
    }

    Write-Host "Opening file $hostsFilePath for edit with admin privilege"
    Try {
      Start-Process $EditorProgram -Verb Runas -ArgumentList $hostsFilePath -ErrorAction 'stop'
    }
    Catch {
      $_.Exception.Message
    }
  }

  elseif ($cmd -eq 'pwsh' -Or $cmd -eq 'Pwsh') {
    Write-Host "Starting elevated powershell core"
    Try {
      Start-Process pwsh -Verb Runas -ErrorAction 'stop'
    }
    Catch {
      $_.Exception.Message
    }
    break
  }

  elseif ($cmd -eq 'cmd') {
    Write-Host "Starting elevated command prompt"
    Start-Process cmd -Verb Runas -ErrorAction 'stop'
    break
  }

  elseif ($cmd -eq 'help') {
    ShowHelp
    break
  }

  # ss list-programs: list available registry programs
  elseif ($cmd -eq 'applist') {
    gci 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths'
    gci 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths'
    break
  }
  # Open Network Adapter Settings, ref above
  elseif ($cmd -eq 'ncpa') {
    control ncpa.cpl
    break
  }
  ## switch ends

  if ($clArgs.Count -gt 1) {
    $cargs = $args[1 .. ($args.Count)]
  }
  else {
    $cargs = "";
  }

  $origcmd = $cmd

  if ($cmd.StartsWith(".\") -or $cmd.StartsWith("./")) {
    $msgid += 1
  }
  elseif ($cmd.IndexOf("\") -eq "-1") {
    $cmd = ".\" + $cmd
  }

  #if ($cmd.EndsWith(".ps1") -or $cmd.EndsWith(".cmd") -or $cmd.EndsWith(".bat")) {
  if ($cmd.EndsWith(".ps1")) {
    $msgid = $msgid + 2
  }

  if ($msgid -eq 0) {
    # write.exe resolved a space was being added garbage
    # $regitem = dir "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" -recurse -include *notepad* | Select-Object -first 1
    # gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" -recurse -include *notepad* | Select-Object -first 1
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$cmd.exe"
    if (Test-Path $regPath) {
      $regitem = Get-ItemProperty $regPath
      # Get-ItemProperty $regPath
      $regcmd = $regitem."(default)"
      Write-Host "Starting program`: `"$regcmd`""
      # Modify the command so that arguments don't get splitted
      $regcmd = $regcmd.TrimStart("`"")
      $regcmd = $regcmd.TrimEnd("`"")
      & "$regcmd" $cargs
      break
    }
    elseif (!(Test-Path "$Env:PS_SC_DIR\$cmd.ps1")) {
      Write-Host "Please check your command"
      break
    }

  }
  elseif ($msgid -eq 1) {
    Write-Host "* Spirited syntax"
  }
  elseif ($msgid -eq 3) {
    Write-Host "* Spirited syntax *"
  }

  & $Env:PS_SC_DIR\$cmd $cargs
}

# Entry Point
Main
