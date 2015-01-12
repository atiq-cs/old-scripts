@echo Saint Hack Script

@if [%1] equ [] @(
	echo Network Address in cl argument missing..
	goto exit
)

@set mac_reg=[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\0007]

@ rem *********** GET NICE information using this command: devcon listclass net and get the string upto '&'
@ rem *********** help from: http://www.pcreview.co.uk/forums/thread-2304371.php

@ rem disable NIC
@echo Disabling Local Area Network Connection
@devcon disable PCI\VEN_10EC

@echo Changing Network Address
@echo Windows Registry Editor Version 5.00> %scriptpath%\dynmac.reg
@echo %mac_reg%>> %scriptpath%\dynmac.reg
@echo "NetworkAddress"="%1">> %scriptpath%\dynmac.reg
@regedit /s %scriptpath%\dynmac.reg

@ rem enable NIC
@devcon enable PCI\VEN_10EC
@echo Enabling Local Area Network Connection
@echo.

:exit
