<# Date: 10/12/2017 23:55:38
 # Author: Atique

 .\Fix-MediaFileName.ps1 file_path normalize
 .\Fix-MediaFileName.ps1 file_path joy
 .\Fix-MediaFileName.ps1 file_path phorsty
 .\Fix-MediaFileName.ps1 dir_path -p joy
 .\Fix-MediaFileName.ps1 dir_path -p norm
 .\Fix-MediaFileName.ps1 dir_path -p psarip

Steps:
 Steps are laid out in `RenameFile` method
#>

Param(
  [Parameter(Mandatory=$true)] [alias("s")] [string]$StreamPath,
  [Parameter(Mandatory=$false)] [alias("p")] [string]$Pattern
)

# Purpose of this function is to verify arguments
function VERIFY_PARAMETERS() {
  if ([string]::IsNullOrEmpty($StreamPath) -Or !(Test-Path $StreamPath)) {
    Write-Host "Please provide correct source media path. Current input `"" `
    "$StreamPath`"`n"
    return -1
  }
  elseif (Test-Path $StreamPath -PathType Container) {
    $script:IsSourceDirectory = $true
  }

  if ([string]::IsNullOrEmpty($Pattern)) {
    $Pattern = "normalize"
  }

  # support minor spelling mistakes
  if ($Pattern.ToLower().Equals("norm") -Or $Pattern.ToLower().Equals("nomr")) {
    $Pattern = "normalize"
  }
  elseif ($Pattern.ToLower().Equals("snap") -Or $Pattern.ToLower().Equals("snaph")) {
    $Pattern = "snahp"
  }
  if (! ( $Pattern.ToLower().Equals("normalize") -Or $Pattern.ToLower().Equals(
    "joy") -Or $Pattern.ToLower().Equals("snahp") -Or $Pattern.ToLower().Equals(
    "phrosty") -Or $Pattern.ToLower().Equals("psarip") -Or $Pattern.ToLower().
    Equals("other") )) {
    return -1
  }
  # ensure change is global
  $script:Pattern=$Pattern
  return 0
}

function SupportedExtension([string] $FileName) {
  # subrip file renaming supported as well
  $SupportedExtList = ".mp4", ".m4v", ".mkv", ".flv", ".mnft", ".avi", ".mpg",
  ".mpeg",".3gp",".srt"

  for ($i=0; $i -lt $SupportedExtList.Count; $i++) {
    if ($FileName.EndsWith($SupportedExtList[$i]) -or $FileName.EndsWith(
    $SupportedExtList[$i].ToUpper())) {
      return $true
    }
  }
  return $false
}


function GetNewNameByPattern([string] $OldName) {  
  <#
    Suggestions for normalize feature
    should be auto supported,
     Blazing Saddles 1974.1080p.x265.10bit.Joy
    support input patterns like this
     Blazing Saddles 1974.1080p.x265.10bit.Joy
  #>
  Write-Host "pat" $script:Pattern
  if ($Pattern.Equals("normalize")) {
    $resMatch=([regex] "(.*).(\d\d\d\d).(1080p|720p|brrip|BrRip|br\.x265)(.*)"
      ).Match($OldName).Groups
    $year = $resMatch[2].Value
    $index = [int] 3
    if ([string]::IsNullOrEmpty($year)) {
      $resMatch = ([regex] `
      "(.*).\((\d\d\d\d)\).(1080p|720p|brrip|BrRip|br\.x265)(.*)").Match($OldName).Groups
      $year = $resMatch[2].Value
    }
    if ([string]::IsNullOrEmpty($year)) {
      $resMatch = ([regex] `
      "(.*).(\d\d\d\d).(\w+.)(1080p|720p|brrip|BrRip|br\.x265)(.*)").Match($OldName).Groups
      $year = $resMatch[2].Value
      $index++
    }
    if ([string]::IsNullOrEmpty($year)) {
      $resMatch = ([regex] `
      "(.*).\((\d\d\d\d)\).(\w+.)(1080p|720p|brrip|BrRip|br\.x265)(.*)").Match($OldName).Groups
      $year = $resMatch[2].Value
      $index++
    }
    $mediaName = $resMatch[1].Value
    $resolution = [string] ""
    if ($index -gt 3) {
      $resolution = $resMatch[$index-1].Value
    }
    $resolution += $resMatch[$index++].Value
    $restSpec = $resMatch[$index].Value
    Write-Host "debug 1 $mediaName"
    $newMediaName = $mediaName -replace '\.',' '
    Write-Host "debug 2 $newMediaName"
    $newMediaName = [CultureInfo]::CurrentCulture.TextInfo.ToTitleCase($newMediaName.ToLower());
    $newMediaName += ' (' + $year + ').' + $resolution + $restSpec
    if ([string]::IsNullOrEmpty($mediaName) -Or [string]::IsNullOrEmpty($year)`
      -Or [string]::IsNullOrEmpty($resolution) -Or [string]::IsNullOrEmpty( `
      $restSpec)) {
      return $null
    }
  }
  # supports tigole, YiFi when it has same pattern
  # separate joy, Tigole, YIFY using detect pattern
  elseif ($Pattern.Equals("joy")) {
    $newMediaName = $OldName -replace ' \(1080p x265 Joy\)',
    '.1080p.x265.Joy' -replace ' \(1080p x265 10bit Joy\)',
    '.1080p.x265.10bit.Joy' -replace ' \(1080p H265 Joy\)',
    '.1080p.x265.Joy' -replace '\(1080p.x265.Joy\)','1080p.x265.Joy' `
    -replace ' \(1080p x265 10bit Tigole\)','.1080p.x265.10bit.Tigole' `
    -replace '1080p x265 10bit Tigole','.1080p.x265.10bit.Tigole' `
    -replace ' 1080p BrRip x264 YIFY','.1080p.BrRip.x264.YIFY' `
    -replace '\.x265-Joy','.Joy'
  }
  elseif ($Pattern.Equals("psarip")) {
    # correct season#, episode# and resolution abbreviation
    $newMediaName = $OldName -replace '\.2CH\.x265\.HEVC-PSA','.psarip' -replace '\.x265\.HEVC-PSA','.psarip'
  }
  elseif ($Pattern.Equals("phrosty")) {
    # correct season#, episode# and resolution abbreviation
    $newMediaName = $OldName -replace '^e0','S17E0' -replace '^e1','S17E1'
      -replace ' \(1920x1080\)','.1080p' -replace ' 1920x1080','.1080p'
  }
  # snahp.it, this might contain joy pattern inside like
  #  [snahp.it]Chuck.S01E01.name.(1080p.x265.Joy)_snahp.it.mkv
  # Run this first for dirty names
  #  .\Stream-Converter.ps1 namefixonly
  elseif ($Pattern.Equals("snahp")) {
    # correct season#, episode# and resolution abbreviation
    $newMediaName = $OldName -replace 'Chuck\.S01','S01' -replace
      '\(snahp\.it\)','' -replace '_snahp\.it',''
  }
  <#
    More patterns to support,
     [snahp.it]Rear.Window.1954.1080p.Bluray.10bit.x265.AAC-HazMatt_snahp.it.mkv
  #>
  return $newMediaName
}


