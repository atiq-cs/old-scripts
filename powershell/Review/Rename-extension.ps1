<# Date: 06/27/2011 22:18:07
   Author: Atiq
   valid usage example:
        $ .\Rename-extension.ps1 -d "G:\ituneConvert\OST - VA - 2009 - (500) Days Of Summer (Music From The Motion Picture)" -p "m4a" -n "alac.m4a"
        $ .\Remove-mp3-tag-ad.ps1 -d "I:\Audio\Bangla\Unrecognized\James" -t " (music.com.bd)" -e mp3
 #>

Param(
    [Parameter(Mandatory=$true)]
    [alias("d")]
    [string]$MediaDirectory,
    [Parameter(Mandatory=$true)]
    [alias("p")]
    [string]$ExtPre,
    [Parameter(Mandatory=$true)]
    [alias("n")]
    [string]$ExtNow)

if ((Test-Path -path $MediaDirectory -pathtype leaf) -or !(Test-Path $MediaDirectory)) {
    Write-Host "Please provide proper directory name.`n"
    break
}

gci -Recurse $MediaDirectory\*.$ExtPre | %{
    $FileNameOnly = [string]$_.BaseName
    Write-Host "Processing" $FileNameOnly

    $OldFileName = $_.fullName

    # correct name
    $OldFileName = $OldFileName.Replace('[', '``[')
    $OldFileName = $OldFileName.Replace(']', '``]')

    $FileNameOnly = $FileNameOnly.Replace('[', '``[')
    $FileNameOnly = $FileNameOnly.Replace(']', '``]')

    #$NewFileName = $MediaDirectory+"\"+$FileNameOnly+"."+$Ext
    $NewFileName = $FileNameOnly+"."+$ExtNow


    if (Test-Path $NewFileName) {
        Write-Host "File name for" $NewFileName "already exists. Cannot process" $OldFileName
    }
    else {
        #Write-Host $OldFileName "will be" $NewFileName
        if (Test-Path $OldFileName) {
            Rename-Item $OldFileName $NewFileName
        }
        else {
            Write-Host "Path string related problem again. Consider characters like square brackets for" $OldFileName
        }
    }
}

Write-Host " "
