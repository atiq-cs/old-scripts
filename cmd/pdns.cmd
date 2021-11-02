@echo off
echo Sending dns resolve request to
nslookup www.google.com

echo.
echo Checking if primary dns server replies to ping.
ping 174.136.48.107
echo.
echo Checking if secondary dns server replies to ping.
ping 4.2.2.2
echo.
echo Checking if default gateway replies to ping.
ping %NETPREFIX%.1
echo on