@echo off
tasklist|findstr /i  idman > tmp.txt
for /f "tokens=*" %%a in ('type tmp.txt 2^>NUL') do @set res1=%%a
del tmp.txt
echo %res1%
if [%res1%] equ [] @(
	echo ip address in cl argument missing..
	goto exit
)

if "%res1%"=="" echo IDMan doesn't exist
:input
set INPUT=
set /P INPUT=Type input: %=%
if "%INPUT%"=="" goto input
echo Your input was: %INPUT%
@echo on