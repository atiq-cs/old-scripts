@echo Saint Hack Script
@echo Advanced file download management System
@set curdir="%cd%"
@cd /d %scriptpath%

@if [%1] equ [] @(
	echo Delay time in cl argument missing..
	goto exit
)

@if exist delay.exe delay.exe %1
@if not exist delay.exe echo "Cannot make delay. File doesn't exist." && goto exit
@msg * %1 seconds time is up for %2. Switch context now.

@if exist SetIDMInt.exe SetIDMInt.exe /1
@if not exist SetIDMInt.exe echo "Cannot write to registry. File doesn't exist." && goto exit

@echo Press any key after capturing the download.

@pause
@if exist SetIDMInt.exe SetIDMInt.exe /0

:exit
@cd /d %curdir%
@set curdir=
@echo All done.