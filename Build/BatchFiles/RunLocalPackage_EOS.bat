@echo off
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"

set "UE_ROOT_ARG="
set "ARCHIVE_DIR="

if not "%~1"=="" set "UE_ROOT_ARG=%~1"
if not "%~2"=="" set "ARCHIVE_DIR=%~2"

call "%SCRIPT_DIR%_ResolveProjectEnv.bat" "%UE_ROOT_ARG%" || exit /b 1

if not defined ARCHIVE_DIR set "ARCHIVE_DIR=%PROJECT_ROOT%\Saved\Packages\Win64EOS"

echo Packaging Win64 EOS client to "%ARCHIVE_DIR%"...
call "%RUNUAT_BAT%" BuildCookRun -nop4 -project="%UPROJECT_PATH%" -cook -stage -archive -archivedirectory="%ARCHIVE_DIR%" -package -compressed -pak -prereqs -targetplatform=Win64 -build -target=LyraGameEOS -clientconfig=Development -utf8output -compile
exit /b %errorlevel%

