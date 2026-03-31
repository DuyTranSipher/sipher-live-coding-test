@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SNAPSHOT_DIR=%~dp0"
if "%SNAPSHOT_DIR:~-1%"=="\" set "SNAPSHOT_DIR=%SNAPSHOT_DIR:~0,-1%"

for /f %%E in ('echo prompt $E^| cmd') do set "ESC=%%E"
set "COLOR_GREEN=%ESC%[32m"
set "COLOR_RED=%ESC%[31m"
set "COLOR_CYAN=%ESC%[36m"
set "COLOR_HINT=%ESC%[90m"
set "COLOR_RESET=%ESC%[0m"

rem --- Validate snapshot folder ---
set "CONFIG_FILE=%SNAPSHOT_DIR%\.snapshot-config"
if not exist "%CONFIG_FILE%" (
	echo !COLOR_RED!ERROR: .snapshot-config not found in this folder.!COLOR_RESET!
	echo This script must be run from the interview snapshot folder.
	goto :PauseAndExit
)

rem --- Check for existing session ---
set "SESSION_FILE=%SNAPSHOT_DIR%\.session-info"
if exist "!SESSION_FILE!" (
	echo !COLOR_RED!ERROR: A session is already in progress.!COLOR_RESET!
	echo !COLOR_HINT!  Delete .session-info to start a new session, or run Finish-LiveCoding.bat to submit.!COLOR_RESET!
	goto :PauseAndExit
)

echo !COLOR_CYAN!==========================================!COLOR_RESET!
echo !COLOR_CYAN! Start Live Coding Exercise!COLOR_RESET!
echo !COLOR_CYAN!==========================================!COLOR_RESET!
echo.

:PromptName
set "CANDIDATE_NAME="
set /p "CANDIDATE_NAME=Enter your full name (e.g. John Doe): "
if "!CANDIDATE_NAME!"=="" (
	echo !COLOR_RED!Name is required.!COLOR_RESET!
	echo.
	goto :PromptName
)

rem --- Capture ISO-8601 start time (UTC) ---
for /f "tokens=*" %%T in ('powershell -NoProfile -Command "[datetime]::UtcNow.ToString(\"yyyy-MM-ddTHH:mm:ssZ\")"') do set "START_TIME=%%T"

if "!START_TIME!"=="" (
	echo !COLOR_RED!ERROR: Could not read current time.!COLOR_RESET!
	goto :PauseAndExit
)

rem --- Write .session-info ---
(
	echo CANDIDATE_NAME=!CANDIDATE_NAME!
	echo START_TIME=!START_TIME!
) > "!SESSION_FILE!"

echo.
echo !COLOR_GREEN!==========================================!COLOR_RESET!
echo !COLOR_GREEN! Session started!!COLOR_RESET!
echo !COLOR_GREEN!==========================================!COLOR_RESET!
echo.
echo   Candidate : !CANDIDATE_NAME!
echo   Started   : !START_TIME! (UTC)
echo.
echo !COLOR_HINT!Work in this folder. Run Finish-LiveCoding.bat when you are done.!COLOR_RESET!

:PauseAndExit
echo.
echo Press any key to close...
pause >nul

endlocal
