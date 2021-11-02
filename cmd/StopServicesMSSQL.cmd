@echo off
echo Stopping services required for MS SQL
net stop MSSQLSERVER
net stop SQLWriter
net stop ReportServer
@echo on