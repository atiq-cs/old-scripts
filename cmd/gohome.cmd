@if exist mpl.cmd @echo You are already in scripting environment. Nothing to do. && @goto end
@if exist out.pdb goto exit_mscl
@if exist BSCMAKE.EXE goto exit_masm
@if exist "Traditonal template.java" goto exit_java
@if exist tasm.exe goto exit_tasm
@if exist imagedit.exe goto exit_win32
@goto end

:exit_mscl
@echo.
@del *.obj
@goto end
:exit_win32
@echo.
@echo Detected MASM Version 10, loading make conventions..
@call masm32_cls.cmd
@goto end
:exit_java
@call java_cls.cmd
@goto end

:exit_tasm
@call tasm_cls.cmd
@goto end

:exit_masm
@echo Deleting Previously generated Output file.
@del out.exe
@echo Resuming Scripting Environment
:end
@cd /d %scriptpath%
@echo.
