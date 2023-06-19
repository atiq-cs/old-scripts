<#
 # Date: 12/11/2012 16:13:11
 # Author: Atiq

  Usage EXamples (sorted by newest),
  $ pdflatex.ps1 CreatePDF main.tex

  First time install would require some fonts and additional packages installation which can be
  taken care of using elevation,
  $ pdflatex.ps1 CreatePDF main.tex -perm elevate

  $ pdflatex.ps1 cleantex .
  $ pdflatex.ps1 CreatePDF "$(Get-Location)\ascend\cs.tex"
  
  Old Usage EXamples:
  $ pdflatex.ps1 CreatePDF "F:\svnws\All_Latex\Cover Letters\Moderncv Banking\job_gaming_se_cover_letter.tex"
  $ pdflatex.ps1 cleantex "F:\svnws\All_Latex\Cover Letters\Moderncv Banking"
  $ pdflatex.ps1 CreatePDF main.tex
  $ pdflatex.ps1 CreatePDF F:\svnws\All_Latex\Resume\SA_Resume_intern.tex
  $ pdflatex.ps1 CreatePDF "F:\svnws\All_Latex\Data Mining\04_Milestone\sigproc-sp.tex" -hasRef yes
  $ pdflatex.ps1 CreatePDF "F:\svnws\All_Latex\Data Mining\04_Milestone\sigproc-sp.tex" -perm elevate -ref yes
  $ pdflatex.ps1 "F:\svnws\All_Latex\Data Mining\05_Final" sigproc-sp --noelevation --refcompile
  $ pdflatex.ps1 F:\svnws\All_Latex\Resume SA_Resume_intern.tex --noelevation
  $ pdflatex.ps1 "F:\Documents\English\Higher Study Docs\SOP\Latex" "Atiqur Rahman_SOP.tex"
#>

#whenever epstopdf error occurs
#$Env:path += ";"+"C:\Program Files\MiKTex\miktex\bin\x64"

Param(
  [Parameter(Mandatory=$true)] [alias("a")] [string]$Action,
  [Parameter(Mandatory=$true)] [alias("filepath")] [string]$texFilePath,
  [Parameter(Mandatory=$false)] [alias("perm")] [string]$runAs,
  [Parameter(Mandatory=$false)] [alias("ref")] [string]$hasRef)

#######################################################################################################
#####################     Functions' Definitions Start      #####################################
#######################################################################################################

