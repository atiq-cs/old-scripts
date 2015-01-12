@echo off
	for /f "tokens=*" %%a in ('ParseRS %dndir%\ForCookie2.html 2^>NUL') do set RSDNURL=%%a
	echo Got Download URL %RSDNURL%
	echo.


	echo.
echo on