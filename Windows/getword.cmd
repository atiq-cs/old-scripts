@echo off
rem SAOS Scripts
rem Author:	Saint Atique
rem You can freely modify/distribute this code but don't use it for commercial reason
rem idm instructions at http://www.internetdownloadmanager.com/support/command_line.html

rem To make this script work

echo Saint Thesaurus Script
rem For 32 bit windows
rem Set IDM location
set IDMEXEC="C:\Program Files\Internet Download Manager\idman.exe"
rem Set Windows Media Player Location, according to OS
set WMPLAYERMEXEC="C:\Program Files\Windows Media Player\wmplayer.exe"
rem Windows Seven 64 bit
rem set WMPLAYERMEXEC="C:\Program Files (x86)\Windows Media Player\wmplayer.exe"
rem set IDMEXEC="D:\Win7_x86\Internet Download Manager\idman.exe"
tasklist|findstr /i idman 1> tmp.txt
for /f "tokens=*" %%a in ('type tmp.txt 2^>NUL') do set res1=%%a
del tmp.txt
if ["%res1%"] equ [""] (
	goto startmainprocess
)

set INPUT=
echo Internet Download Manager is alreay active. Are you sure to kill task IDM?
:input
set /P INPUT=Type y to confirm or any other key to skip: %=%
if [%INPUT%] equ [] goto input
if [%INPUT%] equ [y] @(
	taskkill /f /im IDMan.exe
	echo Skipping killing IDM. Exiting..
	goto startmainprocess
)

goto end
:startmainprocess
rem ThesaurusDir is the dir where pronunciation files are stored.
set ThesaurusDir=G:\Thesaurus
md %ThesaurusDir%
if exist %ThesaurusDir%\%1.mp3 goto playaudio
echo Pronunciation file for the word %1 not found. Downloading..
%IDMEXEC% /n /q /d "http://www.gstatic.com/dictionary/static/sounds/de/0/%1.mp3" /p %ThesaurusDir%\
if not exist %ThesaurusDir%\%1.mp3 goto end

:playaudio
if not exist %ThesaurusDir%\%1.mp3 goto wait
start %WMPLAYERMEXEC% %ThesaurusDir%\%1.mp3
goto end

:wait
echo File download in progress.
%scriptpath%\delay 2
goto playaudio

:end
set INPUT=
set res1=
set ThesaurusDir=
@echo on
