@echo off
echo Starting services required for MS SQL
net start MSSQLSERVER
net start SQLWriter
net start ReportServer
@echo on