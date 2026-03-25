@echo off
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"

set "UE_ROOT_ARG="
set "TEST_FILTER=Project.Functional Tests.ShooterTests"

:parse_args
if "%~1"=="" goto args_done
set "ARG=%~1"
if /I "%~1"=="-TestFilter" (
	if "%~2"=="" (
		echo Missing value for -TestFilter
		exit /b 1
	)
	set "TEST_FILTER=%~2"
	shift
	shift
	goto parse_args
)
if /I "%ARG:~0,12%"=="-TestFilter=" (
	set "TEST_FILTER=%ARG:~12%"
	shift
	goto parse_args
)
if not defined UE_ROOT_ARG (
	set "UE_ROOT_ARG=%~1"
	shift
	goto parse_args
)

echo Unknown argument: %~1
echo Usage: RunProjectAutomationTests.bat [UE_ROOT] [-TestFilter "Automation.Filter"]
exit /b 1

:args_done
call "%SCRIPT_DIR%_ResolveProjectEnv.bat" "%UE_ROOT_ARG%" || exit /b 1

if not exist "%UNREAL_EDITOR_CMD%" (
	echo Could not find "%UNREAL_EDITOR_CMD%".
	exit /b 1
)

echo Running automation filter: %TEST_FILTER%
call "%UNREAL_EDITOR_CMD%" "%UPROJECT_PATH%" -unattended -nop4 -nosplash -log -TestExit="Automation Test Queue Empty" -ExecCmds="Automation RunTests %TEST_FILTER%"
exit /b %errorlevel%
