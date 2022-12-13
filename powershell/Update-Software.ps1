<#
.SYNOPSIS
  Update example software ffmpeg
.DESCRIPTION
  Date: 10/18/2014
  1. Check current ffmpeg version installed
  2. Check current ffmpeg version released
  3. Compare and udpate based on the version


.EXAMPLE
  Update-Software.ps1 -component ffmpeg

.NOTES
  It's not complete, this was just a starter.
  However, it contains example zeranoe build URLs for ffmpeg for 2014.

  Demonstrates
  - System.Net.WebClient::DownloadFile
  - Exception handling for `DownloadFile`
  -  ref, https://gist.github.com/TravisEz13/9bb811c63b88501f3beec803040a9996
#>

Param(
    [Parameter(Mandatory=$true)] [alias("component")]
      [string] $comp_name
)



if ($comp_name -eq "ffmpeg") {
    $ffmpeg_url = "http://ffmpeg.zeranoe.com/builds/win64/shared/ffmpeg-20141017-git-bbd8c85-win64-shared.7z"
    $destination = "F:\Windows Project\zeranoe\ffmpeg-20141017-git-bbd8c85-win64-shared.7z"
    $client = new-object System.Net.WebClient

    try {
      $client.DownloadFile($ffmpeg_url,$destination)
    }
    catch [Net.WebException] {
        Write-Host "An exception occurred. Details`: "
        Write-Host $_.Exception.ToString()
    }
} else {
    Write-Host "Invalid command line."
}