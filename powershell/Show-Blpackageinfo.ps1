<#
.SYNOPSIS
  Show BanglaLion Internet Quota Info

.DESCRIPTION
  Updated 2011 to 2014

.EXAMPLE

.NOTES
  published in,
   https://atiqcs.wordpress.com/2011/12/11/banglalion-connection-info-powershell-script

  Demonstrations,
  - Select BL user account if MAC matches
  - string parsing of html string output
#>


[CmdletBinding()]
param(
  [ValidateSet('NAME_1', 'NAME_2')]
    [string] $userName
)

# Uses xml http to post data
function DownloadHttpFilebyPostData([string] $url, [string] $parameters) {
  $http_request = New-Object -ComObject Msxml2.XMLHTTP
  # $name = $http_request.GetType().FullName
  $http_request.open('POST', $url, $false)
  $http_request.setRequestHeader("Content-type", 
    "application/x-www-form-urlencoded")
  $http_request.setRequestHeader("Content-length", $parameters.length)
  $http_request.setRequestHeader("Connection", "close")

  try {
    $http_request.send($parameters)
  }
  catch {
    $expStatus = $http_request.statusText
    Write-Host -nonewline " on $expStatus"
    $http_request = $null
    # if ($http_request.statusText.Equals("OK")) {
    #Write-Host -nonewline " on exception"
  }

  return $http_request
}

function ShowBanglaLionInfo([string] $userName, [string] $passWord, [bool] $isPrepaidPackage) {
  $outputFilePath=${Env:ScriptsHome}+"\temp.html"

  if (Test-Path $outputFilePath) { rm $outputFilePath }
  Write-Host "Retrieving connection info"
  write-Host -nonewline "Sending post data"
  
  $postString = "login=" + $userName + "&pass=" + $passWord
  
  $http_request = DownloadHttpFilebyPostData "http://care.banglalionwimax.com/radauth.php" $postString

  if ($http_request -eq $null) {
    Write-Host "http_request is null"
    break
  }
  elseif ($http_request.statusText -eq $null) {
    Write-Host "http_request status text is null"
  }
  elseif ($http_request.statusText.Equals("OK")) {
    $http_request.responseText | Out-File $outputFilePath

    if (select-string $outputFilePath -pattern "Your session get expired") {
      Write-Host -foregroundcolor red "`t`t[Failed]"
      Write-Host "Reason: session expired"
      # exit instead of break is better
      # break stops execution of all the scripts including parents
      # exit only stops the current script
      exit
    }
    elseif (select-string $outputFilePath -pattern "Invalid Password.         </b>") {
      Write-Host -foregroundcolor red "`t`t[Failed]"
      Write-Host "Response: invalid password!"
      exit
    }
    else {
      Write-Host -foregroundcolor green "`t`t[OK]"
    }
  }
  else {
    Write-Host -foregroundcolor red "`t`t[Failed]"
    break
  }

  #cat bl.html  "\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,6}"
  # "[<TD><B>]\d{1,4}\.d{1,3}[ Mb</B></TD>]"
  $len = 0
  $res = [string] (select-string $outputFilePath -pattern "<TD><B>.* Mb</B></TD>")
  $len = $res.LastIndexOf(" MB")+3
  $startpos = $res.IndexOf("<")+7
  #Write-Host "start: $startpos len: $len"
  $offset = $len - $startpos
  if ($offset -lt 0) {
    Write-Host "Error in data!"
    Write-Host "res var is: $res"
    break
  }
  #$res = $res.SubString($startpos, $len) + " MegaBytes"
  $RemainingVolume = $res.SubString($startpos, $offset)
  # in pattern we need backslash in `IndexOf` we don't need
  $res = [string] (select-string $outputFilePath -pattern "DateCompare\(`'.*`'")

  if ($isPrepaidPackage) {
    $len = $res.LastIndexOf("`',")
  }
  else {
    $len = $res.LastIndexOf("`')`">")
  }
  
  if ($len -lt 0) {
    Write-Host $res
    exit
  }
  if ($isPrepaidPackage) {
    $startpos = $res.IndexOf("DateCompare(`'")+13
    $offset = $len - $startpos
  }
  else {
    $startpos = $res.IndexOf("DateCompare(`'`'")+16
  }


  # Update June 30, 2014 due to upstream
  # Date string got a change: result 3 character extra for both prepaid and postpaid
  $offset = $len - $startpos - 3
  
  #$res = $res.SubString($startpos, $len) + " MegaBytes"
  $ExpirationDate = $res.SubString($startpos, $offset)
  #$ExpString = $ExpirationDate + " 0:0:0 AM"
  $DateStr = $ExpirationDate.Split("/ ")
  # $DateStr[0]
  $DateExp = new-object System.DateTime($DateStr[2], $DateStr[1], $DateStr[0], 23, 59, 59)
  $DateCurrent = [System.DateTime]::Now
  $diff = new-object System.TimeSpan
  $diff = $DateExp.Subtract($DateCurrent)
  $ExpDay = $diff.Days

  if ($res) {
    Write-Host "Remaining volume: $RemainingVolume"
    Write-Host "Expiry Date: $DateExp"
    if ($ExpDay -eq 0) {
      Write-Host -foregroundcolor red "Recharge within today to avoid losing volume!"
    }
    elseif ($ExpDay -lt 0) {
      Write-Host -foregroundcolor red "Connection validity already expired!"
    }
    # for singular number
    elseif ($ExpDay -eq 1) {
      Write-Host -foregroundcolor red "Recharge within" $ExpDay "day to avoid losing volume!"
    }
    elseif ($ExpDay -lt 3) {
      Write-Host -foregroundcolor red "Recharge within" $ExpDay "days to avoid losing volume!"
    }
    else {
      Write-Host -nonewline "Remaining days: "
      Write-Host -foregroundcolor green $ExpDay
    }
  }
  else {
    Write-Host "Didn't find the pattern may be login failed!"
  }
}

if (Test-Connection -Cn care.banglalionwimax.com -BufferSize 16 -Count 1 -ea 0 -quiet) {
  # Connect Per Person
  if ($userName) {
    switch ($userName) {
    "NAME_1" {
      ShowBanglaLionInfo "USER_NAME_1" "USER_PASS_1" $true
    }
    "NAME_2" {
      ShowBanglaLionInfo "USER_NAME_2" "USER_PASS_2" $false
    }
    Default {
      'Unknown user name ' + $userName + '!'
    }
    }
  }
  # Connect Per Mac Address; convenient when MAC is known
  else {
    $MAC1 = "C6-64-C7-BA-C0-E6"
    $MAC2 = "98-F5-37-A1-EC-FD"

    # cmdlet version for legacy: `getmac`
    $deviceMac = (Get-NetAdapter -Physical).MacAddress

    switch ($deviceMac) {
    $MAC1 {
      ShowBanglaLionInfo "USER_NAME_1" "USER_PASS_1" $true
    }
    $MAC2 {
      ShowBanglaLionInfo "USER_NAME_2" "USER_PASS_2" $false
    }
    Default {
      'Unknown mac address: ' + $deviceMac + '!'
    }
  }
}
else {
  Write-Host "Banglalion care is down. Please check later."
}
