<#
    Source: cannot find
    Last modified: 2014-03
    Deprecated by VS Code Diff Tool and Win Diff

    ref, https://devblogs.microsoft.com/scripting/use-powershell-to-compare-two-files/
#>

Function Compare-TextFile {
  param ($file1, $file2, [switch]$window)

  $refObj = Get-Content $file1
  $tarObj = Get-content $file2

  $lengths = New-Object 'object[,]' ($refObj.Length + 1), ($tarObj.Length + 1)

  for($i = 0; $i -lt $refObj.length; $i++) {
    for ($j = 0; $j -lt $tarObj.length; $j++) {
      if ($refObj[$i] -ceq $tarObj[$j]) {
        $lengths[($i+1),($j+1)] = $lengths[$i,$j] + 1
      } else {
        $lengths[($i+1),($j+1)] = [math]::max(($lengths[($i+1),$j]),($lengths[$i,($j+1)]))
      }
    }
  }

  $lcsobj = @()
  $x = $refObj.length
  $y = $tarObj.length
  while (($x -ne 0) -and ($y -ne 0)) {
    if ( $lengths[$x,$y] -eq $lengths[($x-1),$y]) {--$x}
    elseif ($lengths[$x,$y] -eq $lengths[$x,($y-1)]) {--$y}
    else {
      if ($refObj[($x-1)] -ceq $tarObj[($y-1)]) {    
        $lcsobj = ,($refObj[($x-1)],($x-1),($y-1)) + $lcsobj
      }
      --$x
      --$y
    }
  }

  $linefmt = "000"
  $refPos = 0
  $tarPos = 0
  $lcsPos = 0

  if ($window) {
    $refPos = 0
    $tarPos = 0
    $lcsPos = 0
    $results = @()

    while ($lcsPos -lt ($lcsObj.length)) {
      $a = @()
      while ($refPos -le $lcsObj[$lcsPos][1] ) {
        if ($refPos -ne $lcsObj[$lcsPos][1]) {
          $a += ,($refObj[$refPos], $refPos)
        }
        $refPos++
      }

      $b = @()
      while ($tarPos -le $lcsObj[$lcsPos][2] ) {
        if ($tarPos -ne $lcsObj[$lcsPos][2]) {
          $b += ,($tarObj[$tarPos], $tarPos)
        }
        $tarPos++
      }

      $tokenlen = [math]::max($a.length, $b.length)
      if ($tokenlen -gt 0) {
        $code = "Changed"
        if ($a.length -eq 0) {$code = "Added"}
        if ($b.length -eq 0) {$code = "Deleted"}
        for($i=0; $i -lt $tokenlen; $i++) {
          $result = "" | select "code", "Ref_line", "Reference", "Target_line", "Target"
          $result.code = $code
          if ($i -lt $a.length) {
            $result.ref_line = ($a[$i][1]+1)
            $result.reference = $a[$i][0]
          }
          if ($i -lt $b.length) {
            $result.target_line = ($b[$i][1]+1)
            $result.target = $b[$i][0]
          }
          $results += $result
        }
      }

      $lcsPos++
    }

    $a = @()
    while ($refPos -lt $refObj.length ) {
      $a += ,($refObj[$refPos],$refPos)
      $refPos++
    }
    $b = @()
    while ($tarPos -lt $tarObj.length ) {
      $b += ,($tarObj[$tarPos],$tarPos)
      $tarPos++
    }
    $tokenlen = [math]::max($a.length, $b.length)
    $code = "Changed"
    if ($a.length -eq 0) {$code = "Added"}
    if ($b.length -eq 0) {$code = "Deleted"}

    if ($tokenlen -gt 0) {
      for($i=0; $i -lt $tokenlen; $i++) {
        $result = "" | select "code", "Ref line", "Reference", "Target line", "Target"
        $result.code = $code
        if ($i -lt $a.length) {
          $result.ref_line = ($a[$i][1]+1)
          $result.reference = $a[$i][0]
        }
        if ($i -lt $b.length) {
          $result.target_line = ($b[$i][1]+1)
          $result.target = $b[$i][0]
        }
        $results += $result
      }
    }
    $results | out-gridview
  } else {

    while ($lcsPos -lt ($lcsObj.length)) {
      $changes = $false
      while ($refPos -le $lcsObj[$lcsPos][1] ) {
        if ($refPos -ne $lcsObj[$lcsPos][1]) {
          write-host ("<="+($refPos+1).ToString($linefmt)+":"+$refObj[$refPos]) -ForegroundColor Red
          $changes = $true
        }
        $refPos++
      }

      while ($tarPos -le $lcsObj[$lcsPos][2] ) {
        if ($tarPos -ne $lcsObj[$lcsPos][2]) {
          write-host ("=>"+($tarPos+1).ToString($linefmt)+":"+$tarObj[$tarPos]) -ForegroundColor Yellow
          $changes = $true
        }
        $tarPos++
      }

      if ($changes) {
        write-host "=========="
      }
      $lcsPos++
    }

    while ($refPos -lt $refObj.length ) {
      write-host ("<="+($refPos+1).ToString($linefmt)+":"+$refObj[$refPos]) -ForegroundColor Red
      $refPos++
    }
    while ($tarPos -lt $tarObj.length ) {
      write-host ("=>"+($tarPos+1).ToString($linefmt)+":"+$tarObj[$tarPos]) -ForegroundColor Yellow
      $tarPos++
    }
  }
}
