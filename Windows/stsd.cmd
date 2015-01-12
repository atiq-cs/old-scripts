@echo Scheduled Timer Shutdown
@delay %1
@msg * Time up. Shutting down.
@shutdown -s -t 0
