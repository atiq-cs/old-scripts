<# Logout script
 # What does it do?
 # 	1. Create Bakup folder[$env:PS_SC_DIR\Bakup] if doesn't exist
 #  2. Once init.ps1 is performed we are sure that file $profile exists

     Find current powershell profile path and copies current changed profile there
		which means change in current profile (ss ep) come into effect when next time powershell is run.
 #>

# CMD arg validation
if ($args.Count -eq 0) {
  $cmd = [string] ""
}
elseif ($args.Count -eq 1) {
  $cmd = [string]$args
  if (-not $cmd.Equals("skipsvn")) {
    Write-Host -ForegroundColor Red "Logout: wrong cmd arg!`r`nCurrently only supported argument is skipsvn.`r`n"
    break
  }
}
else {
  Write-Host "Wrong cmd args!"
  break
}

# function definition starts
function UpdatePSProfile() {
  # only perform if file has changed different
  if (Compare-Object -ReferenceObject (Get-Content $env:PS_SC_DIR\Microsoft.PowerShell_profile.ps1) -DifferenceObject (Get-Content $PROFILE)) {
    ######## Get local copy of profile #####################
    Write-Host "Bringing local copy of profile into documents dir"

    # Create Bakup folder if doesn't exist
    if ( -not (Test-Path $env:PS_SC_DIR\Bakup)) { New-Item -ItemType Directory $env:PS_SC_DIR\Bakup }


    # If there is a folder called WindowsPowerShell inside Bakup force delete it and copy
    # We are using copy instead of move so that next get-item command works
    Copy-Item -Force $profile $env:PS_SC_DIR\Bakup

    #$ProfileDir = $profile.Remove($profile.LastIndexOf("\"), $profile.Length-$profile.LastIndexOf("\"));
    # Easier way: not the parent of the parent
    #$ProfileDir = (Get-Item $profile).Directory.Parent.FullName
    $ProfileDir = (Get-Item $profile).Directory.FullName

    if ( -not (Test-Path $ProfileDir)) { New-Item -ItemType Directory $ProfileDir }
    # Force because previous file still exists there
    Copy-Item -Force $env:PS_SC_DIR\Microsoft.PowerShell_profile.ps1 $ProfileDir
  }
}


function PerformSVNCommit() {
  # Commit scripts
  Write-Host "Committing scripts back"
  $logFilePath = "$env:PS_SC_DIR\..\Conf\svnerr.log"

  if (Test-path $logFilePath) { rm $logFilePath }

  #(& $env:PS_SC_DIR\svn.ps1 ci 1) 2> >(tee svnlog.txt >&2)
  #(& $env:PS_SC_DIR\svn.ps1 ci 1)>(tee Conf\svnout.log) 2> >(tee Conf\\svnerr.log >&2)
  (& $env:PS_SC_DIR\svn.ps1 ci 1) 2> $logFilePath

  if (!(Test-path $logFilePath) -or (cat $logFilePath | select-string "fail")) {
    #cat $env:PS_SC_DIR\Conf\svnerr.log
    Write-Host "Scripts not comitted!"
    Write-Host "`nError log`n======================================================"
    cat $logFilePath
  }
  else {
    Write-Host "Upload success"
    Write-Host "Shutting down shell.."
    Start-Sleep -s 3

    #Reference for $host exit: http://mshforfun.blogspot.com/2006/08/do-you-know-there-is-host-variable.html
    $host.SetShouldExit(0)

    <# Experiment
    Write-Host "Press any key.. "
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")     # reference: http://technet.microsoft.com/en-us/library/ff730938.aspx
    Write-Host "You entered $x"
    #>

  }
}

function Main() {
  UpdatePSProfile
  
  if ($cmd.Equals("skipsvn")) {
    Write-Host "Ignoring SVN commit!"
    Write-Host "Shutting down shell.."
    Start-Sleep -s 3
    $host.SetShouldExit(0)
  }
  else { PerformSVNCommit }
}
# function definition ends

Main
