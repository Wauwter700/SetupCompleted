SET LOCATION=%cd%
PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -File ""%LOCATION%\Win10AfterSetup.ps1""' -Verb RunAs}";