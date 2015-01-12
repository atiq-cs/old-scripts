@echo off
Title SVN Dev Terminal
color 02
set path=%path%;%depopath%
if [%depopath%] equ [H:\Sourcecodes\Chrome\depot_tools] (
	cd /d H:\Sourcecodes\Chrome\home\chrome-svn\tarball\chromium\src
)
if [%depopath%] equ [F:\Chrome\depot_tools] (
	cd /d F:\Chrome\depot_tools
)

set GYP_MSVS_VERSION=2010
echo on
