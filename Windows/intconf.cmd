@echo off
set prefix1=192.168.16
set prefix2=192.168.10

rem ***************************************************************************
rem * This Script changes the IP configuration of VoIPTA
rem * on: to enable prefix 192.168.16
rem * on: to enable prefix %prefix2%0
rem ***************************************************************************

rem echo SA Hack Script
rem echo.

if [%1] equ [] (
	echo Configuration mode in cl argument missing. Available options:
	echo 1. 16
	echo 2. 10
	echo 3. status
	goto exit
)

if [%1] equ [16] (
	goto setisp1
)

if [%1] equ [10] (
	goto setisp2
)

if [%1] equ [switchisp] (
	goto labelispswitch
)

if [%1] equ [status] (
	netsh int ipv4 show config "Local Area Connection"
	goto exit
)

if [%1] equ [getispinfo] (
	netsh int ipv4 show config "Local Area Connection" | findstr /i 100.12
	goto exit
)

echo Configuration mode in cl argument is invalid. Available options:
echo 1. 16
echo 2. 10
goto exit

:labelispswitch
if [%NETPREFIX%] equ [%prefix2%] (
	echo Switch to series %prefix1%
	goto setisp1
)

rem Else
echo Switch to series %prefix2%
goto setisp2

:setisp1
	set NETPREFIX=
	set NETPREFIX=%prefix1%
	echo Default Interface IP Configuration is being changed [prefix: %NETPREFIX%]
	netsh int ip set address "Local Area Connection" static %NETPREFIX%.12 255.255.255.0 %NETPREFIX%.1 1
	rem Info on gateway metric: http://wiki.answers.com/Q/What_is_Gateway_and_Metric
	
	delay 4
	netsh int ipv4 show config "Local Area Connection"
	ping %NETPREFIX%.1
goto exit

:setisp2
	set NETPREFIX=%prefix2%
	echo Default Interface IP Configuration is being restored [prefix: %NETPREFIX%]
	netsh int ip set address "Local Area Connection" static %NETPREFIX%.12 255.255.255.0 %NETPREFIX%.1 1
	delay 4
	netsh int ip show config "Local Area Connection"
	ping %NETPREFIX%.1
goto exit

:exit
set prefix1=
set prefix2=
echo on
