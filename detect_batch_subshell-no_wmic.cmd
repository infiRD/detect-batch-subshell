:: Script used to detect whether it is running in a cmd subshell
:: Does not use wmic, but depends on powershell

@echo off
setlocal EnableDelayedExpansion

REM Dequote path to command processor and this script path
set ScriptPath=%~0
set CmdPath=%COMSPEC:"=%

REM Get command processor filename and filename with extension
for %%c in (!CmdPath!) do (
    set CmdExeName=%%~nxc
    set CmdName=%%~nc
)

set IsCmdParent=0
set IsExternal=0
set "ps=$id=$PID; 1..2 | ForEach-Object { $id=(Get-WmiObject Win32_Process -Filter ('ProcessId='+$id)).ParentProcessId }; (Get-WmiObject Win32_Process -Filter ('ProcessId='+$id)).CommandLine.Trim()"

for /f "tokens=1,2,*" %%j in (
    'powershell -NoProfile -NonInteractive -Command "!ps!"'
) do (
    set ParentPath=%%j
    set ParentPath=!ParentPath:"=!
    set ParentScriptPath=%%l
    set ParentScriptPath=!ParentScriptPath:"=!

    REM Handle different invocations: C:\Windows\system32\cmd.exe, cmd.exe, cmd
    for %%p in (!CmdPath! !CmdExeName! !CmdName!) do (
		if /i !ParentPath!==%%p set IsCmdParent=1
    )

    REM Check if we're running in cmd.exe with /c switch and this script path as argument
	if !IsCmdParent!==1 if /i %%k==/c if /i "!ParentScriptPath!"=="%ScriptPath%" set IsExternal=1
)

if !IsExternal!==1 (
    echo %~nx0 only works if run directly from !CmdExeName!^^!
    exit 1
) else (
    echo Running interactively in !CmdExeName! session.
)
