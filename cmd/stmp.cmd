@echo off
if [%1] equ [restart] (
	echo Running restart script for web stack..
	echo.
	net stop Tomcat6
	net stop MySQL
	net start Tomcat6
	net start MySQL
	goto exit
)

if [%1] equ [start] (
	echo Running start script for web stack..
	echo.
	net start Tomcat6
	net start MySQL
	goto exit
)

if [%1] equ [] (
	echo Running start script for web stack..
	echo.
	net start Tomcat6
	net start MySQL
	goto exit
)

if [%1] equ [stop] (
	echo Running stop script for web stack..
	echo.
	net stop Tomcat6
	net stop MySQL
)

:exit
@echo on
