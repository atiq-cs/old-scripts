# Date: 02/19/2012 15:17:16
# Author: Atiq
# For `Write-Host` cmdlet, Before colon ':' must use grave sign, otherwise mess

$WordDBFile=$Env:scriptdir+"\..\WordList\Barron Word DB.txt"

if ($args.Count -eq 0) {
  Write-Host "No command line argument provided. Please provide word."
  break
}
else {
  $word = $args[0]
}

<#$list = select-string -pattern $args -path $WordDBFile
$i = 1
Write-Host "passed $i"
foreach($line in $list) {
  $i = $i + 1
  "$i`: $line"
}#>

$i = 1
$j = 1

# capture only for " word " or " word\t"

$regexP = " "+$word+" |"+" "+$word+"\t|"+" "+$word+";|"+" "+$word+"$"
select-string -pattern $regexP -path $WordDBFile | ForEach-Object {
  $bText = ""
  $line = $_.Line
  if ($line.StartsWith(" x")) {
    $bText = "[Non-barron]"
    $line = $line.TrimStart(" x")
    $line = " "+$line
  }
  
  if ($line.StartsWith(" $word ")) {
    #Write-Host "line: $line`n"
    $line = $line.TrimStart()
    #Write-Host "line: $line`n"
    $line = $line.TrimStart("$word")
    #Write-Host "line: $line`n"
    $line = $line.TrimStart(' ')
    Write-Host "Definition of $word $bText $i`:`t$line`n"
    $i = $i+1
  }
  elseif ($line.StartsWith(" $word`t")) {
    $line = $line.TrimStart(" $word")
    $line = $line.TrimStart()
    #Write-Host "Definition t of $word $i`:`t$line`n"
    #$line = $line.TrimStart("`t ")
    #$line = $line.TrimStart(" ")
    Write-Host "Definition of $word $bText $i`:`t$line`n"
    $i = $i+1
  }
  <#elseif ($line.StartsWith(" x $word ")) {
    $line = $line.TrimStart(" x $word ")
    $line = $line.TrimStart()
    Write-Host "Definition of $word [Non-barron] $i`:`t$line`n"
    $i = $i+1
  }
  elseif ($line.StartsWith(" x $word`t")) {
    $line = $line.TrimStart(" x $word`t")
    $line = $line.TrimStart()
    Write-Host "Definition of $word [Non-barron] $i`:`t$line`n"
    $i = $i+1
  }#>
  else {
    #Write-Host "Line: $line`n"
    $line = $line.TrimStart()
    $defpos = $line.IndexOf(" ")
    $nWord = $line.SubString(0, $defpos)
    $nWord = $nWord.TrimEnd()
    $line = $line.SubString($defpos)
    Write-Host "Inside definition of $nWord $bText $j`:`n$line`n"
    $j = $j+1
  }
}

if ($i -eq 1 -and $j -eq 1) {
  Write-Host "The word $word is not in barron's database.`n"
}

# .\WordFile-Search $word

Write-Host "`nInside current word file:"
$WordFile=$Env:scriptdir+"\..\WordList\words.txt"
Get-Content $WordFile | Select-String $word
