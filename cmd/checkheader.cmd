rem Author: Atiqur Rahman
rem Script uses netcat to retrieve HTTP 1.1 HEAD
@echo off
echo HEAD / HTTP/1.1> telnethttpcmd.txt
echo Host: %1>> telnethttpcmd.txt
echo.>> telnethttpcmd.txt
nc.exe %1 80 < telnethttpcmd.txt
rem Use like this to change port
rem nc.exe %1 5058 < telnethttpcmd.txt
@echo on