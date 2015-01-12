@echo off
rem http://rapidshare.com/#!download|20tl|418921349|The_Great_Design.pdf|20588
set DEBUG=OFF
set CountDownTime=

echo Rapidshare File Download Component
echo.
echo got args %*
rem Argument Validation
if [%1] equ [] (
	echo URL in cl argument missing..
	goto:eof
)

rem Initialization
set dndir=F:\Temp
set pagedownloader=c:\ProgData\GnuWin32\bin\wget.exe
rem set pagedownloader=idm.lnk
set curdir=%cd%

rem clear up
cd /d %dndir%
if [%DEBUG%] equ [OFF] (
	if exist ForCookie1.html del ForCookie1.html
	if exist ForCookie2.html del ForCookie2.html
)

echo Navigating to RS first page
echo.

if [%DEBUG%] equ [OFF] (
	if [%pagedownloader%] equ [c:\ProgData\GnuWin32\bin\wget.exe] (
		echo Downloading page: %1
		%pagedownloader% --user-agent="Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.151 Safari/534.16" --header="Accept-Language: en-US,en;q=0.8" --header="Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3" --header="Accept: application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5" --header="Accept-Encoding: gzip,deflate,sdch" --save-cookies=%dndir%\cookieunused.txt %1 -O %dndir%\ForCookie1.gz
	) else (
		rem have to stop dialog boxes cannot resolve how to post using idm
		%pagedownloader% /n /d %1 /p %dndir% /f ForCookie1.html
		pause
	)
)

rem Got ForCookie1.html
rem now Parse it to get serverURL and to store it to variable
for /f "tokens=*" %%a in ('ParseRS %dndir%\ForCookie1.html 2^>NUL') do set RSServerURL=%%a

echo Got server URL %RSServerURL%
echo.

echo Auto clicking free user
echo.

:DownloadFile
	rem there can be 3 cases after fetching in this page
	rem 1. Another user is already downloading a file
	rem 2. RS in waiting stage max upto 15 minutes and we have to wait
	rem 3. File Does not exist
	rem 4. Waiting for ticket
	rem 5. Little file, no waiting straight download
	rem 6. Unknown scenario rs changed or something other

	if [%DEBUG%] equ [OFF] (
		if [%pagedownloader%] equ [c:\ProgData\GnuWin32\bin\wget.exe] (
			%pagedownloader% --post-data=dl.start=Free ww%RSServerURL% -O %dndir%\ForCookie2.html
		) else (
			%pagedownloader% /n /d %RSServerURL%?dl.start=Free /p %dndir% /f ForCookie2.html
			pause
		)
	)

	rem Use my ParseRS executable to find the URL
	for /f "tokens=*" %%a in ('ParseRS %dndir%\ForCookie2.html 2^>NUL') do set RSDNURL=%%a
	echo Got Download URL %RSDNURL%
	echo.

	rem use findstr to get the line containing var c
	for /f "tokens=*" %%a in ('findstr /C:"var c" %dndir%\ForCookie2.html 2^>NUL') do set CDTimeLine=%%a
	echo Got CDTimeLine line as %CDTimeLine%

	rem parse the line using for
	for /f "eol=; tokens=1,2,9* delims==;" %%a in ("%CDTimeLine%") do set garbage=%%a & set CountDownTime=%%b
	echo First Part: %garbage%
	echo CountDownTime: %CountDownTime%
	
	if [%CountDownTime%] equ [] (
		echo There is a fatal error. Free and/ downloading is not available for some causes.
		rem do something or jump some where error checking is possible
		goto LabelCheckError1
	)

rem END
cd /d %curdir%
rem Unregister variables
set curdir=
set dndir=
set pagedownloader=
set RSDNURL=
set RSServerURL=
set CDTimeLine=
set CountDownTime=
set garbage=
echo on
goto LabelExitSingleDownload


:LabelExitSingleDownload