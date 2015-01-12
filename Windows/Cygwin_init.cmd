@echo off
Title SA Linux Terminal
color 02
set path=%path%;E:\sa\linux\bin;E:\sa\linux\lsdk\bin
rem C:\Program Files\Common Files\Microsoft Shared\Windows Live;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\;C:\Program Files\Windows Live\Shared;E:\sa\linux\bin;E:\sa\linux\lsdk\bin
bash --login -i
echo Thanks %username% for intelligent script
exit
echo on