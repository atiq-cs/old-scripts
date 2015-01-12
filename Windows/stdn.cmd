@echo Waiting for download to finish..
:loop
@delay 5:10
@if not exist %1 goto loop
@echo Download is complete. Waiting for locks to be free.
@echo Download of file %1 is complete > dnlog.txt
@delay 5:0
@echo Shutting system down %date% %time% >> dnlog.txt
@echo Shutting system down..
@shutdown /f /s /t 0
