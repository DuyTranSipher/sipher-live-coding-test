@echo off
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"

set "UE_ROOT_ARG="
set "SKIP_LFS=0"
set "BUILD_EDITOR=0"

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="-SkipLfs" (
	set "SKIP_LFS=1"
	shift
	goto parse_args
)
if /I "%~1"=="-BuildEditor" (
	set "BUILD_EDITOR=1"
	shift
	goto parse_args
)
if not defined UE_ROOT_ARG (
	set "UE_ROOT_ARG=%~1"
	shift
	goto parse_args
)

echo Unknown argument: %~1
echo Usage: SetupProject.bat [UE_ROOT] [-SkipLfs] [-BuildEditor]
exit /b 1

:args_done
call "%SCRIPT_DIR%_ResolveProjectEnv.bat" "%UE_ROOT_ARG%" || exit /b 1

echo Project root: %PROJECT_ROOT%
echo Project file: %UPROJECT_PATH%
echo Unreal root: %UE_ROOT%

if %SKIP_LFS%==0 (
	echo Installing Git LFS hooks...
	git lfs install
	if errorlevel 1 exit /b %errorlevel%

	echo Pulling Git LFS content...
	git lfs pull
	if errorlevel 1 exit /b %errorlevel%
)

echo Generating project files...
call "%GENERATE_PROJECT_FILES%" -project="%UPROJECT_PATH%" -game
if errorlevel 1 exit /b %errorlevel%

if %BUILD_EDITOR%==1 (
	echo Building UnrealEditor target...
	call "%BUILD_BAT%" UnrealEditor Win64 Development -Project="%UPROJECT_PATH%"
	if errorlevel 1 exit /b %errorlevel%
)

echo Setup complete.
exit /b 0
