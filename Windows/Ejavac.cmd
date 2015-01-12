@echo Saint Linux Scripting System
@echo Initializing..
@if exist %2.class del %2.class
@echo Pre-checking to generate ByteCode %1.java
@e:\xp\Java\jdk1.6.0_04\bin\javac.exe %1.java
@if not exist %2.class goto End
@echo %1.class (Executable file running under %os% DOS)
@echo =========================================================
@echo.
@e:\xp\Java\jdk1.6.0_04\bin\java %2 %3
@goto success
:End
@echo.
@echo Please correct your sourcecode: (%1.java) and recompile to generate ByteCode.
:success
@echo.
@echo Process Ended
