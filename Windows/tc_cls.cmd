@echo Saint Linux Script
@For %%I in (*.c*) do @del %%~nI.obj && @del %%~nI.exe && @del %%~nI.bak && @echo deleted file: %%~nI.obj, %%~nI.exe, %%~nI.bak
@echo Garbage files deleted at %time% today: %date%
