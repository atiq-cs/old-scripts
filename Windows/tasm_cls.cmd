@echo Saint Linux Script
@For %%I in (*.asm) do @del %%~nI.obj && @del %%~nI.map && @del %%~nI.exe && @echo deleted file: %%~nI.obj, %%~nI.map, %%~nI.exe
@echo Garbage files deleted at %time% today: %date%
@I:
@cd I:\Sourcecodes\Scripts
@echo.
@echo Assembly Tasks Ended..
@echo Returning to scripts directory.
@Title Scripting and Working Konsole
