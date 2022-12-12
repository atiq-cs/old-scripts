<#
.SYNOPSIS
  Convert lossless flac audio files to mpeg4 audio format
.DESCRIPTION
  Date: 12/31/2012
  Utilizes Windows Forms, Invokes from Powershell

.EXAMPLE
  Convert-flac-to-m4a.ps1 -s "F:\flacsource" -d "D:\ituneConvert"
  Convert-flac-to-m4a.ps1 -s "F:\alac" -d "D:\ituneConvert" -t alac
  Convert-flac-to-m4a.ps1 -s "F:\OST - VA - 2009 - (500) Days Of Summer" -d "D:\ituneConvert" -t alac

  Convert-flac-to-m4a.ps1 -s "F:\Lossless\flacsource" -d "D:\ituneConvert"
  Convert-flac-to-m4a.ps1 -s "F:\Lossless\The Corrs - The Best Of" -d "D:\ituneConvert"

  Special example (square bracket in path)
   Convert-flac-to-m4a.ps1 -s "F:\Lossless\Jennifer Lopez - Dance Again The Hits FLAC 2012" -d  "D:\ituneConvert\alac"

.NOTES
  Demonstrations,
  - alac conversion
  - alac to mp4a
  - and few tools cli i.e., iTunes, dBpoweramp


  **Square Bracket on File Names are Non Standard**
  Use stream converter to fix path that contains square bracket
  More on Square Bracket problem,
    N/A: Uses literal path to solve the square bracket problem. Square brackets are considered wildcards in powershell.
    Without backticks following commands make problems
      Test-Path
      Remove-Item
      gci

      New-Item works fine

    Another solution is to use -literalPath switch with sensitive commands.
#>

Param(
    [Parameter(Mandatory=$true)]
    [alias("s")]
    [string]$SourceDirectory,
    [Parameter(Mandatory=$true)]
    [alias("d")]
    [string]$DestinationDirectory,
    [alias("t")]
    [string]$SourceType)


$ConverterALACExec="C:\Program Files (x86)\Illustrate\dBpoweramp\CoreConverter.exe"
# acquired from http://www.shchuka.com/software/itunescoder/index.html#download
# $ConverterM4AACExec="D:\Stream Converters\dbPowerAmp\iTunesEncode46\iTunesEncode.exe"
$ConverterM4AACExec="D:\Stream Converters\itunescoder2009\iTunesEncode.exe"
$Ext=".flac"

# reference 1: http://www.dbpoweramp.com/help/Codec/Flac/help.htm
# http://www.dbpoweramp.com/developer-cli-encoder.htm
# ref 2: http://forum.dbpoweramp.com/showthread.php?16599-CoreConverter-CLI-prepends-track-filename-to-strings-in-ID-Tag-Processing-exportart
# & "C:\Program Files (x86)\Illustrate\dBpoweramp\CoreConverter.exe" "-infile=`"F:\Lossless\Owl City - Ocean Eyes [FLAC]\09 Owl City - Fireflies.flac`"" "-outfile=`"G:\Streams\temp\Take\alac\out.m4a`"" "-convert_to=`"Apple Lossless"`"
# & "D:\audio conversion\iTunesEncode46\iTunesEncode.exe" -i "F:\Streams\temp\Take\alac\09 Owl City - Fireflies.m4a" -o "G:\Streams\temp\Take\alac\outItunes.m4a" -d

if (! (Test-Path -path $ConverterALACExec)) {
    Write-Host "Please install dBpoweramp and then run the script again.`n"
    break
}

if (! (Test-Path -path "C:\Program Files (x86)\iTunes\iTunes.exe")) {
    Write-Host "Please install itunes and then run the script again.`n"
    break
}

if (! (Test-Path -path $ConverterM4AACExec)) {
    Write-Host "Please check for tool iTunesEncode.exe and then run the script again.`n"
    break
}

if ((Test-Path -path $DestinationDirectory -pathtype leaf) -or !(Test-Path $DestinationDirectory)) {
    Write-Host "Please provide proper directory name of destination.`n"
    break
}

if ((Test-Path -path $SourceDirectory -pathtype leaf) -or !(Test-Path $SourceDirectory)) {
    Write-Host "Please provide proper directory name of source.`n"
    if (! (Test-Path $SourceDirectory)) {
        Write-Host "does not exist.`n"
    }
    break
}

