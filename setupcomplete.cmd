@ECHO OFF
ECHO Setupcompleted V.1.0 

SET LOCATION=%cd%
PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -File ""%LOCATION%\script.ps1""' -Verb RunAs}";