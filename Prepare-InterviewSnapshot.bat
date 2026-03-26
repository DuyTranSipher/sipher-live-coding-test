@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "REPO_ROOT=%~dp0"
set "PAUSE_ON_EXIT=%INTERVIEW_SNAPSHOT_PAUSE%"
set "SCRIPT_PATH=%REPO_ROOT%Build\Scripts\Interview\Prepare-InterviewSnapshot.ps1"
set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "PS_ARGS=%*"
set "INTERACTIVE_MODE=0"
set "BRANCH_NAME=main"
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
echo Starting snapshot export
echo ==========================================
echo !COLOR_HINT!PowerShell arguments: !PS_ARGS!!COLOR_RESET!
echo.
%PS_EXE% -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" !PS_ARGS!
set "EXIT_CODE=%ERRORLEVEL%"
goto :finish

:PromptForArguments
echo Prepare Interview Snapshot
echo ==========================
echo.
echo Branch: %BRANCH_NAME%
echo.
echo 1. Export snapshot
echo !COLOR_HINT!   Create a candidate snapshot from the main branch.!COLOR_RESET!
echo 2. Show help
echo !COLOR_HINT!   Display command-line usage and examples, then return to this menu.!COLOR_RESET!
echo 3. Cancel
echo !COLOR_HINT!   Exit without creating or modifying any snapshot.!COLOR_RESET!
echo.
set /p "MODE=Choose an option [1-3]: "

if "%MODE%"=="1" goto :PromptExport
if "%MODE%"=="2" (
	call :ShowHelp
	goto :PromptForArguments
)
if "%MODE%"=="3" (
	echo Cancelled.
	exit /b 1
)

echo Invalid option.
echo.
goto :PromptForArguments

:PromptExport
echo.
set "PS_ARGS=-Branch ""%BRANCH_NAME%"""
call :PromptCommonOptions
exit /b 0

:PromptCommonOptions
echo.
echo Configure snapshot output:
echo !COLOR_HINT!  Leave a field empty to accept the default value shown in brackets.!COLOR_RESET!
echo.
echo !COLOR_HINT!  Hint: Parent folder where exported snapshot folders will be created.!COLOR_RESET!
set /p "OUTPUT_ROOT=Output folder [%USERPROFILE%\Documents\InterviewSnapshots]: "
if not "%OUTPUT_ROOT%"=="" (
	rem Strip trailing backslash to prevent it from escaping the closing quote in PowerShell
	if "!OUTPUT_ROOT:~-1!"=="\" set "OUTPUT_ROOT=!OUTPUT_ROOT:~0,-1!"
	set "PS_ARGS=!PS_ARGS! -OutputRoot ""%OUTPUT_ROOT%"""
)

echo !COLOR_HINT!  Hint: Optional custom folder name for this export. Leave empty to use the branch-based default.!COLOR_RESET!
set /p "SNAPSHOT_NAME=Snapshot folder name [auto]: "
if not "!SNAPSHOT_NAME!"=="" (
	set "PS_ARGS=!PS_ARGS! -SnapshotName ""!SNAPSHOT_NAME!"""
)

echo !COLOR_HINT!  Hint: Recommended yes. Allows replacing an existing snapshot folder with the same name.!COLOR_RESET!
set /p "FORCE_OVERWRITE=Replace existing output if needed? [Y/n]: "
if /I not "%FORCE_OVERWRITE%"=="n" (
	set "PS_ARGS=!PS_ARGS! -Force"
)

echo !COLOR_HINT!  Hint: Recommended yes for candidate handoff. This removes git history from the exported snapshot.!COLOR_RESET!
set /p "NO_GIT_INIT=Skip creating a fresh git repo in the snapshot? [Y/n]: "
if /I not "%NO_GIT_INIT%"=="n" (
	set "PS_ARGS=!PS_ARGS! -NoGitInit"
)

echo !COLOR_HINT!  Hint: Recommended yes if the snapshot should open directly in Rider or Visual Studio. This step may take longer.!COLOR_RESET!
set /p "GENERATE_PROJECT_FILES=Generate Unreal project files in the snapshot? [Y/n]: "
if /I not "%GENERATE_PROJECT_FILES%"=="n" (
	set "PS_ARGS=!PS_ARGS! -GenerateProjectFiles"
)

echo !COLOR_HINT!  Hint: Usually no. Keeping interview docs exposes internal setup notes and authoring material.!COLOR_RESET!
set /p "KEEP_DOCS=Keep Docs\Interview in the snapshot? [y/N]: "
if /I "%KEEP_DOCS%"=="y" (
	set "PS_ARGS=!PS_ARGS! -KeepInterviewDocs"
)

echo.
echo Running with:
echo   !PS_ARGS!
echo.
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
	echo Prepare-InterviewSnapshot failed with exit code %EXIT_CODE%.
	echo Press any key to close this window...
	pause >nul
) else if "%INTERACTIVE_MODE%"=="1" (
	echo.
	echo Prepare-InterviewSnapshot completed.
	echo Press any key to close this window...
	pause >nul
) else if /I "%PAUSE_ON_EXIT%"=="1" (
	echo.
	echo Prepare-InterviewSnapshot completed successfully.
	echo Press any key to close this window...
	pause >nul
)

endlocal & exit /b %EXIT_CODE%
