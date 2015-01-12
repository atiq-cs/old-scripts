@if not exist %1.class goto End
@echo Saint Linux Scripting System
@echo Java Runtime Environment is loading virtual machine..
@echo %1.class (ByteCode) run by HotSpot TM Virtual Machine
@echo Now ejava Supports command line arguments
@echo under %os% DOS
@echo =========================================================
@echo.
@e:\xp\Java\jdk1.6.0_04\bin\java %*
@echo.
@goto success
:End
@echo Please correct your sourcecode: (%1.java) and recompile to generate ByteCode.
:success
@echo Process Ended
