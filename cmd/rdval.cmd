@echo off

setlocal

set value=

for /f "tokens=*" %%a in ('myARP %1 2^>NUL') do set value=%%a

@if [%value%] equ [Error] @(
	echo Error occurred
	goto exit
)

@echo value=%value%

:exit