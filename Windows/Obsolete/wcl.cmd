@title Saint Atique OpenGL platform
@echo Saint Atique Script
@echo Creating object file.
@echo.
@if not exist %1.cpp goto fnf
@if exist out.exe del out.exe
@cl /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /FD /EHa /MDd /W3 /nologo /c /Zi /clr /TP  /errorReport:prompt %1.cpp
@rem cl /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /FD /EHa /MDd /Fo"Debug\\" /Fd"Debug\vc90.pdb" /W3 /nologo /c /Zi /clr /TP /errorReport:prompt
@if not exist %1.obj goto obj_fail
@echo Linking output obj file
@link /OUT:out.exe /INCREMENTAL /NOLOGO /MANIFEST /MANIFESTUAC:"level='asInvoker' uiAccess='false'" /DEBUG /ASSEMBLYDEBUG /SUBSYSTEM:CONSOLE /DYNAMICBASE /FIXED:No /NXCOMPAT /MACHINE:X86 /ERRORREPORT:PROMPT Iphlpapi.lib  kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib %1.obj

@rem /OUT:"G:\Sourcecodes\Win32\winAPI\ICMP1\Debug\ICMP1.exe" /INCREMENTAL /NOLOGO /MANIFEST /MANIFESTFILE:"Debug\ICMP1.exe.intermediate.manifest" /MANIFESTUAC:"level='asInvoker' uiAccess='false'" /DEBUG /ASSEMBLYDEBUG /PDB:"g:\Sourcecodes\Win32\winAPI\ICMP1\Debug\ICMP1.pdb" /SUBSYSTEM:CONSOLE /DYNAMICBASE /FIXED:No /NXCOMPAT /MACHINE:X86 /ERRORREPORT:PROMPT Iphlpapi.lib  kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib
@echo.
@if not exist out.exe goto build_fail
@echo Running executable file
@out
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
@title Saint Atique Terminal
