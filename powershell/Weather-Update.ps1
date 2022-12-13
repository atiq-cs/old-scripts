<#
.SYNOPSIS
  Basic weather information retrieval from CLI
.DESCRIPTION
  Date: 01/12/2012, updated 2014
  needs fix


.EXAMPLE
  Update-Software.ps1 -component ffmpeg

  At present, parsing needs to be updated for changes upstream,
  ```
  Retreving info from weather channel: 992 KB
  Pattern: "<h1>" is not found in page.
  Pattern: "<div class="wx-phrase ">" is not found in page.
  Pattern: "<div class="wx-temperature"><span itemprop="temperature-fahrenheit">" is not found in page.
  Pattern: "<span itemprop="feels-like-temperature-fahrenheit">" is not found in page.
  Pattern: "<span class="wx-temp" itemprop="humidity">" is not found in page.
  Pattern: "<span class="wx-temp" itemprop="dewpoint">" is not found in page.

  Pattern: "<h6 class="wx-label">Tonight:</h6>
  <p class="wx-text">" is not found in page.
  : , °F (-17.78°C) feels like °F (-17.78°C); Humidity: ; Dew point: °, Today
  ```

.NOTES
  Demonstrates
  - download html string from URL
  - string parsing

  tags: windows-only
#>


# provided by http://blogs.msdn.com/b/jasonn/archive/2008/06/13/downloading-files-from-the-internet-in-powershell-with-progress.aspx
function downloadFile($url, $targetFile, [int] $nBytes)
{
    #"Downloading $url"
    Write-Host -NoNewline "Retreving info from weather channel"
    
    $uri = New-Object "System.Uri" "$url" 
    $request = [System.Net.HttpWebRequest]::Create($uri) 
    $request.set_Timeout(15000) #15 second timeout 
    $response = $request.GetResponse() 
    if ($nBytes -gt 0) {
        $nBytes = $nBytes * 1024
        $totalLength = $nBytes
    }
    else {
        $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024) 
    }
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024) 
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create 
    $buffer = new-object byte[] 10KB 
    $count = $responseStream.Read($buffer,0,$buffer.length) 
    $downloadedBytes = $count 
    while (($count -gt 0) -and (($nBytes -eq 0) -or ( $downloadedBytes -ge $nBytes) ) )
    { 
        [System.Console]::CursorLeft = 0
        [System.Console]::Write("Retreving info from weather channel: {0} KB", [System.Math]::Floor($downloadedBytes/1024)) 
        
        $targetStream.Write($buffer, 0, $count)
        $count = $responseStream.Read($buffer,0,$buffer.length)
        $downloadedBytes = $downloadedBytes + $count 
    } 
    #"`nFinished Download"
    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose() 
    $responseStream.Dispose()
}

function GetMiddleString([string]$page, [string]$head, [string]$tail) {
    if ($head.Equals("")) {
        $res = $page
    }
    else {
        $res = [string] (select-string -inputobject $page -pattern $head)
        if ($res -eq $null -or $res.Equals("")) {
            Write-Host "`nPattern: `"$head`" is not found in page.`n"
            return $res
        }
    }
    $len = $head.Length
    $startpos = $res.IndexOf($head)+$len
    $len = $res.Length
    if ($len -lt $startpos) {
        Write-Host "not found"
        return ""
    }
    $res = $res.SubString($startpos)
    $len = $res.IndexOf($tail)
    
    if ($len -lt 0) {
        Write-Host "Less than zero!!!"
        return ""
    }
    $res = $res.SubString(0, $len)
    # necessary for weather page

    # remove tabs and newlines    
    #$res = $res.TrimStart()
    #$res = $res.TrimEnd()
    $res = $res.Replace("`t", "")
    $res = $res.Replace("`n", "")
    return $res
}

function CovertFToC([int]$F) {
    $C = ($F - 32) * 5 / 9
    $C = $C.ToString(".00")
    return $C
}

# Keep the downloaded file for examining
#$DEBUG = $true
$DEBUG = $false

# Create Client Instance
$clnt = new-object System.Net.WebClient

# For Bangladesh
# $url = "http://www.weather.com/weather/today/23.709921,90.407143"
# $url = "http://www.weather.com/weather/today/BGXX0003"
# For Stony brook, NY
$url = "http://www.weather.com/weather/today/11790"
$netFile = "$(get-location)\temp.html"

if ($DEBUG -eq $false -and (Test-Path $netFile)) { rm $netFile }

try {
    if (Test-Path $netFile) {
      Get-Content $netFile
    }
    else
    {
        #$clnt.DownloadFile($url,$netFile)
        downloadFile $url $netFile 0
    }
    
    $len = 0
    $res = Get-Content $netFile
    $resWithoutNL = [string]::Join("`n", $res)
    $rainProb = "N/A"
    
    $placeText = GetMiddleString $resWithoutNL "<h1>" "</h1>"
    
    $Condition = GetMiddleString $resWithoutNL "<div class=`"wx-phrase `">" "</div>"
    $TemperatureStr = GetMiddleString $resWithoutNL "<div class=`"wx-temperature`"><span itemprop=`"temperature-fahrenheit`">" "</span>"
    $feelTempStr = GetMiddleString $resWithoutNL "<span itemprop=`"feels-like-temperature-fahrenheit`">" "</span>"
    $humidity = GetMiddleString $resWithoutNL "<span class=`"wx-temp`" itemprop=`"humidity`">" "</span>"
    $dewP = GetMiddleString $resWithoutNL "<span class=`"wx-temp`" itemprop=`"dewpoint`">" "&deg;</span>"
    # Fix for new change in site
    $narrateText = GetMiddleString $resWithoutNL "<h6 class=`"wx-label`">Tonight:</h6>`n<p class=`"wx-text`">" "</p>"
    
    $Temperature = CovertFToC($TemperatureStr)
    $feelTemp = CovertFToC($feelTempStr)
    Write-Host "`r$placeText`: $Condition, $TemperatureStr°F ($Temperature°C) feels like $feelTempStr°F ($feelTemp°C); Humidity: $humidity; Dew point: $dewP°, Today $narrateText"
}
catch [Net.WebException] {
    Write-Host
    $excText = [string]$_.Exception

    if ($excText.Contains("resolved")) {
        Write-Host "Could not connect to weather server!"
    }
    else {
        Write-Host "[debug] $excText"
    }
}

Write-Host
