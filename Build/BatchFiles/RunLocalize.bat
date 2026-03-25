@echo off
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"

set "UE_ROOT_ARG="
if not "%~1"=="" set "UE_ROOT_ARG=%~1"

call "%SCRIPT_DIR%_ResolveProjectEnv.bat" "%UE_ROOT_ARG%" || exit /b 1

if not defined LOCALIZATION_PROVIDER (
	echo LOCALIZATION_PROVIDER is not set.
	echo Supported examples: Crowdin_Sample, XLoc_Sample, Smartling_Sample
	echo.
	echo Required environment variables depend on the provider you use.
	echo Example:
	echo   set LOCALIZATION_PROVIDER=Crowdin_Sample
	echo   set CROWDIN_PROJECT_ID=your-project-id
	echo   set CROWDIN_ACCESS_TOKEN=your-token
	echo   Build\BatchFiles\RunLocalize.bat
	exit /b 1
)

if /I "%LOCALIZATION_PROVIDER%"=="Crowdin_Sample" (
	if not defined CROWDIN_PROJECT_ID (
		echo CROWDIN_PROJECT_ID is not set.
		exit /b 1
	)
	if not defined CROWDIN_ACCESS_TOKEN (
		echo CROWDIN_ACCESS_TOKEN is not set.
		exit /b 1
	)

	call "%RUNUAT_BAT%" Localize -p4 -UEProjectDirectory="%PROJECT_ROOT%" -UEProjectName=%PROJECT_NAME% -LocalizationBranch="Main" -LocalizationProjectNames=Game -LocalizationProvider=Crowdin_Sample -ProjectId="%CROWDIN_PROJECT_ID%" -AccessToken="%CROWDIN_ACCESS_TOKEN%"
	exit /b %errorlevel%
)

if /I "%LOCALIZATION_PROVIDER%"=="XLoc_Sample" (
	if not defined XLOC_SERVER (
		echo XLOC_SERVER is not set.
		exit /b 1
	)
	if not defined XLOC_API_KEY (
		echo XLOC_API_KEY is not set.
		exit /b 1
	)
	if not defined XLOC_API_SECRET (
		echo XLOC_API_SECRET is not set.
		exit /b 1
	)
	if not defined XLOC_LOCALIZATION_ID (
		echo XLOC_LOCALIZATION_ID is not set.
		exit /b 1
	)

	call "%RUNUAT_BAT%" Localize -p4 -UEProjectDirectory="%PROJECT_ROOT%" -UEProjectName=%PROJECT_NAME% -LocalizationBranch="Main" -LocalizationProjectNames=Game -LocalizationProvider=XLoc_Sample -Server="%XLOC_SERVER%" -APIKey="%XLOC_API_KEY%" -APISecret="%XLOC_API_SECRET%" -LocalizationId="%XLOC_LOCALIZATION_ID%"
	exit /b %errorlevel%
)

if /I "%LOCALIZATION_PROVIDER%"=="Smartling_Sample" (
	if not defined SMARTLING_PROJECT_ID (
		echo SMARTLING_PROJECT_ID is not set.
		exit /b 1
	)
	if not defined SMARTLING_USER_ID (
		echo SMARTLING_USER_ID is not set.
		exit /b 1
	)
	if not defined SMARTLING_API_SECRET (
		echo SMARTLING_API_SECRET is not set.
		exit /b 1
	)

	call "%RUNUAT_BAT%" Localize -p4 -UEProjectDirectory="%PROJECT_ROOT%" -UEProjectName=%PROJECT_NAME% -LocalizationBranch="Main" -LocalizationProjectNames=Game -LocalizationProvider=Smartling_Sample -SmartlingProjectId="%SMARTLING_PROJECT_ID%" -SmartlingUserId="%SMARTLING_USER_ID%" -SmartlingAPISecret="%SMARTLING_API_SECRET%"
	exit /b %errorlevel%
)

echo Unsupported LOCALIZATION_PROVIDER value: %LOCALIZATION_PROVIDER%
exit /b 1
