<#
.SYNOPSIS
  Automate `svn update` commit tasks

.DESCRIPTION
  Updated 2012-2013
  Copy over only the sinc site required modules

.EXAMPLE
1. Update project 7 to revision 3
  svn.ps1 up 7 3
  
2. See commit log for specific revision, for example revision 6
  svn.ps1 log 7 6

.PARAMETER Action
  co : checkout
  ci : commit
  up : update

.PARAMETER Limit
  number: will have maximum range, cannot exceed limit

.PARAMETER CommitLog
  commit log

.NOTES
  Demonstrations,
  - Manual command line argument manipulation / parsing
  - subversion command line examples i.e., commit, update

#>

# not required anymore, we can commit without starting a server
function SAStartService ([string] $ServiceName) {
    $arrService = Get-Service -DisplayName $ServiceName
    if ($arrService.Status -ne "Running"){
        Write-Host "Starting service $ServiceName"
        Start-Service $ServiceName
    }
    else {
        Write-Host "Service $ServiceName is running"
    }
}

$projectnum = 1000
$svnhost = "google"
$maxprojectnumber = 9

# Project Names
$ProjectNames = @(
  "Workspace and scripts",
  "Open GRE Words",
  "Wireshark Parser",
  "PingGUIn",
  "ShutDownTimer Win32",
  "TA Firmware",
  "J2ME callthrough dialer",
  "IM Dialer Emot Icons",
  "PC Dialer IM Unicode Integration on Progress"
)

# Project directories
$ProjectDirs = @(
  "$Env:PS_SC_DIR\..\", # Project 1: Scripts, we assume statically that project is always on drive e:
  "$Env:PS_SC_DRIVE\Sourcecodes\Web\GREWords",  # Project 2: open gre words
  "$Env:PS_SC_DRIVE\Sourcecodes\MFC\WS_Parser", # Project 3: WS Parser
  "$Env:PS_SC_DRIVE\Sourcecodes\MFC\P19_PingGUIn", # Project 4: PingGUIn
  "$Env:PS_SC_DRIVE\Sourcecodes\Win32\winAPI\P2_ShutDownTimer Win32", # Project 5: Shutdown timer
  "$Env:PS_SC_DRIVE\ATA VOIP\TAProjectUpdatedFirmware", # Project 6: TA Firmware
  "$Env:PS_SC_DRIVE\Sourcecodes\eclipsews03\iTelCallThroughDialer.S40",  # Project 7: J2ME callthrough dialer
  "$Env:PS_SC_DRIVE\Windows Project\IM Clients\TestEmoCustomControl", # Project 8: Emot Icons Custom Control development
  "$Env:PS_SC_DRIVE\Windows Project\IM Clients\P02_PC Dialer IM Unicode_SA_VersionControlled" # Project 8: Emot Icons Custom Control development
)

# error 1
if ($args.Count -lt 1) {
    Write-Host "Please provide at least 1 argument which is update or commit."
    break
}
# error 2
elseif ($args.Count -gt 3) {
    Write-Host "Please provide at most 3 arguments."
    break
}
# Take project number as input
elseif ($args.Count -eq 1) {
    Write-Host "No project number has been given. Please enter project number.`n`nCurrent project list:"
    for ($i=1; $i -le $maxprojectnumber; $i++) {
        $prname = $ProjectNames[$i-1];
        Write-Host "  $i. $prname"
    }
    # uncomment when input is implemented
    break
}

if ($args.Count -eq 3) {
    $commitlog = $args[2]
}

# Project Directories
$hostdb = @(
  "assembla", # Project 1: Scripts
  "google",  # Project 2: open gre words
  "google", # Project 3: WS Parser
  "google", # Project 4: PingGUIn
  "sourceforge", # Project 5: Shutdown Timer
  "officelocal", # Project 6: VOITPTA Firmware
  "officelocal", # Project 7: J2ME callthrough dialer
  "officelocal", # Project 8: Emot Icons Custom Control development
  "officelocal" # Project 8: Emot Icons Custom Control development
)
               
               
# Get project number
if ($projectnum -eq 1000) {
    $projectnum = [int] $args[1]
    $projectnum = $projectnum - 1
}

# total project = 4, last index = 3
if ($projectnum -gt $maxprojectnumber) {
    Write-Host "Select project index out of bound."
    break
}
else {
    $pName = $ProjectNames[$projectnum]
    Write-Host -NoNewline "Project" ($projectnum+1) $pName
}
               
$CurProjectDir = [string] $ProjectDirs[$projectnum]
$svnhost = [string] $hostdb[$projectnum]

if ($svnhost.Equals("assembla")) {
    Write-Host -NoNewline "[assembla] "
    $username='ASSEMBLA_USER_SAMPLE'
    $password="ASSEMBLA_PASS_SAMPLE"
}
elseif ($svnhost.Equals("google")) {
    Write-Host -NoNewline "[Google] "
    $username='GOOGL_USER_SAMPLE'
    $password='GOOGL_PASS_SAMPLE'
}
elseif ($svnhost.Equals("sourceforge")) {
    Write-Host -NoNewline "[sourceforge] "
    $username='SF_USER_SAMPLE'
    $password='SF_PASS_SAMPLE'
}
elseif ($svnhost.Equals("officelocal")) {
    Write-Host -NoNewline "[local collabnet subversion edge] "
    # Also start local service manually if that's an optimization on VC Service Running locally
    # SAStartService("CollabNet Subversion Edge")
    $username='LOCAL_COLLAB_USER_SAMPLE'
    $password='LOCAL_COLLAB_PASS_SAMPLE'
}
else {
    Write-Host "Host: $svnhost is not recognized. Please check command."
    exit
}

pushd
if (! (Test-Path $CurProjectDir)) {
    Write-Host "`nDirectory `"$CurProjectDir`" does not exist."
    exit
}

switch ($args[0]) {
    "up" {
         'Performing update '
         if ($commitlog) {
            # update to specified revision
            svn update $CurProjectDir -r $commitlog --username $username --password $password
         }
         else {
            svn update $CurProjectDir --username $username --password $password
         }
     }
    "ci" {
         'Performing commit'
         if ($commitlog) {
            svn commit $CurProjectDir --username $username --password $password -m "Manual commit $commitlog" 
         } else {
            svn commit $CurProjectDir --username $username --password $password -m "Automated commit $(get-date) from host $HOST_TYPE)"
         }
         if ($svnhost.Equals("officelocal")) {
            Write-Host -NoNewline "Forcing version update for local svn server. "
            svn update $CurProjectDir 
         }
     }
    "status" {
         Write-Host "listing"
         svn status $CurProjectDir
     }
    "info" {
         Write-Host "fetching repo information"
         svn info $CurProjectDir
     }
    "diff" {
        Write-Host "calculating diff"
        svn diff $CurProjectDir -r $commitlog
     }
    "log" {
        Write-Host "fetching log"
        if ($commitlog) {
            svn log $CurProjectDir -r $commitlog
        }
        else {
            svn log $CurProjectDir
        }
     }
     # For Testing Purposes
     default {
        Write-Host "svn experiment"
        # Debug
        # $commitlog
        #svn up $CurProjectDir -r $commitlog
        $cmd =$args[3] 
        Write-Host "$cmd"
        svn log $CurProjectDir -r $args[3]
     }
}
