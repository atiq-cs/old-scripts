@echo off
echo SA Global Scripts
set scriptpath=E:\svnws\Scripts
rem Detect whether the PC is my hall PC or office PC
set depopath=F:\Chrome\depot_tools
if exist E:\Sourcecodes goto officepcsetup
echo Applying residence settings
set scriptdrive=H:\
prompt [sa@saosx.com]$$ 
set progdir=d:\Win7_x86
set NETPREFIX=180.149.14
goto globalset

rem officepc configuration starts
:officepcsetup
echo Applying office settings
set scriptdrive=E:\
set progdir=C:\Program Files
prompt [sa@revesoft.com]$$ 
echo.
rem Detect network settings for office
echo Retrieving ISP Information
for /f "tokens=*" %%a in ('intconf.cmd getispinfo 2^>NUL') do set PCIP=%%a
if ["%PCIP%"] equ [""] (
	set NETPREFIX=192.168.16
	echo Current ISP: "CONNECTBD Ltd, Internet Service Provider, Dhaka, B" [on series 16]
	goto globalset
)

rem Else
echo ISP 'Advance Technology Computers Ltd' [on series 100]
set NETPREFIX=192.168.100

rem Global configurations
:globalset
title SA cmd terminal
color 02

rem Update scripts
echo Updating scripts
rem SVN Update Script special call so that environment not lost!!
set prepath=%path%
set path=%path%;%depopath%
cd /d E:\svnws
call %depopath%\svn.bat update
set path=%prepath%
cd /d %scriptpath%
rem restored previous path after updated
echo Got depopath: %depopath%
echo.
set PATH=%path%;%scriptpath%
rem PATH=%path%;%scriptpath%;%progdir%\Java\jdk1.6.0_16\bin
rem echo Initializing Environment for gnu compilers
rem add cygnus d:\Vista\cygnus\cygwin-b20\H-i586-cygwin32\bin;
rem echo Initializing Visual Studio Environment
if exist "%VS100COMNTOOLS%vsvars32.bat" call "%VS100COMNTOOLS%vsvars32.bat"
echo Inherited script path 2 %scriptpath%
cd /d %scriptpath%
call vcm.cmd
set PCIP=
echo on
