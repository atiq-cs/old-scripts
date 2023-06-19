<# Date: 10/06/2017 18:01:22
 # Author: Atique

verify name in imdb format (then subtitle & movie archive creation would work)
Given movie name if the subtitle exist rar them together..
take movie name from recognized video files..

if file size is small then m2 can be applied

allow recurse..

Desc:

Usage Example,
 .\winrar.ps1 -a c -dir E:\Upload\SouthPark\S17.phrosty

Cmd Example:
v1048576
1073742
A raw command,
& 'C:\Program Files\WinRAR\Rar.exe' a 'D:\Movies\upload\Batman Begins (2005)_1080p.10bit.BluRay.x265.HEVC.6CH-MRN.rar' -prx -ep1 -ma5 -v1073742 -m2 'D:\Movies\upload\Batman Begins (2005)_1080p.10bit.BluRay.x265.HEVC.6CH-MRN.mkv' 'D:\Movies\upload\Batman Begins 2005 (1080p x265 10bit Tigole).srt'
& 'C:\Program Files\WinRAR\Rar.exe' a 'D:\Movies\upload\The Dark Knight Rises (2012).1080p.x265.Joy.rar' -prx -ep1 -ma5 -v1073742 -m1 D:\Movies\upload\up\The*
& 'C:\Program Files\WinRAR\Rar.exe' a 'D:\Movies\upload\The Dark Knight Rises (2012).1080p.x265.Joy.rar' -prx -ep1 -ma5 -v1073741824b -m1 D:\Movies\upload\up\The*

D:\Movies\upload
& 'C:\Program Files\WinRAR\Rar.exe' a 'D:\Movies\upload\The Shawshank Redemption (1994).1080p.x265.Joy.rar' -prx -ep1 -ma5 -v1073741824b -m2 'E:\Upload\The Shawshank Redemption (1994)*'

Refeferences:
Get-Date msdn
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-5.1

#>

Param(
  [Parameter(Mandatory=$true)] [alias("a")] [string]$Action,
  [Parameter(Mandatory=$false)] [alias("s")] [string]$StreamPath,
  [Parameter(Mandatory=$false)] [alias("dir")] [string]$SourceDir
  )

$RAREXE='C:\PFiles_x64\choco\WinRar\Rar.exe'
[bool] $global:IsSourceDirectory = $true
[int] $global:CompressLevel = 1

# Purpose of this function is to verify arguments
function VERIFY_PARAMETERS() {
  if ($SourceDir.Equals("")) {
    $global:IsSourceDirectory = $false
  }

  if (! (Test-Path -path $RAREXE)) {
    Write-Host "Please correct RAR Binary path and then run the script again.`n"
    return -1
  }

  # source is a directory, verify directory
  if ($global:IsSourceDirectory) {
    if (! (Test-Path -path $SourceDir -pathtype Container)) {
      Write-Host "Please provide correct source directory path.`n"
      return -1
    }
  }
  elseif ($StreamPath.Equals("")) {
    Write-Host "Input file is not specified!`n"
    return -1
  }
  # source dir not provided, process stream file path
  elseif (! $StreamPath.Equals("") -and ! (Test-Path -path $StreamPath -pathtype leaf)) {
    Write-Host "Incorrect input file path `"$StreamPath`".`n"
    return -1
  }

  if ($Action.ToLower().Equals("c") -Or $Action.ToLower().Equals("x") -Or $Action.ToLower().Equals("create") -Or $Action.ToLower().Equals("extract")) {
    return 0
  }
  return -1
}

function SupportedExtension([string] $FileName) {
  # movie files, ebook formats
  # optional formats to support for other features
  #   , ".pdf", ".dts"
  $SupportedExtList = ".mp4", ".m4v", ".mkv", ".flv", ".mnft", ".avi", ".mpg", ".mpeg",".3gp", ".epub"

  for ($i=0; $i -lt $SupportedExtList.Count; $i++) {
    if ($FileName.EndsWith($SupportedExtList[$i]) -or $FileName.EndsWith($SupportedExtList[$i].ToUpper())) {
      return $true
    }
  }
  return $false
}

