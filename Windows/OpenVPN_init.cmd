@echo off
Title OpenVPN Daemon
color 02
set vpnpath=c:\ProgData\OpenVPN\bin
set path=%path%;%vpnpath%
cd /d C:\ProgData\OpenVPN\config
echo Did you remember that openvpn requires 100 series IP? Starting openvpn..
rem gets recursive call problem when exe is omitted
openvpn.exe client.ovpn

set vpnpath=
echo on
exit