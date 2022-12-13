<#
.SYNOPSIS
  Spawn ID Manager to download a file using URI

.DESCRIPTION
  Updated 2012-12

.EXAMPLE

.NOTES
  Update $IDMEXE as per your install location
#>

$IDMEXE = "C:\PFiles_x64\Internet Download Manager\IDMan.exe"
$DNDIR = "F:\Videos"
# Example default value
$dnURL = "http://download.ted.com/talks/DenisDutton_2010-480p-en.mp4"

if ($args.Count -eq 0) {
    Write-Host "Please provide download URL."
    break
}
elseif ($args.Count -eq 1) {
    $dnURL = $args[0]
    Write-Host "Provided URL: $dnURL"
}
else {
    Write-Host "Too many command line arguments."
    break
}

& $IDMEXE /n /p $DNDIR /d $dnURL