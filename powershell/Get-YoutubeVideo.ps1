<#
.SYNOPSIS
  Download youtube video
.DESCRIPTION
  Date: 04/27/2014
  Utlize /get_video endpoint to download video

.EXAMPLE
  List-Process

.NOTES
  YT's '/get_video' seems deprecated
  For Linux, replace the regex match and downloader cmd i.e., `wget`

tag: windows-only
#>

# ** TODO: replace bitstransfer with Invoke-WebRequest
Import-Module bitstransfer 
$ErrorActionPreference = "SilentlyContinue"
# TODO: replace with Param
$v=$args[0]

#$v="irp8CNj9qBI" 
#Grab Youtube Page 
$s=(New-Object System.Net.WebClient).DownloadString("http://www.youtube.com/watch?v=" + $v) 
$s | Out-File yt_Log.txt
#extract token 
$t=$s | % {$_.substring($_.IndexOf("`"t`": `"")+6,44)} 

#extract title 
$r="<title>(.*?) - YouTube</title>" ; $f = $s | ?{ $_ -match $r } |  %{ $_ -match $r | out-null ; $matches[1] } 

#Try downloading 720p version of video 
$u = "http://www.youtube.com/get_video?fmt=22&video_id=" + $v + "&t=" + $t 
$o = "G:\Videos\" + $f + "_HQ.mp4" 
Start-BitsTransfer –source $u -destination $o 

#Try downloading regular mp4 version of video, if HQ version failed 
if (!$?) { 
    $u = "http://www.youtube.com/get_video?fmt=18&video_id=" + $v + "&t=" + $t 
    $o = $Env:Userprofile + "\Videos\" + $f + ".mp4" 
    Start-BitsTransfer –source $u -destination $o 
}
