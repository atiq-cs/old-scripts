@title Saint Atique masm platform
@echo Saint Atique Script
@echo MASM assemble syntax: mpl SourceFileName (output file is out.exe)
@echo Creating object file.
@echo.
@rem case sensitive /ml switch
@if exist out.exe del out.exe
@if exist out.obj del out.obj
@masm /ml %1 out
@if not exist out.obj goto obj_fail
@echo Linking output obj file
@link /batch out;
@echo.
@if not exist out.exe goto build_fail
@echo Running executable file: out.exe
@echo ==============================================
@out
@echo.
@echo Process succeeded.
@goto end
:obj_fail
@echo.
@echo Error generating obj binary codes
@goto end
:build_fail
@Echo Error building executable file..

:end
@echo Process Ended.
@title Saint Atique Terminal
