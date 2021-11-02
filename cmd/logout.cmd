rem ***************************************************************************
rem * Author: Atiqur Rahman
rem * Desc:
rem *	Imagine you have a command prompt that has the strength of providing you a shell that lets you do your complex tasks at minimal effort
rem *	Shell_Init gives such a command prompt
rem *	
rem *	Before we exit his shell we need to cleanup some things, schedule some tasks and finally commit changes to the workspace used
rem * 	This Script performs these operations
rem ***************************************************************************

@echo off
if exist konsole.cmd goto term_konsole
echo.
echo Other tasks running..
echo Closing other applications.
call %scriptpath%\gohome.cmd
:term_konsole
if exist ungc.lnk goto uninstall
if exist displaymsg.cmd goto showdialogs
:logout
echo Committing modified information. Also consider commiting manually if you have modified other projects.
echo.
cd /d %scriptpath%
cd ..
svn commit .\ --username YOUR_USERNAME --password YOUR_PASSWORD -m "Automated commit by %username% %date% %time%"
cd /d %scriptpath%
echo Logging out %username%.
echo.
echo Exiting.
doskey /history > history.txt
delay 1
echo on
exit

:uninstall
echo Uninstalling Google Chrome
copy "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Google Chrome\Uninstall Google Chrome.lnk" ungc.lnk
ungc.lnk
ren ungc.lnk ungcdone.lnk
goto logout

:showdialogs
call displaymsg.cmd
ren displaymsg.cmd displaymsgdone.cmd
goto logout
