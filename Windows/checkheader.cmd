@echo off
echo HEAD / HTTP/1.1> telnethttpcmd.txt
echo Host: %1>> telnethttpcmd.txt
echo.>> telnethttpcmd.txt
nc.exe %1 80 < telnethttpcmd.txt
rem nc.exe %1 5058 < telnethttpcmd.txt
@echo on