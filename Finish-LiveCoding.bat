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

rem --- Read repo root from .snapshot-config ---
set "REPO_ROOT="
set "CONFIG_FILE=%SNAPSHOT_DIR%\.snapshot-config"
if not exist "%CONFIG_FILE%" (
	echo %COLOR_RED%ERROR: .snapshot-config not found in this folder.%COLOR_RESET%
	echo This script must be run from the interview snapshot folder.
	echo.
	echo Press any key to close...
	pause >nul
	exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
	if "%%A"=="REPO_ROOT" set "REPO_ROOT=%%B"
)

if "%REPO_ROOT%"=="" (
	echo %COLOR_RED%ERROR: Could not read REPO_ROOT from .snapshot-config%COLOR_RESET%
	echo.
	echo Press any key to close...
	pause >nul
	exit /b 1
)

if not exist "%REPO_ROOT%\.git" (
	echo %COLOR_RED%ERROR: Repository not found at %REPO_ROOT%%COLOR_RESET%
	echo Make sure the interview repository is still at that path.
	echo.
	echo Press any key to close...
	pause >nul
	exit /b 1
)

echo %COLOR_CYAN%==========================================%COLOR_RESET%
echo %COLOR_CYAN% Finish Live Coding Exercise%COLOR_RESET%
echo %COLOR_CYAN%==========================================%COLOR_RESET%
echo.
echo %COLOR_HINT%Snapshot : %SNAPSHOT_DIR%%COLOR_RESET%
echo %COLOR_HINT%Repository: %REPO_ROOT%%COLOR_RESET%
echo.

:PromptName
set "CANDIDATE_NAME="
set /p "CANDIDATE_NAME=Enter your full name (e.g. John Doe): "
if "%CANDIDATE_NAME%"=="" (
	echo %COLOR_RED%Name is required.%COLOR_RESET%
	echo.
	goto :PromptName
)

rem --- Sanitize name for branch: lowercase, replace spaces with hyphens ---
set "BRANCH_SUFFIX=%CANDIDATE_NAME: =-%"
set "BRANCH_NAME=candidate/%BRANCH_SUFFIX%"

echo.
echo %COLOR_CYAN%Step 1/3: Creating branch "%BRANCH_NAME%"%COLOR_RESET%
echo.

cd /d "%REPO_ROOT%"
if errorlevel 1 (
	echo %COLOR_RED%ERROR: Could not navigate to repository.%COLOR_RESET%
	echo.
	echo Press any key to close...
	pause >nul
	exit /b 1
)

git checkout main >nul 2>&1
if errorlevel 1 (
	echo %COLOR_RED%ERROR: Could not checkout main branch.%COLOR_RESET%
	echo.
	echo Press any key to close...
	pause >nul
	exit /b 1
)

git checkout -b "%BRANCH_NAME%" >nul 2>&1
if errorlevel 1 (
	echo %COLOR_RED%ERROR: Could not create branch "%BRANCH_NAME%". It may already exist.%COLOR_RESET%
	echo.
	echo Press any key to close...
	pause >nul
	exit /b 1
)

echo   Branch created successfully.

echo.
echo %COLOR_CYAN%Step 2/3: Copying changes from snapshot...%COLOR_RESET%
echo %COLOR_HINT%  This copies your modified files back to the repository.%COLOR_RESET%
echo.

robocopy "%SNAPSHOT_DIR%" "%REPO_ROOT%" /E /XD ".git" /XF "Finish-LiveCoding.bat" ".snapshot-config" /NFL /NDL /NJH /NJS /NC /NS /NP >nul

rem robocopy exit codes 0-7 are success (1=files copied, 2=extras, etc.)
if %ERRORLEVEL% GTR 7 (
	echo %COLOR_RED%ERROR: File copy failed with code %ERRORLEVEL%.%COLOR_RESET%
	echo.
	echo Press any key to close...
	pause >nul
	exit /b 1
)

echo   Files copied successfully.

echo.
echo %COLOR_CYAN%Step 3/3: Committing your work...%COLOR_RESET%
echo.

git add -A
if errorlevel 1 (
	echo %COLOR_RED%ERROR: git add failed.%COLOR_RESET%
	echo.
	echo Press any key to close...
	pause >nul
	exit /b 1
)

git commit -m "Interview submission: %CANDIDATE_NAME%"
if errorlevel 1 (
	echo %COLOR_RED%ERROR: git commit failed. Make sure git user.name and user.email are configured.%COLOR_RESET%
	echo.
	echo Press any key to close...
	pause >nul
	exit /b 1
)

echo.
echo %COLOR_GREEN%==========================================%COLOR_RESET%
echo %COLOR_GREEN% Submission complete!%COLOR_RESET%
echo %COLOR_GREEN%==========================================%COLOR_RESET%
echo.
echo   Candidate : %CANDIDATE_NAME%
echo   Branch    : %BRANCH_NAME%
echo   Repository: %REPO_ROOT%
echo.
echo %COLOR_HINT%Your work has been committed. Please notify your interviewer.%COLOR_RESET%
echo.
echo Press any key to close...
pause >nul

endlocal & exit /b 0
