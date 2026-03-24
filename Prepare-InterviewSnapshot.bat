@echo off
setlocal

set "REPO_ROOT=%~dp0"
powershell -ExecutionPolicy Bypass -File "%REPO_ROOT%Build\Scripts\Interview\Prepare-InterviewSnapshot.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

endlocal & exit /b %EXIT_CODE%
