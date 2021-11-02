@title Saint Atique masm win32 platform
@echo Saint Atique Script
@echo MASM assemble syntax: wpl SourceFileName
@echo Creating object file.
@echo.
@if exist %1.exe del %1.exe
@if exist %1.obj del %1.obj
@ml /c /coff /Cp %1.asm
@if not exist %1.obj goto obj_fail
@if exist %1.rc @echo Linking %1.rc & @rc %1.rc
@echo Linking object file and res file
@link /SUBSYSTEM:WINDOWS /LIBPATH:e:\masm32\lib %1.obj %1.RES
@echo.
@if not exist %1.exe goto build_fail
@echo Running executable file: %1.exe
@echo ==============================================
@%1.exe
@echo.
@echo Process succeeded.
@goto end
:obj_fail
@echo.
@echo Error generating obj binary codes
@goto end
:build_fail
@echo.
@Echo Errors in source. Correction required..

:end
@echo Process Ended.
@title Saint Atique Terminal
