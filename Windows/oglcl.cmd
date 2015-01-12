@echo off
@title Saint Atique OpenGL Platform
@echo Saint Atique Compilation Script
@echo Creating object file.
@echo.
@if not exist %1.cpp goto fnf
@if exist %1.exe del %1.exe
@if exist %1.obj del %1.obj
@if exist Debug rd /s /q Debug
@cl /Zi /nologo /W3 /WX- /O2 /Oi /Oy- /GL /D "_MBCS" /Gm- /EHsc /MD /GS /Gy /fp:precise /Zc:wchar_t /Zc:forScope /Fp"%1.pch" /Fa"%1.asm" /Fo"%1.obj" /Fd"vc100.pdb" /Gd /analyze- /errorReport:queue %1.cpp
@if not exist %1.obj goto obj_fail
@echo Linking output obj file
@link /OUT:%1.exe /NOLOGO "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" /MANIFEST /ManifestFile:"%1.exe.intermediate.manifest" /ALLOWISOLATION /MANIFESTUAC:"level='asInvoker' uiAccess='false'" /DEBUG /PDB:"%1.pdb" /OPT:REF /OPT:ICF /LTCG /TLBID:1 /DYNAMICBASE /NXCOMPAT /MACHINE:X86 /ERRORREPORT:QUEUE %1.obj
@echo.
@if not exist %1.exe goto build_fail
@echo Running executable file: %1.exe
@echo ==================================================
@%1.exe
@echo.
@echo Process succeeded.
@goto end

:fnf
@echo.
@echo File %1.cpp not found.
@goto end

:obj_fail
@echo.
@echo Error generating obj binary codes
@goto end
:build_fail
@Echo Error building executable file..

:end
@echo Process Ended.
@if exist %1.exe del %1.exe
@echo on
@title Saint Atique Terminal
