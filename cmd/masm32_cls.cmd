@echo Saint Linux Script for Win32 MASM
@For %%I in (*.asm) do @if exist %%~nI.obj del %%~nI.obj && @if exist %%~nI.res del %%~nI.res && @if exist %%~nI.exe del %%~nI.exe && @echo deleted build files for: %%~nI.asm
@echo Garbage files deleted at %time% today: %date%
@I:
@cd I:\Sourcecodes\Scripts
@echo.
@echo Assembly Tasks Ended..
@echo Returning to scripts directory.
@Title Scripting and Working Konsole
