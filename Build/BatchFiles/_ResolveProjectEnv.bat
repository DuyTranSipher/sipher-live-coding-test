@echo off

for %%I in ("%~dp0..\..") do set "PROJECT_ROOT=%%~fI"
set "PROJECT_NAME=sipher_livecoding_test"
set "UPROJECT_PATH=%PROJECT_ROOT%\%PROJECT_NAME%.uproject"

if not exist "%UPROJECT_PATH%" (
	echo Could not find "%UPROJECT_PATH%".
	exit /b 1
)

if not "%~1"=="" (
	set "UE_ROOT=%~1"
)

if not defined UE_ROOT if defined UnrealEngineRoot set "UE_ROOT=%UnrealEngineRoot%"
if not defined UE_ROOT if defined UE5_ROOT set "UE_ROOT=%UE5_ROOT%"

if not defined UE_ROOT (
	echo UE_ROOT is not set.
	echo Set UE_ROOT to your Unreal Engine 5.7 install or pass it as the first script argument.
	echo Example: Build\BatchFiles\SetupProject.bat D:\UE_5.7
	exit /b 1
)

set "GENERATE_PROJECT_FILES=%UE_ROOT%\Engine\Build\BatchFiles\GenerateProjectFiles.bat"
set "BUILD_BAT=%UE_ROOT%\Engine\Build\BatchFiles\Build.bat"
set "RUNUAT_BAT=%UE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat"
set "UNREAL_EDITOR=%UE_ROOT%\Engine\Binaries\Win64\UnrealEditor.exe"
set "UNREAL_EDITOR_CMD=%UE_ROOT%\Engine\Binaries\Win64\UnrealEditor-Cmd.exe"

if not exist "%GENERATE_PROJECT_FILES%" (
	echo Invalid UE_ROOT: "%UE_ROOT%"
	echo Expected to find "%GENERATE_PROJECT_FILES%".
	exit /b 1
)

exit /b 0
