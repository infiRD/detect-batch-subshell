:: Script used to detect whether it is running in a cmd subshell
:: Does not use wmic, but depends on powershell
::
:: Tested on:
::   - Win7 x86/x64 with PS 2.0 and 5.1
::   - Win11 x64
::
:: Usage:
::     set DEBUG=1
::     detect_batch_subshell-no_wmic.debug.cmd

@echo off
setlocal EnableDelayedExpansion

set "dbg=rem"
if defined DEBUG set "dbg=echo"

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

!dbg! DEBUG at startup:
!dbg!         ScriptPath         = [%ScriptPath%]
!dbg!         CmdPath            = [!CmdPath!]
!dbg!         CmdExeName         = [!CmdExeName!]
!dbg!         CmdName            = [!CmdName!]

for /f "tokens=1,2,*" %%j in (
    'powershell -NoProfile -NonInteractive -Command "!ps!"'
) do (
    !dbg! DEBUG loop:
	!dbg!         j                  = [%%j]
	!dbg!         k                  = [%%k]
	!dbg!         l                  = [%%l]

    set ParentPath=%%j
    set ParentPath=!ParentPath:"=!
    set ParentScriptPath=%%l
    set ParentScriptPath=!ParentScriptPath:"=!

	!dbg! DEBUG parsed:
	!dbg!         ParentPath         = [!ParentPath!]
	!dbg!         ParentScriptPath   = [!ParentScriptPath!]

    REM Handle different invocations: C:\Windows\system32\cmd.exe, cmd.exe, cmd
    for %%p in (!CmdPath! !CmdExeName! !CmdName!) do (
        !dbg! DEBUG compare:               [!ParentPath!] ^<--^> [%%p]

		if /i !ParentPath!==%%p set IsCmdParent=1
    )

	!dbg! DEBUG cmd check:
	!dbg!         IsCmdParent        = !IsCmdParent!
    !dbg!         k                  = [%%k]
	!dbg!         script compare       [!ParentScriptPath!] vs [%ScriptPath%]

    REM Check if we're running in cmd.exe with /c switch and this script path as argument
	if !IsCmdParent!==1 if /i %%k==/c if /i "!ParentScriptPath!"=="%ScriptPath%" set IsExternal=1

	!dbg! DEBUG end of loop:
	!dbg!         IsExternal         = !IsExternal!
)

!dbg! DEBUG after loop:
!dbg!         IsCmdParent        = !IsCmdParent!
!dbg!         IsExternal         = !IsExternal!

if !IsExternal!==1 (
    echo %~nx0 only works if run directly from !CmdExeName!^^!
    exit 1
) else (
    echo Running interactively in !CmdExeName! session.
)
