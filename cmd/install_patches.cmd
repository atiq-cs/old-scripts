rem ***************************************************************************
rem * Author: Atiqur Rahman
rem * Desc:
rem *	Install downloaded microsoft updates  one by one from msu files
rem *	
rem *	Set updatedir first to the location where you downloaded update files
rem ***************************************************************************

@echo off
echo SAOSLab Windows Patching Script
echo.
set updatedir=F:\MS Updates\Install
set curdir="%cd%"
cd /d "%updatedir%"
For %%I in (*.msu) do echo Installing patch %%~nI && @wusa.exe "%updatedir%\%%~nI.msu" /quiet /norestart & move "%%~nI.msu" ..\ & echo Installed and moved file %%~nI.msu

@rem cleanup
@cd /d %curdir%
@set curdir=
@set updatedir=
@echo All patches processed.
@echo on
@rem this command is for extracted files
@rem pkgmgr.exe /norestart /ip %updatedir%\MS  Updates\Install\Temp\filename.xml
