rem ***************************************************************************
rem * Author: Atiqur Rahman
rem * Desc:
rem *	You wanna type npp with arguments or not you want notepad++ to appear
rem *	  This script performs this simple task. Additionally, it checks
rem *	   whether system has x86 program files directory (present in modern 64 bit Windows Systems)
rem *	   If not found uses old program files location so that it works on 32 bit old OSs
rem ***************************************************************************

@echo Notepad++ is opening %1
@if exist echo %ProgramFiles(x86)% @start %ProgramFiles(x86)%\notepad++\notepad++.exe %* && goto exit
start %ProgramFiles%\notepad++\notepad++.exe %* && goto exit

:exit
