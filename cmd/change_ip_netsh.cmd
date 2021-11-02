@echo Changing IP Address to %prefix%.%1
@netsh int ipv4 set address "Local Area Connection" static %prefix%.%1 255.255.255.0 %prefix%.1 1
