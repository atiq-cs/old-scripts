@echo off
echo SA Windows Patching Script
echo.
set updatedir=F:\Softs\MS Updates\Install
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
@rem pkgmgr.exe /norestart /ip %updatedir%\MS Supports\Win7 Support\MS  Updates\Install\Temp\filename.xml
