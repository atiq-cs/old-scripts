@echo off
taskkill /im "wmplayer.exe" /f
net stop wmpnetworksvc
echo on