foreach ($item in Get-ChildItem -Recurse $SourceDirectory) {
    $ItemName = $item.FullName
    $PathTail = $ItemName.Replace($SourceDirectory, "")
    #Write-Host "Trim str" $SourceDirectory
    #Write-Host "Trail str" $PathTail
    #Write-Host "Creating directory" $PathTail.Substring(1)
    # get file path for destination
    $newtargetitemname = $DestinationDirectory+$PathTail

    if (! $item.Exists) {
        Write-Host "Object doesn't exist anymore! Probably moved!"
    }
    elseif ($item.PSIsContainer) {
        #if (! (Test-Path "$newtargetitemnamedirty")) {
        if (! (Test-Path "$newtargetitemname")) {
            New-Item -type directory "$newtargetitemname"
        }
        else {
            Write-Host "Directory" $newtargetitemname "already exists!!"
        }
    }
    else {
        if ($SourceType.Equals("alac")) {
            # Added for new system
            $Ext=".alac.m4a"
             if ($ItemName.EndsWith($Ext)) {
                $alacitemname = $ItemName
                $m4aacitemname = $newtargetitemname.Replace($Ext, ".m4a")

                & $ConverterM4AACExec -i "$alacitemname" -o "$m4aacitemname" -d
                if (Test-Path $m4aacitemname) {
                    Remove-Item $alacitemname
                    if (Test-Path $alacitemname) {
                        Write-Host "File could not be deleted"
                        break
                    }
                }
            }
            # avoid garbage files
            elseif ($ItemName.EndsWith(".cue") -Or $ItemName.EndsWith(".log") -Or $ItemName.EndsWith(".m3u") -Or $ItemName.EndsWith(".m3u8") -Or $ItemName.EndsWith(".nfo") -Or $ItemName.EndsWith(".pls") -Or $ItemName.EndsWith(".dat") -Or $ItemName.EndsWith(".sfv") -Or $ItemName.EndsWith(".html") -Or $ItemName.EndsWith(".htm") -Or $ItemName.EndsWith(".url") -Or $ItemName.EndsWith("BitComet 0.85 or above____")) {
                Write-Host "Ignoring" $PathTail.Substring(1)
            }
            else {
                # Copy the file simply
                Write-Host "Copying" $PathTail.Substring(1)
                Copy-Item -literalPath $ItemName $newtargetitemname
            }
        }
        else {
            # prcoess flac files, create apple loseless with dbpoweramp
            if ($ItemName.EndsWith("$Ext")) {
                $alacitemname = $newtargetitemname.Replace($Ext, ".alac.m4a")
                $m4aacitemname = $newtargetitemname.Replace($Ext, ".m4a")

                if (Test-Path $alacitemname) {
                    Write-Host "Apple loseless for" $PathTail.Substring(1) "already exists"
                }
                elseif (Test-Path $m4aacitemname) {
                    Write-Host "aac m4a for" $PathTail.Substring(1) "already exists"
                }
                else {
                    $FlacFilePath=$item.FullName
                    & $ConverterALACExec "-infile=`"$FlacFilePath`"" "-outfile=`"$alacitemname`"" "-convert_to=`"Apple Lossless`""
                }

                if (Test-Path $m4aacitemname) {
                    if (Test-Path $alacitemname) {
                        Write-Host "aac m4a for" $PathTail.Substring(1) "already exists"
                        Remove-Item $alacitemname
                    }
                }
                else {
                    if (Test-Path $alacitemname) {
                        & $ConverterM4AACExec -i "$alacitemname" -o "$m4aacitemname" -d
                        # if conversion fails don't delete
                        if (Test-Path $m4aacitemname) {
                            Remove-Item $alacitemname
                            if (Test-Path $alacitemname) {
                                Write-Host "File could not be deleted"
                                break
                            }
                        }
                    }
                    else {
                        Write-Host "alac file is not generated. Check if alac conversion failed!"
                        break
                    }
                }
            }
            # avoid garbage files
            elseif ($ItemName.EndsWith(".cue") -Or $ItemName.EndsWith(".log") -Or $ItemName.EndsWith(".m3u") -Or $ItemName.EndsWith(".m3u8") -Or $ItemName.EndsWith(".nfo") -Or $ItemName.EndsWith(".pls") -Or $ItemName.EndsWith(".dat") -Or $ItemName.EndsWith(".sfv") -Or $ItemName.EndsWith(".html") -Or $ItemName.EndsWith(".htm") -Or $ItemName.EndsWith(".url") -Or $ItemName.EndsWith("BitComet 0.85 or above____")) {
                Write-Host "Ignoring" $PathTail.Substring(1)
            }
            else {
                # Copy the file simply
                Write-Host "Copying" $PathTail.Substring(1)
                Copy-Item -literalPath $ItemName $newtargetitemname
            }
        }
    }
}

Write-Host "`nConversion Complete."

# close itunes
Write-Host "Closing itunes"
Stop-Process -Name iTunes

# Now delete unnecessary folders
# HOMEDRIVE   C:
# HOMEPATH    \Users\USER_NAME
$iTunesDir=$env:HOMEDRIVE+$env:HOMEPATH+"\Music\iTunes\iTunes Media\Music"
Write-Host "Removing directories created by itunes."
#Remove-Item $iTunesDir -recurse -force

$items = Get-ChildItem -Recurse $iTunesDir
foreach($item in $items)
{
      if( $item.PSIsContainer )
      {
            $subitems = Get-ChildItem -Recurse -Path $item.FullName
            if($subitems -eq $null)
            {
                  Remove-Item $item.FullName
            }
            $subitems = $null
      }
}
