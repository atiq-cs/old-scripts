@echo off
set prefix=%NETPREFIX%

@if [%1] equ [] @(
	echo IP Address in cl argument missing..
	goto exit
)

if [%1] equ [/n] @(
	if [%2] equ [] @(
		echo IP Address in cl argument missing..
		goto exit
	)
	ping -a %prefix%.%2
	goto exit
)

ping %prefix%.%1
:exit

set prefix=
@echo on