function GetMediaName([string] $SFilePath, [string] $showType) {
  $BaseName = Get-ChildItem "$SFilePath" | % {$_.BaseName}
  $OutputExt = ".srt"
  $OldName = $BaseName+$OutputExt

  if ($showType.Equals('TVShow')) {
    # TV Show
    # previous: "(.*S\d\dE\d\d)(.*)(1080|720|brrip|BrRip|.*)(.*)"
    $resMatch = ([regex] "^(E\d\d)").Match($BaseName).Groups
    # Season#, Episode#
    $seDesc = $resMatch[1].Value
    # $title = $resMatch[2].Value
    # $resolution = $resMatch[3].Value
    # $restSpec = $resMatch[4].Value
    Write-Host "debug info 1: EP $BaseName"
    Write-Host "debug info 2: EP: $seDesc" #  t: $title res: $resolution rest: $restSpec"
  
    <# Error check, title1 and title2 can be null
    example for which these are all null:
    'S02E01 VO.srt'
    if ([string]::IsNullOrEmpty($seDesc) -Or [string]::IsNullOrEmpty($resolution) -Or [string]::IsNullOrEmpty($restSpec))  #>
    if ([string]::IsNullOrEmpty($seDesc))
    {
      return $null
    }
    $SubBaseName = $seDesc
    # if (! [string]::IsNullOrEmpty($title)) {
    #   $SubBaseName = $title + $seDesc
    # }
    # will fail for bare name S01E01.mp4
    Write-Host "TV Show name detected: $SubBaseName"
    $ParentDirPath = (Get-Item $SFilePath).Directory.FullName
    # this file might not exist, added a check
    # appky this syntax gci D:\Movies\up_d\* -Include *.txt, *.gif
    # process for multiples files returned in result
    # [string]::Join(' ',(gci D:\Movies\up_d\* -Include *.txt, *.gif).FullName)
    $newMediaName = (Get-ChildItem "$ParentDirPath\$SubBaseName*.srt").FullName
    if ([string]::IsNullOrEmpty($newMediaName) -Or ! $newMediaName.EndsWith(".srt")) {
      $newMediaName = (Get-ChildItem "$ParentDirPath\$SubBaseName*.ass").FullName
    }
    if ([string]::IsNullOrEmpty($newMediaName)) {
      return $null
    }
  }
  # wouldn't reach here if it's TV Show
  elseif ($showType.Equals('Movie')) {
    # strict input pattern
    # Run .\Fix-MediaFileName.ps1 first
    $resMatch = ([regex] "(.*).\((\d\d\d\d)\).(1080p|720p|brrip|BrRip)(.*)").Match($BaseName).Groups
    $year = $resMatch[2].Value
    if ([string]::IsNullOrEmpty($year)) {
      $resMatch = ([regex] "(.*).(\d\d\d\d).(1080p|720p|brrip|BrRip)(.*)").Match($BaseName).Groups
    }

    $mediaName = $resMatch[1].Value
    $year = $resMatch[2].Value
    $resolution = $resMatch[3].Value
    $restSpec = $resMatch[4].Value

    # Error check
    if ([string]::IsNullOrEmpty($mediaName) -Or [string]::IsNullOrEmpty($year) -Or [string]::IsNullOrEmpty($resolution) -Or [string]::IsNullOrEmpty($restSpec)) {
      return $null
    }
    $SubBaseName = "$mediaName ($year)"
    Write-Host "Movie name detected: $SubBaseName"
    $ParentDirPath = (Get-Item $SFilePath).Directory.FullName
    # this file might not exist, added a check
    $newMediaName = (Get-ChildItem "$ParentDirPath\$SubBaseName*.srt").FullName
    if ([string]::IsNullOrEmpty($newMediaName) -Or ! $newMediaName.EndsWith(".srt")) {
      return $null
    }
  }
  # other types yet to implement

  Write-Host "media Name $newMediaName"
  return $newMediaName
}

function GetSubRipName([string] $SFilePath) {
  $newName = GetMediaName $SFilePath 'TVShow'
  if (! [string]::IsNullOrEmpty($newName)) {
    return $newName
  }
  return GetMediaName $SFilePath 'Movie'
  <# debug
  $newName = GetMediaName($SFilePath, 'Movie')
  if (! [string]::IsNullOrEmpty($newName)) {
    return $newName
  }#>
}