# Purpose of this function is to verify prerequisite program are installed and command line
# arguments are properly provided
function VERIFY_PREREQUISITES_AND_PARAMETERS() {
  if ($HOST_TYPE.Equals("PC_NOTEBOOK") -Or $HOST_TYPE.Equals("OFFICE_WS")) {
    $global:pdflatexExec = $Env:PFilesX64 + '\miktex\miktex\bin\x64\pdflatex.exe'
  }
  elseif ($HOST_TYPE.Equals("JASMINE_UNIVERSE_WS")) {
    $global:pdflatexExec = "${Env:ProgramFiles}\MikTex\miktex\bin\x64\pdflatex.exe"
  }
  elseif ($HOST_TYPE.Equals("VSINC_SERVER_2008")) {
    $global:pdflatexExec = 'C:\texlive\2014\bin\win32\pdflatex.exe'
  }
  else {
    Write-Host "PdfLatex script: Host type not recognized!`r`n"
    return -1
  }


  if ($Action.ToLower().Equals("createpdf")) {
    # check if PdfLatex is installed in the system
    # moved the condition here, want to run the script with cleantex without installing miktex
    if (! (Test-Path $global:pdflatexExec)) {
      Write-Host $global:pdflatexExec
      Write-Host "PdfLatex script: please install Miktex latex and run again!`r`n"
      return -1
    }

    # Add ".tex" if not provided
    # file file name
    if (! $texFilePath.EndsWith(".tex")) {
      # inputText = inputText.Substring(0, inputText.LastIndexOf(item))
      $texFilePath = $texFilePath + ".tex"
    }
    if (! (Test-Path -path $texFilePath -pathtype leaf)) {
      Write-Host "Please provide correct source latex file path.`n"
      return -1
    }
     
    # Get only file name
    $global:texWsDir = (Get-Item $texFilePath).Directory.FullName
    $global:texFileName = $texFilePath.Replace($global:texWsDir+"\", "")

    # file name
    if ($global:texFileName.EndsWith(".tex")) {
      # inputText = inputText.Substring(0, inputText.LastIndexOf(item))
      $global:texFileName = $global:texFileName.Substring(0, $global:texFileName.LastIndexOf(".tex"))
    }
    $global:curTexFilePath = "`"${global:texWsDir}\${texFileName}.tex`""
    $global:curpdfFilePath = $global:texWsDir + "\" + $texFileName + ".pdf"
    $global:pdfName = $texFileName + ".pdf"
  }
  elseif ($Action.ToLower().Equals("cleantex")) {
    # empty string check not required for mandatory parameter
    if (! ( Test-Path $texFilePath) -Or (Test-Path -path $texFilePath -pathtype leaf)) {
      Write-Host "Incorrect input directory `"$texFilePath`"`n"
      return -1
    }
    # provided arguments correct
    return 1
  }
  elseif ($Action.ToLower().Equals("open")) {
    Write-Host -ForegroundColor Red "Not implemented!`n"
    return -1
  }
  else {
    Write-Host -ForegroundColor Red "Incorrect action specified: `"$Action`"`n"
    return -1
  }

  $global:IsElevated = $false
  if ((! $runAs.Equals("")) -and $runAs.Tolower().Equals("elevate")) {
    $global:IsElevated = $true
    $global:dirarg = "`"-output-directory=$global:texWsDir`""
  }

  $global:IsReferenced = $false
  if ($hasRef.Equals(""))
  {
    Write-Host -ForegroundColor Green "Fast compilation: no reference"
  }
  elseif ($hasRef.Tolower().Equals("yes")) {
    Write-Host -ForegroundColor Green "Reference compilation set"
    $global:IsReferenced = $true
    # $global:curBibFilePath = "`"${global:texWsDir}\${texFileName}.bib`""
  }
  elseif ($hasRef.Tolower().Equals("no")) {
    Write-Host -ForegroundColor Green "Fast compilation: no reference"
  }
  else {
    Write-Host -ForegroundColor Red "Invalid reference parameter: $hasRef. Please correct commandline and run again."
    return -1
  }
  
  return 1
}


# Kill adobe pdf reader
function KillPDFReader([string] $pdfReaderProgram, [string] $pdftitle) {
  # Write-Host "got title: $pdftitle"
  
  if (Get-Process $pdfReaderProgram -ErrorAction SilentlyContinue) {
    # $res = Get-Process $pdfReaderProgram -ErrorAction SilentlyContinue | where {$_.MainWindowTitle.Equals($pdftitle)}
    $IsKilled = $false
    do {
      # Hint for accessing members http://www.computerperformance.co.uk/powershell/powershell_process_stop.htm
      # Hint if we want this automated http://stackoverflow.com/questions/1777668/send-message-to-a-windows-process-not-its-main-window
      # process class https://msdn.microsoft.com/en-us/library/system.diagnostics.process_properties(v=vs.110).aspx
      $res = Get-Process $pdfReaderProgram -ErrorAction SilentlyContinue | where {$_.MainWindowTitle.ToString().StartsWith($pdftitle)}
      <#foreach($p in $res) {
        Write-Host "process`: `""$p.MainWindowTitle"`""
      }#>

      if ($res -eq $null) {
        $response = Read-Host "Is there a process active? (if yes`: activate and press y)"

        if ($response.Equals("n")) {
          $IsKilled = $true
          # Write-Host "You pressed" $response
          # $response | Get-Member
        }
      }
      else {
        Write-Host "Stopping Adobe Reader" $res.Id
        # Stop-Process -Id $res.Id
        # $res.Close()
        $res.CloseMainWindow()
        $IsKilled = $true
      }

    } while ($IsKilled -eq $false);
    }
  else {
    # process is not running
    Write-Host "Adobe Reader process not found running."
  }
}

