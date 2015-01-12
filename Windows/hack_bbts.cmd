@echo Saint Hack Script
if [%scriptpath%] equ [] @(
	echo Please define scriptpath and then try again.
	goto exit
)
set curdir="%cd%"
cd %scriptpath%

set prefix=10.16.128
rem Nulll value check: http://stackoverflow.com/questions/731332/check-for-null-variable-in-windows-batch
rem change ip: http://en.kioskea.net/forum/affich-13513-how-to-change-ip-address-from-command-prompt

if [%1] equ [] @(
	echo ip address in cl argument missing..
	goto exit
)

for /f "tokens=*" %%a in ('myARP %1 2^>NUL') do @set mac=%%a

if [%mac%] equ [] @(
	echo Empty network address.
	goto exit
)

if [%mac%] equ [Error] @(
	echo Couldn't Find Network Address for specified IP on the database.
	goto exit
)

if [%mac%] equ [ffffffffffff] @(
	echo Provided IP is not for PC.
	goto exit
)

echo Changing IP Address to %prefix%.%1
netsh int ipv4 set address "Local Area Connection" static %prefix%.%1 255.255.255.0 %prefix%.1 1
echo Got Network Address: %mac%
echo.

set mac_reg=[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\0007]

 rem disable NIC
echo Disabling Local Area Network Connection
devcon disable PCI\VEN_10EC
echo.
echo Changing Network Address
echo.
echo Windows Registry Editor Version 5.00> %scriptpath%\dynmac.reg
echo %mac_reg%>> %scriptpath%\dynmac.reg
echo "NetworkAddress"="%mac%">> %scriptpath%\dynmac.reg
regedit /s %scriptpath%\dynmac.reg
echo.
 rem enable NIC
echo Enabling Local Area Network Connection
devcon enable PCI\VEN_10EC
if exist %scriptpath%\delay.exe %scriptpath%\delay 4
if not exist %scriptpath%\delay.exe echo Cannot make delay. File doesn't exist.
getmac

ping 116.193.170.5
:exit
cd %curdir%
rem Unregister Envirionment variables
set curdir=
set prefix=
set mac_reg=
echo on