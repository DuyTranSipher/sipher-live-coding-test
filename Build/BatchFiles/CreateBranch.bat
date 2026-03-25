@echo off
setlocal EnableExtensions

if "%~1"=="" (
	echo Usage: CreateBranch.bat BRANCH_NAME [START_POINT]
	echo Example: CreateBranch.bat fix/reticle-state main
	exit /b 1
)

set "BRANCH_NAME=%~1"
set "START_POINT=%~2"

if not defined START_POINT set "START_POINT=HEAD"

git switch -c "%BRANCH_NAME%" "%START_POINT%"
exit /b %errorlevel%