function PerformOperationOnSingleFile ([int] $m_CompressLevel, [string] $SFilePath)
{
  if (!(SupportedExtension $SFilePath)) {
    Write-Host "Extension not supported; skipping $SFilePath"
    return -1
  }

  $InputExt = Get-ChildItem $SFilePath | % {$_.Extension}
  $InputFileBaseName = $SFilePath.Substring(0, $SFilePath.Length - $InputExt.Length)
  $OutputExt=".rar"
  $OutputFilePath=$InputFileBaseName + $OutputExt
  <#
  m = compression level
  v = volume size in bytes
  #>
  $SubtitleDisabled = $false
  $fileSize = (Get-Item $SFilePath).length
  if ($fileSize -le 128mb ) {
    $m_CompressLevel += 2
  }
  elseif ($fileSize -le 512mb ) {
    $m_CompressLevel++
  }
  Write-Host "Elevating level of compression to $m_CompressLevel."

  if ($SubtitleDisabled) {
    & $RAREXE a $OutputFilePath -prx -ep1 -ma5 -v1073741824b -m"$m_CompressLevel" $SFilePath
  }
  else {
    $SubRipExt=".srt"
    $SubFilePath=$InputFileBaseName + $SubRipExt
    if (! (Test-Path $SubFilePath -PathType Leaf)) {
      $SubFilePath=$InputFileBaseName + ".ass"
    }
    if (Test-Path $SubFilePath -PathType Leaf) {
      Write-Host "Adding subrip: $SubFilePath"
      & $RAREXE a $OutputFilePath -prx -ep1 -ma5 -v1073741824b -m"$m_CompressLevel" $SFilePath $SubFilePath
      if (! (Test-Path "$OutputFilePath" -PathType Leaf)) {
        $OutputFilePath=$InputFileBaseName + ".part1" + $OutputExt
      }
      # Send subrip file to recycle bin
      if (Test-Path "$OutputFilePath" -PathType Leaf) {
        $sh = new-object -comobject "Shell.Application"
        $ns = $sh.Namespace(0).ParseName("$SubFilePath")
        $ns.InvokeVerb("delete")
      }
    }
    else {
      # get sophisticated sub file name
      $SubFilePath = GetSubRipName($SFilePath)
      if (! [string]::IsNullOrEmpty($SubFilePath)) {
        Write-Host "Adding subrip: $SubFilePath"
        & $RAREXE a $OutputFilePath -prx -ep1 -ma5 -v1073741824b -m"$m_CompressLevel" $SFilePath $SubFilePath
        if (! (Test-Path "$OutputFilePath" -PathType Leaf)) {
          $OutputFilePath=$InputFileBaseName + ".part1" + $OutputExt
        }
        if (Test-Path "$OutputFilePath" -PathType Leaf) {
          $sh = new-object -comobject "Shell.Application"
          $ns = $sh.Namespace(0).ParseName("$SubFilePath")
          $ns.InvokeVerb("delete")
        }
      }
      else {
        & $RAREXE a $OutputFilePath -prx -ep1 -ma5 -v1073741824b -m"$m_CompressLevel" $SFilePath
      }
    }
  }

  # when there are multiple segments of archive file
  if (! (Test-Path "$OutputFilePath" -PathType Leaf)) {
    $OutputFilePath=$InputFileBaseName + ".part1" + $OutputExt
  }
  # Send to recycle bin if archive creation succeeded
  if (Test-Path "$OutputFilePath" -PathType Leaf) {
    $sh = new-object -comobject "Shell.Application"
    $ns = $sh.Namespace(0).ParseName("$SFilePath")
    $ns.InvokeVerb("delete")
  }
}

# Start of Main function
function Main() {
  if (VERIFY_PARAMETERS -le 0) {
    break
  }

  if ($global:IsSourceDirectory) {
    # Perform operation for each stream file, recursively
    foreach ($item in Get-ChildItem -Recurse $SourceDir)
    {
      if (! $item.PSIsContainer) {
        $fName = $item.FullName
        if (SupportedExtension($fName)) {
          PerformOperationOnSingleFile $global:CompressLevel "$fName"
        }
        else {
          Write-Host "Extension not supported; skipping $fName"
        }

      }
    }
  }
  else {
    PerformOperationOnSingleFile $global:CompressLevel "$StreamPath"
  }
}

Main
