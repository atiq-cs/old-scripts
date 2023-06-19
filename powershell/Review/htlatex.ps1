<# Date: 12/11/2012 16:13:11
   Author: Atiq
    Don't know the syntax, this script is not for frequent use

   Usage:
        .\htlatex "F:\Documents\Higher Study\CV\html" "SA_Resume_latex.tex
#>

if ($IS_MATRIX -eq $true) {
    $htlatexExec = 'C:\Program Files\MiKTex\miktex\bin\x64\htlatex.exe'
}
else {
    $htlatexExec = 'C:\Program Files\MikTex\miktex\bin\x64\htlatex.exe'
}

#get args
$texWsDir = $args[0]
$texFileName = $args[1]

if ($texWsDir.Equals("openexp")) {
    $defaultTexDir = "H:\Higher Study\CV"
    explorer $defaultTexDir
    break
}

# check if directory really exists
if (! (Test-Path $texWsDir)) {
    Write-Host "Provided directory does not exist"
    break
}

# file file name
if ($texFileName.EndsWith(".tex")) {
    # inputText = inputText.Substring(0, inputText.LastIndexOf(item))
    $texFileName = $texFileName.Substring(0, $texFileName.LastIndexOf(".tex"))
    Write-Host "File Name: " $texFileName
}

<# Kill adobe pdf reader
if (Get-Process AcroRd32 -ErrorAction SilentlyContinue) {
    # process is running
    # Write-Host ""
    Write-Host "Stopping Adobe Reader."
    Stop-Process -processname AcroRd32
}
else {
    # process is not running
    # Write-Host "Adobe Reader not found."
}

# delete previous pdf file
$tmpFileName =  $texFileName + "_pre.pdf"
$tmpFilePath = $texWsDir + "\" + $tmpFileName
if (Test-Path $tmpFilePath) {
    rm $tmpFilePath
    Write-Host "Removed " $tmpFilePath
}

$curpdfFilePath = $texWsDir + "\" + $texFileName + ".pdf"
# rename current to previous
if (Test-Path $curpdfFilePath) {
    Rename-Item $curpdfFilePath $tmpFileName
    Write-Host "Renamed " $curpdfFilePath " to " $tmpFileName
}
#>

# then create current
$curTexFilePath = "`"${texWsDir}\${texFileName}.tex`""
#Write-Host "Command line: $htlatexExec $curTexFilePath -output-directory=$texWsDir"
#$htlatexExec = $htlatexExec+" "+$curTexFilePath
$dirarg = "`"-output-directory=$texWsDir`""
#Write-Host "arg2: $dirarg"
#& $htlatexExec $curTexFilePath $dirarg
$argList=$curTexFilePath,$dirarg
Write-Host "Start-Process $htlatexExec -Verb Runas -ArgumentList $argList -ErrorAction `'stop`'"
Start-Process $htlatexExec -Verb Runas -ArgumentList $argList -ErrorAction 'stop'
# & $htlatexExec H:\Higher_Study\CV\SA_CV_latex.tex -output-directory=H:\Higher_Study\CV

Write-Host -NoNewline "`nWaiting for htlatex to exit"
while (Get-Process htlatex -ErrorAction SilentlyContinue) {
    Write-Host -NoNewline "."
    Sleep 1
}

<# open with adobe pdf reader
if (Test-Path $curpdfFilePath) {
    if ($IS_MATRIX -eq $true) {
        $adobeProg = "C:\Program Files\Adobe\Reader 10.0\Reader\AcroRd32.exe"
    }
    else {
        $adobeProg = "C:\Program Files (x86)\Adobe\Reader 11.0\Reader\AcroRd32.exe"
    }

    Write-Host "`rOpening output pdf file with Adobe Reader"
    # Command line references 1
    # 1. http://partners.adobe.com/public/developer/en/acrobat/PDFOpenParameters.pdf
    # 2. http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/Acrobat_SDK_developer_faq.pdf
    & $adobeProg /A "zoom=100=OpenActions" $curpdfFilePath
}#>

Write-Host " "
