<# Date: 06/27/2011 22:18:07
   valid usage example:
        $ .\Remove-mp3-tag-ad.ps1 -d "I:\Audio\Western\Dido - Life For Rent 2003" -t "[Dreamsounds.net]" -e mp3
        $ .\Remove-mp3-tag-ad.ps1 -d "I:\Audio\Bangla\Unrecognized\James" -t " (music.com.bd)" -e mp3
 #>

Param(
    [Parameter(Mandatory=$true)]
    [alias("d")]
    [string]$MediaDirectory,
    [Parameter(Mandatory=$true)]
    [alias("t")]
    [string]$AdText,
    [alias("e")]
    [string]$Ext)

if ((Test-Path -path $MediaDirectory -pathtype leaf) -or !(Test-Path $MediaDirectory)) {
    Write-Host "Please provide proper directory name.`n"
    break
}

if ($Ext.Length -eq 0) {
    Write-Host "Defaulting extension to mp3"
    $Ext="mp3"
}

gci -Recurse $MediaDirectory\*.$Ext | %{
    $FileNameOnly = [string]$_.BaseName
    Write-Host "Processing" $FileNameOnly

    $OldFileName = $_.fullName
    $OldFileName = $OldFileName.Replace('[', '``[')
    $OldFileName = $OldFileName.Replace(']', '``]')

    $FileNameOnly = $FileNameOnly.Replace($AdText, "")
    $FileNameOnly = $FileNameOnly.Replace('[', '``[')
    $FileNameOnly = $FileNameOnly.Replace(']', '``]')

    #$NewFileName = $MediaDirectory+"\"+$FileNameOnly+"."+$Ext
    $NewFileName = $FileNameOnly+"."+$Ext


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
