@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "REPO_ROOT=%~dp0"
set "PAUSE_ON_EXIT=%INTERVIEW_EVAL_PAUSE%"
set "SCRIPT_PATH=%REPO_ROOT%Build\Scripts\Interview\Evaluate-CandidateSnapshot.ps1"
set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "PS_ARGS=%*"
set "INTERACTIVE_MODE=0"
for /f %%E in ('echo prompt $E^| cmd') do set "ESC=%%E"
set "COLOR_HINT=%ESC%[90m"
set "COLOR_RESET=%ESC%[0m"

if "%~1"=="" (
	set "INTERACTIVE_MODE=1"
	call :PromptForArguments
	if errorlevel 1 (
		set "EXIT_CODE=1"
		goto :finish
	)
)

echo.
echo ==========================================
echo Running candidate evaluation
echo ==========================================
echo !COLOR_HINT!PowerShell arguments: !PS_ARGS!!COLOR_RESET!
echo.
%PS_EXE% -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" !PS_ARGS!
set "EXIT_CODE=%ERRORLEVEL%"
goto :finish

:PromptForArguments
echo Evaluate Candidate Snapshot
echo ===========================
echo.
echo 1. Evaluate a snapshot folder
echo !COLOR_HINT!   Check which regressions a candidate fixed in their exported snapshot.!COLOR_RESET!
echo 2. Evaluate this project folder
echo !COLOR_HINT!   Run the checks against the current project directory (useful for testing).!COLOR_RESET!
echo 3. Show help
echo !COLOR_HINT!   Display command-line usage and examples.!COLOR_RESET!
echo 4. Cancel
echo !COLOR_HINT!   Exit without running any evaluation.!COLOR_RESET!
echo.
set /p "MODE=Choose an option [1-4]: "

if "%MODE%"=="1" goto :PromptSnapshotPath
if "%MODE%"=="2" (
	set "PS_ARGS=-SnapshotPath ""%REPO_ROOT%."""
	exit /b 0
)
if "%MODE%"=="3" (
	call :ShowHelp
	goto :PromptForArguments
)
if "%MODE%"=="4" (
	echo Cancelled.
	exit /b 1
)

echo Invalid option.
echo.
goto :PromptForArguments

:PromptSnapshotPath
echo.
echo !COLOR_HINT!  Enter the full path to the candidate's snapshot folder.!COLOR_RESET!
set /p "SNAPSHOT_PATH=Snapshot path: "
if "%SNAPSHOT_PATH%"=="" (
	echo Path is required.
	echo.
	goto :PromptSnapshotPath
)
set "PS_ARGS=-SnapshotPath ""%SNAPSHOT_PATH%"""
exit /b 0

:ShowHelp
echo.
%PS_EXE% -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" -Help
echo.
echo Press any key to return to the menu...
pause >nul
echo.
exit /b 0

:finish
if not "%EXIT_CODE%"=="0" (
	echo.
	echo Evaluation failed with exit code %EXIT_CODE%.
	echo Press any key to close this window...
	pause >nul
) else if "%INTERACTIVE_MODE%"=="1" (
	echo.
	echo Evaluation completed.
	echo Press any key to close this window...
	pause >nul
) else if /I "%PAUSE_ON_EXIT%"=="1" (
	echo.
	echo Evaluation completed successfully.
	echo Press any key to close this window...
	pause >nul
)

endlocal & exit /b %EXIT_CODE%
