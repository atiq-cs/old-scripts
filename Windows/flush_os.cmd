@set logfile=%scriptpath%\disguise_log.txt

@echo off
if [%1] equ [/t] @(
	if [%2] equ [] @(
		echo Rolling back internet.. Plz wait
		echo Second parameter should be ip
		goto exit
	)
	netsh interface ip set dns "local area connection" static 116.193.170.5
	netsh interface ip add dns "local area connection" 116.193.170.6
	netsh int ip set address "local area connection" static 10.16.128.%2 255.255.255.0 10.16.128.1 1
	goto exit
)

if [%1] equ [] @(
	cls
	echo Flushing Operating System
	echo Disguise agent %date% %time% > %logfile%
	netsh int ip set address "local area connection" static 192.8.50.27 255.0.0.0 192.8.50.120 1 >> %logfile%
	netsh interface ip set dns "local area connection" static 192.8.50.26 >> %logfile%
	netsh interface ip add dns "local area connection" 192.8.50.27 >> %logfile%
	devcon disable PCI\VEN_10EC >> %logfile%
	regedit /s %scriptpath%\mymac.reg >> %logfile%
	devcon enable PCI\VEN_10EC >> %logfile%
	if exist %scriptpath%\delay.exe %scriptpath%\delay 4
	echo Saint Research PC all permissions privelege released.
)

:exit
@echo on
