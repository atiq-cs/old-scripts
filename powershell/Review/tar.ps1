<# Date  : 06/13/2015
# Author : Atique
# Motivation:
#   Why are you using gnu tools instead of using other tools such as WinRAR,
#    7-zip?
#   Because they might change the original file attributes as we suspect..
#   In past, as I have seen, gnutools just work
# Dsec:
#   gzip works with original path but it delete original file
#   So copy the file first, then, run gzip command
#   However, tar does not work with windows full path. easy solution is to use
#    relative path
#   if there is space in path we might have to add back slashes.
#
# Command Line Arguments:
#     xzvf with file path to extract file with extension tar.gz
#     xvf  to extract file with extension tar
#
# Command Line Examples,
#     .\tar.ps1 xjvf "G:\path\to\dir\name.tar.bz2"
#     .\tar.ps1 xzvf "G:\path\to\dir\name.tar.gz"
#>

Param(
    [Parameter(Mandatory=$true)] [alias("a")] [string]$Action,
    [Parameter(Mandatory=$true)] [alias("filepath")] [string]$archiveFilePath)


################################################################################
#####################       Functions' Definitions Start          ##############
################################################################################

# Purpose of this function is to verify prerequisite program are installed and
#  command line arguments are properly provided output global variables,
#   gnutoolsdir
#   archiveExFilePath
#   
function VERIFY_PREREQUISITES_AND_PARAMETERS() {
    # check for GNU Tools Path
    if ($HOST_TYPE.Equals("PC_NOTEBOOK")) {
        # MikTex installer is 32 bit, should have been installed in x86 directory
        $global:gnutoolsdir = 'D:\ProgramFiles_x86\GnuWin32\bin'
    }
    elseif ($HOST_TYPE.Equals("JASMINE_UNIVERSE_WS")) {
        Write-Host "Please set dir of GNU win32 tools.`r`n"
        return -1
    }
    elseif ($HOST_TYPE.Equals("VSINC_SERVER_2008")) {
        Write-Host -ForegroundColor Red "GNU win32 tools are not supported on V`
SINC yet!`r`n"
        return -1
    }

    # check for GNU Tools
    if (! (Test-Path $global:gnutoolsdir)) {
        Write-Host "PdfLatex script: please install GNUWin32 Tools and run`
again!`r`n"
        return -1
    }

    # Set for actions
    # xjvf is the argument and file has extension tar.bz2
    if ($Action.Equals("xjvf") -Or $Action.Equals("xzvf")) {

        if ($Action.Equals("xjvf")) { $global:archivExt = "tar.bz2" }
        elseif ($Action.Equals("xzvf")) { $global:archivExt = "tar.gz" }

        if (! $archiveFilePath.EndsWith($archivExt)) {
            Write-Host "Incorrect file extension.`n"
            return -1
        }
        if (! (Test-Path -path $archiveFilePath -pathtype leaf)) {
            Write-Host "Please provide correct archive file path.`n"
            return -1
        }
         
        # get-item $texFilePath
        $global:archiveDir = (Get-Item $archiveFilePath).Directory.FullName

        # get file name without extension
        $archiveFilePathWithoutExt = $archiveFilePath.Substring(0, `
          $archiveFilePath.LastIndexOf(".tar"))
        $global:archiveExFilePath = $archiveFilePathWithoutExt +"-ex."+$global:archivExt
        return 1
    }
    elseif ($Action.ToLower().Equals("xjvf") -Or $Action.ToLower().Equals("xvf") `
      -Or $Action.ToLower().Equals("xzvf")) {
        Write-Host "This argument is case sensitive. Please correct source latex file path.`n"
        return -1
    }

    Write-Host -ForegroundColor Red "Incorrect argument.`n"
    return -1
}

# Apply gunzip, bzip or other mechanism
# Global Inputs
# gnutoolsdir
# archiveExFilePath
# archivExt
# we are inside the directory
function ExtractPrimaryStage() {    
    Copy-Item $archiveFilePath $global:archiveExFilePath

    if ($global:archivExt.EndsWith("bz2")) {
        $bzipExec = $global:gnutoolsdir+"\bzip2.exe"
        # extract, overwrites, verbose
        & $bzipExec -dvf $global:archiveExFilePath
        # remove .bz2 from file name in path
        $global:archiveExFilePath = $global:archiveExFilePath.Substring(0, 
          $global:archiveExFilePath.LastIndexOf(".bz2"))
        return 1
    }
    elseif ($global:archivExt.EndsWith("gz")) {
        $gzipExec = $global:gnutoolsdir+"\gzip.exe"
        # extract, overwrites, verbose
        & $gzipExec -dvf $global:archiveExFilePath
        # remove .bz2 from file name in path
        $global:archiveExFilePath = $global:archiveExFilePath.Substring(0,
          $global:archiveExFilePath.LastIndexOf(".gz"))
        return 1
    }

    return 0
}

# tar extraction
# Global Inputs
#   gnutoolsdir
#   archiveExFilePath
# tar command only requires files name does not work with full file path
function ExtractSecondaryStage() {
    $tarExec = $global:gnutoolsdir+"\tar.exe"

    $global:archiveExFilePath = $archiveExFilePath.Replace($global:archiveDir+"\", "")
    # Write-Host $global:archiveExFilePath
    # remove .bz2
    & $tarExec -xvf $global:archiveExFilePath
    Remove-Item $global:archiveExFilePath
    return 1
}

#####################      Function Definition Ends             ###############
###############################################################################

# Start of Main function
function Main() {
    $res = VERIFY_PREREQUISITES_AND_PARAMETERS
    if ($res -le 0) {
        # got error
        break
    }

    Push-Location
    Set-Location $global:archiveDir
    $res = ExtractPrimaryStage
    if ($res -eq 1) {
        $res = ExtractSecondaryStage
    }
    Pop-Location
}

Main