<# not keeping preivious versions of pdf docs anymore
# delete previous pdf file
$tmpFileName =  $texFileName + "_pre.pdf"
$tmpFilePath = $texWsDir + "\" + $tmpFileName
if (Test-Path $tmpFilePath) {
  rm $tmpFilePath
  Write-Host "Removed " $tmpFilePath
}

# rename current to previous
if (Test-Path $curpdfFilePath) {
  Start-Sleep 1
  Rename-Item $curpdfFilePath $tmpFileName
  Write-Host "Renamed " $curpdfFilePath " to " $tmpFileName
}
#>

# then create current
#$curInputFilePath = "`"${texWsDir}\${texFileName}`""
#Write-Host "Command line: $global:pdflatexExec $curTexFilePath -output-directory=$texWsDir"
#$global:pdflatexExec = $global:pdflatexExec+" "+$curTexFilePath
#Write-Host "arg2: $dirarg"
#& $global:pdflatexExec $curTexFilePath $dirarg
function CreatePDFUsingMikTex() {
  Push-Location
  cd $global:texWsDir
  if ($global:IsElevated) {
    $argList=$global:curTexFilePath,$global:dirarg
    
    Write-Host "Final Commandline is: Start-Process $global:pdflatexExec -Verb Runas -ArgumentList $argList -ErrorAction `'stop`'"
    try {
      Start-Process $global:pdflatexExec -Verb Runas -ArgumentList $argList -ErrorAction 'stop'
      # & $global:pdflatexExec H:\Higher_Study\CV\SA_CV_latex.tex -output-directory=H:\Higher_Study\CV
    }
    catch {
      Write-Host -ForegroundColor Red "Permission denied. Exiting..`n"
      Pop-Location
      exit
    }
    Write-Host -NoNewline "`nWaiting for pdflatex to exit"
    while (Get-Process pdflatex -ErrorAction SilentlyContinue) {
      Write-Host -NoNewline "."
      Sleep 1
    }
  }
  else {
    # Write-Host "We are not elevated $global:dirarg`r`n"
    if ($global:IsReferenced) { Write-Host -ForegroundColor Red "Do not run with `'-hasRef yes`' if you have an error in document.`r`n" }

    if ($global:IsReferenced) {
      if ($HOST_TYPE.Equals("PC_NOTEBOOK")) {
        $bibtexExec = 'D:\ProgramFiles\MikTex\miktex\bin\x64\bibtex.exe'
        $latexExec = 'D:\ProgramFiles\MikTex\miktex\bin\x64\latex.exe'
      }
      elseif ($HOST_TYPE.Equals("ORACLE_WS")) {
        # MikTex installer 64 bit
        $bibtexExec = "D:\ProgFiles_x64\MiKTeX 2.9\miktex\bin\x64\bibtex.exe"
        $latexExec = "D:\ProgFiles_x64\MiKTeX 2.9\miktex\bin\x64\latex.exe"
      }
      elseif ($HOST_TYPE.Equals("VSINC_SERVER_2008")) {
        $bibtexExec = 'C:\texlive\2014\bin\win32\bibtex.exe'
        $latexExec = 'C:\texlive\2014\bin\win32\pdflatex.exe'
      }

      Write-Host -ForegroundColor Green "Reference compilation: first run of latex"
      & $latexExec $global:texFileName

      # For disk IO, not sure if this is required
      Start-Sleep -Milliseconds 5
      #Write-Host -ForegroundColor Green "bib file path`: $global:texFileName"
      Write-Host -ForegroundColor Green "`r`nFirst run of bibtex"
      & $bibtexExec $global:texFileName
      #Start-Sleep -Milliseconds 10
      #popd
      #exit
      Start-Sleep -Milliseconds 5
      Write-Host -ForegroundColor Green "`r`nSecond run of latex"
      & $latexExec $global:texFileName
      #Start-Sleep -Milliseconds 10
      Start-Sleep -Milliseconds 5
      # & $latexExec $curTexFilePath
      Write-Host -ForegroundColor Green "`r`Final run of latex"
    }
    # Write-Host "$global:pdflatexExec $global:texFileName"
    & $global:pdflatexExec $global:texFileName
    Start-Sleep -Milliseconds 10
  }
  Pop-Location
  Write-Host " "
}

