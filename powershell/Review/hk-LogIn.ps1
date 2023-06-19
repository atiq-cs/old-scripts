# Date: 03-10-2011
# Author: Atiq

function DownloadHttpFilebyPostData([string]$url, [string]$parameters) {
  $http_request = New-Object -ComObject Msxml2.XMLHTTP
  $res = $http_request.open('POST', $url, $false)
  if ($res -eq 0) {
    Write-Host -nonewline "`nOpening connection to server: "
    Write-Host -foregroundcolor red "`t`t[Failed]"
    return $null
  }

  $http_request.setRequestHeader("Content-type", 
    "application/x-www-form-urlencoded")
  $http_request.setRequestHeader("Content-length", $parameters.length)
  $http_request.setRequestHeader("Connection", "close")
  try {
    $http_request.send($parameters)
  }
  catch {
    Write-Host -NoNewline -foregroundcolor red "`n[Exception] "
    Write-Host -NoNewline "hajirakhata app is hang!"
  }
  return $http_request
}

function GetMiddleString([string]$page, [string]$head, [string]$tail) {
  if ($head.Equals("")) {
    $res = $page
  }
  else {
    $res = [string] (select-string -inputobject $page -pattern $head)
    if ($res.Equals("")) {
      Write-Host "Pattern: `"$head`" is not found in page.`n"
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
  #$res = $res.Replace("`t", "")
  $res = $res.Replace("`t", "")
  $res = $res.Replace("`n", "")
  #$res = $res.Trim(" ")
  return $res
}


function Main([string] $userName, [string] $passWord) {
  $login_url = "CORP_URL_FOR_LOGIN"

  Write-Host -nonewline "Hajirakhata Login:"
  $postString = "username=" + $userName + "&password=" + $passWord
  $http_request = DownloadHttpFilebyPostData $login_url $postString

  if ($http_request -eq $null -or $http_request.statusText -eq $null) {
    Write-Host -foregroundcolor red "`t`t[Failed]"
  }
  elseif ($http_request.statusText.Equals("OK")) {
    $outputFile = $http_request.responseText
    $outputFile | out-file ".\temp.html"
    # Login Okay for regualy employ
    if ($outputFile | select-string "Employee Task") {
      $serverTimeStr = [string] ($outputFile | Select-String -pattern "Server Time:&nbsp;</b>.* BDT")
      if ($serverTimeStr.Equals("")) {
        Write-Host -nonewline " server time not found!"
      }
      else {
        $lastPos = $serverTimeStr.LastIndexOf(" BDT")
        $startPos = $serverTimeStr.IndexOf("Server Time:&nbsp;</b>")+22
        $offset = $lastPos - $startPos
        $serverTime = $serverTimeStr.SubString($startpos, $offset)
        Write-Host -nonewline " $serverTime"
      }

      Write-Host -foregroundcolor green "`t`t[OK]"
      if ($outputFile | select-string "Leave Type</td>") {
        # get rid of new lines
        $resWithoutNL = [string]::Join("`n", $outputFile)
        # $LeaveType = ParseLeaveType $resWithoutNL
        $LeaveType = GetMiddleString $resWithoutNL "<td class=`"td_viewdata1`"  align=`"center`" width=`"80`" >" "&nbsp;"
        if ($LeaveType.Equals("")) {
          Write-Host "Error pasrsing leave data: error 1"
          break
        }
        else {
          $LeaveType = $LeaveType.TrimStart()
          # Write-Host "type: `"$LeaveType`""
        }
        $DelegateName = GetMiddleString $resWithoutNL "<td class=`"td_viewdata2 `" align=`"center`" width=`"90`" >" "&nbsp;"
        if ($DelegateName.Equals("")) {
          Write-Host "Error pasrsing leave data: error 2"
          break
        }
        <# else {
          # $DelegateName = $DelegateName.TrimStart()
          # Write-Host "DelegateName: `"$DelegateName`""
        } #>
        Write-Host "$LeaveType leave waiting to be approved by $DelegateName"
      }
    }
    
    # Login okay for supervisor employee
    elseif ($outputFile | select-string "Manage Employee") {
      $serverTimeStr = [string] ($outputFile | Select-String -pattern "Server Time:&nbsp;</b>.* BDT")
      if ($serverTimeStr.Equals("")) {
        Write-Host -nonewline " server time not found!"
      }
      else {
        $lastPos = $serverTimeStr.LastIndexOf(" BDT")
        $startPos = $serverTimeStr.IndexOf("Server Time:&nbsp;</b>")+22
        $offset = $lastPos - $startPos
        $serverTime = $serverTimeStr.SubString($startpos, $offset)
        Write-Host -nonewline " $serverTime *"
      }
      Write-Host -foregroundcolor green "`t`t[OK]"
    }

    # Login failed because of wrong username and password
    elseif ($outputFile | select-string "Invalid Username or Password") {
      Write-Host -foregroundcolor red "`t`t[Failed]"
      Write-Host "Reason: user name or password is wrong"
    }
    
    # Login failed
    else {
      $outputFile | out-file ".\temp.html"

      #Write-Host -foregroundcolor red "`nFetching logged probe`t`t[Failed]"
      Write-Host -nonewline "`nFetching logged probe"
      Write-Host -foregroundcolor red "`t`t[Failed]"
      Write-Host "`nEnabling manual login"
      Start Chrome $url
    }
  }
  else {
    Write-Host -foregroundcolor red "`nSending post data`t`t[Failed]"
  }
}

# Brute Force Password Generation, from 'hk-comb.ps1'
function GeneratePass([string]$initP, [int]$length) {
  # initial string generation
  if ($initP.Equals("")) {
    for ($i=1;$i -le $length; $i++) {
      $initP += "A"
    }
  }

  # next string generation
  # TODO
  
  return $initP
}

if ($args.count -eq 0) {
  Main $USER_NAME $PASSWD

  # or use Password Generation
  # $passLength = 3
  # $initPass = ""
  # $nextPass= GeneratePass $initPass $passLength
  # Write-Host "cur: $nextPass, pre: $initPass"
}
elseif($args.count -eq 2) {
  $cmd1 = $args[0]
  $cmd2 = $args[1]
  Main $cmd1 $cmd2
}
elseif($args.count -ne 2) {
  Write-Host "Please check command line arguments. You provided:`n $args"
}

Write-Host ""

<# stackoverflow example 03-10-2011
try {
  $w = New-Object net.WebClient
  $d = $w.downloadString('http://foo')
}
catch [Net.WebException] {
  Write-Host $_.Exception.ToString()
}#>


# from wget example, before completing this script
# Date: 06-14-2011
function LoginUsingWGet() {
  $gnuwin32binpath="C:\ProgData\GnuWin32\bin"
  $WGET_BIN=$gnuwin32binpath+"\wget.exe"

  pushd
  cd $env:scriptdir\temp

  echo "Logging into hajirakhata"


  rm hajira1.html
  # tests using wget
  # $url = $CORP_URL_MAIN (check doc)
  #& $WGET_BIN -q $url -O hajira1.html
  # append session id
  # $url = '"$login_url;jsessionid=B667771BC6E0ACA8D2760B143AE31099"'
  # $cred_string = "username=USER_NAME`&password=PASSWORD"
  #& $WGET_BIN -q --save-cookies=cookie1 --post-data=$cred_string $url -O hajira1.html
  # $cred_string = "username=USER_NAME&password=PASSWORD"
  & $WGET_BIN -q --save-cookies=cookie1 --post-data=$cred_string $login_url -O hajira1.html

  if (cat .\hajira1.html | select-string "Employee Task") {
      echo "Logging in successful!"
  }
  else {
      echo "Login failed! Enabling manual login"
      Start Chrome $url
  }
  echo ""

  Pop-Location
}
