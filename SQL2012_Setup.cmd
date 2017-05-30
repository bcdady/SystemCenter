::  #################ABOUT#########################
:ABOUT
@ECHO OFF
REM SET scriptname=SQL_Setup.cmd
::  Comments: Run SQL Setup, passing input Configuration File
::  Created by Bryan Dady
::  bryan@dady.us
::  Last Modified - 07/12/2012
REM SET scriptver=Version 1.0
::  History: Script created from template
::
::  #################HEADER#########################
:HEADER
REM @Echo %scriptname%
@Echo Starting %0 %date% %time%
REM @Echo %scriptver%
::  #################MAIN#########################
:MAIN
@echo.
REM Expect configuration file passed as first argument to this cmd script

REM Install SQL Server 2012 from the Command Prompt.
REM http://msdn.microsoft.com/en-us/library/ms144259.aspx

SQLFULL_x64_ENU\Setup.exe /QS /IACCEPTSQLSERVERLICENSETERMS /ACTION=Install /INDICATEPROGRESS /ConfigurationFile=%1
ECHO ErrorLevel: %errorlevel%
:END
@Echo Ending %0 %date% %time%