<#
  Renames single file
 - detect pattern
 - If not detected output that..
 - Otherwise use that pattern name fix.
#>
function RenameFile([string] $SFilePath) {
  if (! (SupportedExtension $SFilePath)) {
    Write-Host "Extension not supported; skipping $SFilePath"
    return -1
  }

  Write-Host "file $SFilePath pat $Pattern"

  $InputExt = Get-ChildItem $SFilePath | % {$_.Extension}
  $BaseName = Get-ChildItem $SFilePath | % {$_.BaseName}
  $curBaseName = $BaseName+$InputExt
  # $InputFileBaseName = $SFilePath.Substring(0, $SFilePath.Length - $InputExt.Length)
  # $OutputFilePath=$InputFileBaseName + $OutputExt

  $script:Pattern = $Pattern = DetectPattern($curBaseName)

  Write-Host "Old name: $curBaseName"
  $newMediaName = GetNewNameByPattern($curBaseName)
  Write-Host "New name: $newMediaName"

  # Providing specific error messages does not work - since our input regex is only for bad ones
  if ([string]::IsNullOrEmpty($newMediaName) -Or $curBaseName.Equals($newMediaName)) {
    Write-Host Write-Host "Skipping $curBaseName.."
  }
  else {
    Rename-Item $SFilePath -NewName $newMediaName
  }
}

# Start of Main function
function Main() {
  if (VERIFY_PARAMETERS -le 0) {
    break
  }

  if ($script:IsSourceDirectory) {
    # Perform operation for each stream file, recursively
    foreach ($item in Get-ChildItem -Recurse $StreamPath) {
      if (! $item.PSIsContainer) {
        $fName = $item.FullName
        if (SupportedExtension($fName)) {
          RenameFile "$fName"
        }
        else {
          Write-Host "Extension not supported; skipping $fName"
        }
      }
    }
  }
  else {
    RenameFile "$StreamPath"
  }
}

Main
