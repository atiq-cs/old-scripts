@echo off

net stop Tomcat6

if [%1] equ [restart] (
	echo Running restart script for web stack..
	echo.
	net stop Apache2.2
	net stop MySQL
	net start Apache2.2
	net start MySQL
	goto exit
)

if [%1] equ [start] (
	echo Running start script for web stack..
	echo.
	net start Apache2.2
	net start MySQL
	goto exit
)

if [%1] equ [] (
	echo Running start script for web stack..
	echo.
	net start Apache2.2
	net start MySQL
	goto exit
)

if [%1] equ [stop] (
	echo Running stop script for web stack..
	echo.
	net stop Apache2.2
	net stop MySQL
)

:exit
@echo on
