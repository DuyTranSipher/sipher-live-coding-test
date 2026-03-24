@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "REPO_ROOT=%~dp0"
set "PAUSE_ON_EXIT=%INTERVIEW_SNAPSHOT_PAUSE%"
set "SCRIPT_PATH=%REPO_ROOT%Build\Scripts\Interview\Prepare-InterviewSnapshot.ps1"
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
echo Starting snapshot export
echo ==========================================
echo !COLOR_HINT!PowerShell arguments: !PS_ARGS!!COLOR_RESET!
echo.
powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" !PS_ARGS!
set "EXIT_CODE=%ERRORLEVEL%"
goto :finish

:PromptForArguments
echo Prepare Interview Snapshot
echo ==========================
echo.
echo 1. Export one scenario branch
echo !COLOR_HINT!   Create a candidate snapshot for one selected interview case.!COLOR_RESET!
echo 2. Export all scenarios
echo !COLOR_HINT!   Create one snapshot folder for every available interview case.!COLOR_RESET!
echo 3. Show help
echo !COLOR_HINT!   Display command-line usage and examples, then return to this menu.!COLOR_RESET!
echo 4. Cancel
echo !COLOR_HINT!   Exit without creating or modifying any snapshot.!COLOR_RESET!
echo.
set /p "MODE=Choose an option [1-4]: "

if "%MODE%"=="1" goto :PromptSingleBranch
if "%MODE%"=="2" goto :PromptAllScenarios
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

:PromptSingleBranch
echo.
call :PromptScenarioSelection
if errorlevel 1 exit /b 1

set "PS_ARGS=-Branch ""%BRANCH_NAME%"""
call :PromptCommonOptions
exit /b 0

:PromptAllScenarios
echo.
set "PS_ARGS=-AllScenarios"
call :PromptCommonOptions
exit /b 0

:PromptCommonOptions
echo.
echo Configure snapshot output:
echo !COLOR_HINT!  Leave a field empty to accept the default value shown in brackets.!COLOR_RESET!
echo.
echo !COLOR_HINT!  Hint: Parent folder where exported snapshot folders will be created.!COLOR_RESET!
set /p "OUTPUT_ROOT=Output folder [.\Saved\InterviewSnapshots]: "
if not "%OUTPUT_ROOT%"=="" (
	set "PS_ARGS=!PS_ARGS! -OutputRoot ""%OUTPUT_ROOT%"""
)

if /I "%MODE%"=="1" (
	echo !COLOR_HINT!  Hint: Optional custom folder name for this one export. Leave empty to use the branch-based default.!COLOR_RESET!
	set /p "SNAPSHOT_NAME=Snapshot folder name [auto]: "
	if not "!SNAPSHOT_NAME!"=="" (
		set "PS_ARGS=!PS_ARGS! -SnapshotName ""!SNAPSHOT_NAME!"""
	)
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

:PromptScenarioSelection
set "SCENARIO_COUNT=0"
for /f "usebackq delims=" %%L in (`powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" -ListScenarios`) do (
	set /a SCENARIO_COUNT+=1
	set "SCENARIO_LINE[!SCENARIO_COUNT!]=%%L"
)

if "%SCENARIO_COUNT%"=="0" (
	echo No scenario docs were found. Enter a branch name manually.
	set /p "BRANCH_NAME=Branch name: "
	if "%BRANCH_NAME%"=="" (
		echo Branch name is required.
		exit /b 1
	)
	exit /b 0
)

echo Available scenarios:
echo !COLOR_HINT!  Pick a number to export that prepared interview case.!COLOR_RESET!
echo !COLOR_HINT!  Pick C only if you want to type a branch name manually.!COLOR_RESET!
for /L %%I in (1,1,%SCENARIO_COUNT%) do (
	for /f "tokens=1-3 delims=|" %%A in ("!SCENARIO_LINE[%%I]!") do (
		echo   %%I. %%A - %%C
		echo !COLOR_HINT!     %%B!COLOR_RESET!
	)
)
echo   C. Custom branch name
echo.
set /p "SCENARIO_CHOICE=Choose a scenario [1-%SCENARIO_COUNT% or C]: "

if /I "%SCENARIO_CHOICE%"=="C" (
	set /p "BRANCH_NAME=Branch name: "
	if "%BRANCH_NAME%"=="" (
		echo Branch name is required.
		echo.
		goto :PromptScenarioSelection
	)
	exit /b 0
)

for /f "delims=0123456789" %%A in ("%SCENARIO_CHOICE%") do set "NON_NUMERIC=%%A"
if defined NON_NUMERIC (
	set "NON_NUMERIC="
	echo Invalid selection.
	echo.
	goto :PromptScenarioSelection
)

if "%SCENARIO_CHOICE%"=="" (
	echo Invalid selection.
	echo.
	goto :PromptScenarioSelection
)

if %SCENARIO_CHOICE% LSS 1 (
	echo Invalid selection.
	echo.
	goto :PromptScenarioSelection
)

if %SCENARIO_CHOICE% GTR %SCENARIO_COUNT% (
	echo Invalid selection.
	echo.
	goto :PromptScenarioSelection
)

for /f "tokens=1-3 delims=|" %%A in ("!SCENARIO_LINE[%SCENARIO_CHOICE%]!") do (
	set "BRANCH_NAME=%%B"
)
exit /b 0

:ShowHelp
echo.
powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" -Help
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
