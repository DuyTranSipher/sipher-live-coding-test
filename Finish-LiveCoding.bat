@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SNAPSHOT_DIR=%~dp0"
if "%SNAPSHOT_DIR:~-1%"=="\" set "SNAPSHOT_DIR=%SNAPSHOT_DIR:~0,-1%"

for /f %%E in ('echo prompt $E^| cmd') do set "ESC=%%E"
set "COLOR_GREEN=%ESC%[32m"
set "COLOR_RED=%ESC%[31m"
set "COLOR_YELLOW=%ESC%[33m"
set "COLOR_CYAN=%ESC%[36m"
set "COLOR_HINT=%ESC%[90m"
set "COLOR_RESET=%ESC%[0m"

rem --- Rollback stage tracking ---
rem   0 = nothing done yet
rem   1 = checked out main
rem   2 = created candidate branch
rem   3 = files copied to repo
set "ROLLBACK_STAGE=0"
set "BRANCH_NAME="
set "ORIGINAL_BRANCH="

rem --- Read repo root from .snapshot-config ---
set "REPO_ROOT="
set "CONFIG_FILE=%SNAPSHOT_DIR%\.snapshot-config"
if not exist "%CONFIG_FILE%" (
	echo !COLOR_RED!ERROR: .snapshot-config not found in this folder.!COLOR_RESET!
	echo This script must be run from the interview snapshot folder.
	goto :PauseAndExit
)

for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
	if "%%A"=="REPO_ROOT" set "REPO_ROOT=%%B"
)

if "!REPO_ROOT!"=="" (
	echo !COLOR_RED!ERROR: Could not read REPO_ROOT from .snapshot-config!COLOR_RESET!
	goto :PauseAndExit
)

if not exist "!REPO_ROOT!\.git" (
	echo !COLOR_RED!ERROR: Repository not found at !REPO_ROOT!!COLOR_RESET!
	echo Make sure the interview repository is still at that path.
	goto :PauseAndExit
)

echo !COLOR_CYAN!==========================================!COLOR_RESET!
echo !COLOR_CYAN! Finish Live Coding Exercise!COLOR_RESET!
echo !COLOR_CYAN!==========================================!COLOR_RESET!
echo.
echo !COLOR_HINT!Snapshot : !SNAPSHOT_DIR!!COLOR_RESET!
echo !COLOR_HINT!Repository: !REPO_ROOT!!COLOR_RESET!
echo.

:PromptName
set "CANDIDATE_NAME="
set /p "CANDIDATE_NAME=Enter your full name (e.g. John Doe): "
if "!CANDIDATE_NAME!"=="" (
	echo !COLOR_RED!Name is required.!COLOR_RESET!
	echo.
	goto :PromptName
)

rem --- Sanitize name for branch: replace spaces with hyphens ---
set "BRANCH_SUFFIX=!CANDIDATE_NAME: =-!"
set "BRANCH_NAME=candidate/!BRANCH_SUFFIX!"

echo.

rem --- Navigate to repository ---
cd /d "!REPO_ROOT!"
if errorlevel 1 (
	echo !COLOR_RED!ERROR: Could not navigate to repository.!COLOR_RESET!
	goto :Rollback
)

rem --- Remember current branch so we can restore on failure ---
for /f "tokens=*" %%B in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "ORIGINAL_BRANCH=%%B"

rem --- Step 1: Checkout main ---
echo !COLOR_CYAN!Step 1/3: Creating branch "!BRANCH_NAME!"!COLOR_RESET!
echo.

git checkout main >nul 2>&1
if errorlevel 1 (
	echo !COLOR_RED!ERROR: Could not checkout main branch.!COLOR_RESET!
	goto :Rollback
)
set "ROLLBACK_STAGE=1"

rem --- Check if branch already exists ---
git rev-parse --verify "!BRANCH_NAME!" >nul 2>&1
if not errorlevel 1 (
	echo !COLOR_RED!ERROR: Branch "!BRANCH_NAME!" already exists.!COLOR_RESET!
	echo !COLOR_HINT!  If a previous submission failed, ask your interviewer to clean up the branch.!COLOR_RESET!
	goto :Rollback
)

