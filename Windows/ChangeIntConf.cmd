rem ***************************************************************************
rem * Author: Atiqur Rahman
rem * Desc:
rem *	Imagine you have connection two networks one has the network prefix: 192.168.16
rem *	and other is 192.168.10
rem *	You want a simple script to switch between these two networks so that you don't have to
rem *		manually go to Network Adapter List, Right click properties and enter one by one each time you want to switch
rem *	This script modifies ethernet interface configuration
rem * 	    This Script changes the IP configuration of Local Area Connection
rem *
rem * call with argument 16: to enable prefix 192.168.16
rem * call with argument 10: to enable prefix 192.168.10
rem * call with switchisp: to switch between prefix
rem ***************************************************************************

@echo off
set prefix1=192.168.16
set prefix2=192.168.10

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
