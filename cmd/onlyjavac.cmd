@echo Saint Linux Scripting System
@echo Initializing..
@if exist %2.class del %2.class
@echo Pre-checking to generate ByteCode %1.java
@f:\xp\Java\jdk1.6.0_03\bin\javac.exe %1.java
@echo.
@echo Process Ended