git checkout -b "!BRANCH_NAME!" >nul 2>&1
if errorlevel 1 (
	echo !COLOR_RED!ERROR: Could not create branch "!BRANCH_NAME!".!COLOR_RESET!
	goto :Rollback
)
set "ROLLBACK_STAGE=2"

echo   Branch created successfully.

rem --- Step 2: Copy files ---
echo.
echo !COLOR_CYAN!Step 2/3: Copying changes from snapshot...!COLOR_RESET!
echo !COLOR_HINT!  This copies your modified files back to the repository.!COLOR_RESET!
echo.

robocopy "!SNAPSHOT_DIR!" "!REPO_ROOT!" /E /XD ".git" /XF "Finish-LiveCoding.bat" ".snapshot-config" /NFL /NDL /NJH /NJS /NC /NS /NP >nul
set "ROBO_EXIT=!ERRORLEVEL!"

rem robocopy exit codes 0-7 are success (1=files copied, 2=extras, etc.)
if !ROBO_EXIT! GTR 7 (
	echo !COLOR_RED!ERROR: File copy failed with code !ROBO_EXIT!.!COLOR_RESET!
	goto :Rollback
)
set "ROLLBACK_STAGE=3"

echo   Files copied successfully.

rem --- Step 3: Stage and commit ---
echo.
echo !COLOR_CYAN!Step 3/3: Committing your work...!COLOR_RESET!
echo.

git add -A >nul 2>&1
if errorlevel 1 (
	echo !COLOR_RED!ERROR: git add failed.!COLOR_RESET!
	goto :Rollback
)

git commit -m "Interview submission: !CANDIDATE_NAME!" >nul 2>&1
if errorlevel 1 (
	echo !COLOR_RED!ERROR: git commit failed.!COLOR_RESET!
	echo !COLOR_HINT!  Make sure git user.name and user.email are configured.!COLOR_RESET!
	goto :Rollback
)

echo   Changes committed successfully.
echo.
echo !COLOR_GREEN!==========================================!COLOR_RESET!
echo !COLOR_GREEN! Submission complete!!COLOR_RESET!
echo !COLOR_GREEN!==========================================!COLOR_RESET!
echo.
echo   Candidate : !CANDIDATE_NAME!
echo   Branch    : !BRANCH_NAME!
echo   Repository: !REPO_ROOT!
echo.
echo !COLOR_HINT!Your work has been committed. Please notify your interviewer.!COLOR_RESET!
goto :PauseAndExit

rem ============================================================
rem  ROLLBACK: undo everything in reverse order so the candidate
rem  can fix the issue and run the script again.
rem ============================================================
:Rollback
echo.
echo !COLOR_YELLOW!Rolling back changes...!COLOR_RESET!

rem Stage 3: discard copied/staged files
if !ROLLBACK_STAGE! GEQ 3 (
	echo !COLOR_HINT!  Discarding copied files...!COLOR_RESET!
	git reset --hard HEAD >nul 2>&1
	git clean -fd >nul 2>&1
)

rem Stage 2: delete the candidate branch and return to main
if !ROLLBACK_STAGE! GEQ 2 (
	echo !COLOR_HINT!  Removing branch "!BRANCH_NAME!"...!COLOR_RESET!
	git checkout main >nul 2>&1
	git branch -D "!BRANCH_NAME!" >nul 2>&1
)

rem Stage 1: return to original branch if different from main
if !ROLLBACK_STAGE! GEQ 1 (
	if defined ORIGINAL_BRANCH (
		if not "!ORIGINAL_BRANCH!"=="main" (
			echo !COLOR_HINT!  Restoring original branch "!ORIGINAL_BRANCH!"...!COLOR_RESET!
			git checkout "!ORIGINAL_BRANCH!" >nul 2>&1
		)
	)
)

echo !COLOR_YELLOW!Rollback complete. You can try again.!COLOR_RESET!

:PauseAndExit
echo.
echo Press any key to close...
pause >nul

endlocal & exit /b 1