function OpenWithAdobePDFReader([string] $pdfFilePath) {
  # open with adobe pdf reader
  if (Test-Path $pdfFilePath) {
    if ($IsPDFReaderUWP) {
      Write-Host "`rOpening output pdf file with StoreApp Adobe Reader"
      & $pdfFilePath
      return
    }
    if ($HOST_TYPE.Equals("PC_NOTEBOOK") -Or $HOST_TYPE.Equals("OFFICE_WS")) {
      $adobeProg = $Env:PFilesX86 + '\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe'
    }
    elseif ($HOST_TYPE.Equals("JASMINE_UNIVERSE_WS")) {
      # adobe reader 32 bit
      $adobeProg = "${Env:ProgramFiles(x86)}\Adobe\Reader 11.0\Reader\AcroRd32.exe"
    }

    elseif ($HOST_TYPE.Equals("VSINC_SERVER_2008")) {
      $adobeProg = "C:\Program Files (x86)\Adobe\Reader 11.0\Reader\AcroRd32.exe"
    }

    if (Test-path $adobeProg) {
      Write-Host "`rOpening output pdf file with Adobe Reader"
      # Command line references 1
      # 1. http://partners.adobe.com/public/developer/en/acrobat/PDFOpenParameters.pdf
      # 2. http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/Acrobat_SDK_developer_faq.pdf
      & $adobeProg /A "zoom=100=OpenActions" $pdfFilePath
    }
    # Favor registry path instead
    # TODO: verify path from registry
    Start-Process acrord32 /A,"zoom=100=OpenActions",$pdfFilePath
  }
}


#####################    Function Definition Ends       #####################################
#######################################################################################################

# Start of Main function
function Main() {
  $res = VERIFY_PREREQUISITES_AND_PARAMETERS
  if ($res -le 0) {
    # Write-Host "Returns $res`r`n"
    break
  }
  if ($Action.ToLower().Equals("cleantex")) {
    # Remove tex created files
    $texWsDir = $texFilePath

    $ExtList = "pdf","aux","log","out", "bbl", "blg", "dvi", "synctex.gz"

    # Clean for tex
    gci -Recurse $texWsDir\*.tex | %{
      $FullPath = $_.fullName
      $BarePath = $FullPath.Substring(0, $FullPath.LastIndexOf(".tex"))
      $hasCleaned = $false

      Foreach($ext in $ExtList) {
        $ExtraTexFilePath = $BarePath+"."+$ext
        if (Test-Path $ExtraTexFilePath) {
          Remove-Item -Force $ExtraTexFilePath
          $hasCleaned = $true
        }
      }
      if ($hasCleaned) { Write-Host "Processed" $_.FullName }
    }
    Write-Host "For Tex files cleaned."
    # Clean for tex
    gci -Recurse $texWsDir\*.eps | %{
      $FullPath = $_.fullName
      $BarePath = $FullPath.Substring(0, $FullPath.LastIndexOf(".eps"))

      $ExtraTexFilePath = $BarePath+"-eps-converted-to.pdf"
      if (Test-Path $ExtraTexFilePath) {
        Remove-Item -Force $ExtraTexFilePath
        Write-Host "Processed" $_.FullName
      }
    }
    Write-Host "For eps files cleaned."
    $ExtraTexFilePath = $(Get-Location).Path + "\texput.log"
    if (Test-Path $ExtraTexFilePath) {
      Remove-Item -Force $ExtraTexFilePath
      Write-Host "Processed" $ExtraTexFilePath
    }
  }
  else {
    $script:IsPDFReaderUWP = $false
    # requires if you use adobe pdf reader to open the pdf file and the reader locks the file..
    KillPDFReader AcroRd32 $global:pdfName
    CreatePDFUsingMikTex
    OpenWithAdobePDFReader $global:curpdfFilePath
  }
}

Main
