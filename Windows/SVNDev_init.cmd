@echo off
Title SVN Dev Terminal
color 02
set depopath=H:\Sourcecodes\Chrome\depot_tools
if exist E:\Sourcecodes (
	set depopath=F:\Chrome\depot_tools
)

if ["%depopath%"] equ [""] (
	echo depopath not set. Exiting..
	pause
	exit
)

set path=%path%;%depopath%
if [%depopath%] equ [H:\Sourcecodes\Chrome\depot_tools] (
	cd /d H:\Sourcecodes\Chrome\home\chrome-svn\tarball\chromium\src
)
if [%depopath%] equ [F:\Chrome\depot_tools] (
	cd /d F:\Chrome\depot_tools
)
echo on
