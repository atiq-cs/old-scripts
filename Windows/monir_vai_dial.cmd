@echo off
if [%1] equ [del] (
	if exist "C:\Windows\Downloaded Program Files\iTelWebDialer.inf" del "C:\Windows\Downloaded Program Files\iTelWebDialer.inf" && echo Deleted 1
	if exist C:\Windows\System32\WebSoftPhone.ocx del C:\Windows\System32\WebSoftPhone.ocx && echo Deleted 2
)

rem start iexplore.lnk http://192.168.100.88/iTelWebDialer.htm
rem start iexplore.lnk http://202.122.99.69/iTelWebDialer.htm
start iexplore.lnk http://192.168.16.88/itelTest/
echo on
