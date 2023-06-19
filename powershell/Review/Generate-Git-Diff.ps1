<# Date: 10/08/2017 13:57:17
 # Author: Atiq

 Goals:
 * Generate diff file and open with a prefered editor
 1. Minimal modification: does not apply git commands to change commit/staged
 2. If file path provided only a


 Tech spec,
 1. When no file path is specified on arg it assumes to run on the entire repository without
 limiting to a file

 Cmd line 'OpenFile' is in transition to `PSTool`. Check if proper unix to windows path conversion
 is necessary.

 Example Usage,
 $ Generate-Git-Diff.ps1 -s cached
 $ Generate-Git-Diff.ps1 general-solving/leetcode/024_swap-nodes-in-pairs.cs of
 $ Generate-Git-Diff.ps1 -s rev -r1 f47f86765 -r2 0d1b957da
 Works because of positional Parameters
 $ Generate-Git-Diff.ps1 rev f47f86765 0d1b957da
 Reference for Advanced Path Differentiation:
  https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%
  29.aspx?f=255&MSPPError=-2147217396
  https://www.dwheeler.com/essays/fixing-unix-linux-filenames.html
  https://en.wikipedia.org/wiki/Filename
  https://serverfault.com/questions/150740/linux-windows-unix-file-names-which-
  characters-are-allowed-which-are-unesc

 #>

Param(
  [Parameter(Mandatory=$false)] [alias("s")]  [string]$Status,
  [Parameter(Mandatory=$false)] [alias("r1")] [string]$rev1,
  [Parameter(Mandatory=$false)] [alias("r2")] [string]$rev2,
  [Parameter(Mandatory=$false)] [alias("f")]  [string]$FilePath
  )


# Check if it's Unix Style

# Check if it's Windows Style

# Forget all complication.
# Right now, for simplification, we substitute '/' with '\'

<#
It feels like in professional workplace they don't verify args. in scripts. However, I am accpeting
unix paths and staff. I should verify for now.
#>

function INIT() {
  $global:IsTargetAFile = $true
  if ($FilePath.Equals("")) {
    $global:IsTargetAFile = $false
  }
  # Default Location
  $Script:DefaultOutDir = 'D:\Docs\npp_files'
}

# Purpose of this function is to verify arguments
function VERIFY_PARAMETERS() {

  # Check if current location is a git repo
  if (! (Test-Path .git -PathType Container)) {
    return -1
  }
  if ($global:IsTargetAFile) {
    # expected only file path, no directory
    if (! (Test-Path $FilePath -PathType Leaf)) {
      return -1
    }
  }
  # check if outdir exists
  if (! (Test-Path $DefaultOutDir -PathType Container)) {
    return -1
  }

  if ($Status -eq '') {}
  elseif ($Status.Equals("openfile") -Or $Status.Equals("OpenFile") -Or $Status.Equals("of")) {
    $Status = 'OpenFile'
  }
  elseif ($Status.StartsWith("cach") -or $Status.StartsWith("cahc") -or $Status.StartsWith("ccah")) {
    $Status = '--cached'
  }
  # ToDo: verify parse for 9 or 7 chars hash
  elseif ($Status -ieq "rev") {
	# verify rev1 and rev2
  }
  else {
	Write-Host "Unrecognized argument: $Status"
    return -1
  } 

  return 0
}

# Start of Main function
function Main() {
  INIT

  if (VERIFY_PARAMETERS -le 0) {
    Write-Host "Error Abort!"
    break
  }
  
  $DiffFilePath = $DefaultOutDir + '\ProblemSolving-' + (Get-Date -UFormat "%Y-%m-%d") + '.diff'
  if ($global:IsTargetAFile) {
    if ($FilePath.Contains(':') -Or $FilePath.Contains('\')) {
      Write-Host "Windows Style Path Detected in Input!"
    }
    elseif ($FilePath.Contains('/')) {
      $FilePath = $FilePath -replace '/','\'
    }
  }

  # Debugging
  # Write-Host "got f path $FilePath diff path $DiffFilePath and cach stat $Status"

  # For opening a file with unix path using VS
  # This can be deprecated for direct commandline instead
  if ($Status.Equals("OpenFile")) {
    start devenv /Edit, $FilePath
    break
  }

  # This single commands can be put in google docs and can be used directly
  # Generate git diff
  if ($Status -ieq 'rev') {
	  git --no-pager diff -r $rev1 $rev2 $FilePath | Out-File $DiffFilePath
  }
  else {
	  git --no-pager diff $Status $FilePath | Out-File $DiffFilePath
  }
  Start-Process notepad++ $DiffFilePath
}

Main
