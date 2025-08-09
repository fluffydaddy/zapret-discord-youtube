@echo off
setlocal EnableDelayedExpansion
set "LOCAL_VERSION=1.8.8"

:: External commands
if "%~1"=="status_zapret" (
	call :test_service zapret soft
	exit /b
)

if "%~1"=="check_updates" (
	if not "%~2"=="soft" (
		start /b service check_updates soft
	) else (
		call :service_check_updates soft
	)
	exit /b
)

net session >nul 2>&1
if %errorlevel% neq 0 (
	echo Requesting admin rights...
	powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" %*\"' -Verb RunAs"
	exit /b
)

call "%~dp0config.bat"

:: MENU ================================
:menu
cls
set "menu_choice=null"
echo =======================
echo 1. Install Service
echo 2. Remove Services
echo 3. Check Service Status
echo 4. Run Diagnostics
echo 5. Check Updates
echo 6. Update ipset list
echo 0. Exit
set /p menu_choice=Enter choice (0-6): 

if "%menu_choice%"=="1" goto service_install
if "%menu_choice%"=="2" goto service_remove
if "%menu_choice%"=="3" goto service_status
if "%menu_choice%"=="4" goto service_diagnostics
if "%menu_choice%"=="5" goto service_check_updates
if "%menu_choice%"=="6" goto ipset_update
if "%menu_choice%"=="0" exit /b
goto menu


:: STATUS ==============================
:service_status
cls
chcp 437 > nul
for /f "tokens=2*" %%A in ('reg query "HKLM\System\CurrentControlSet\Services\%SERVICE_NAME%" /v zapret-discord-youtube 2^>nul') do echo Service strategy installed from "%%B"
call :test_service "%SERVICE_NAME%"
call :test_service "WinDivert"

tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
if !errorlevel!==0 (
	call :PrintGreen "Bypass is ACTIVE"
) else (
	call :PrintRed "Bypass NOT FOUND"
)

pause
goto menu

:test_service
set "ServiceName=%~1"
set "ServiceStatus="

for /f "tokens=3 delims=: " %%A in ('sc query "%ServiceName%" ^| findstr /i "STATE"') do set "ServiceStatus=%%A"
set "ServiceStatus=%ServiceStatus: =%"

if "%ServiceStatus%"=="RUNNING" (
	if "%~2"=="soft" (
		echo "%ServiceName%" is ALREADY RUNNING as service, use "service.bat" and choose "Remove Services" first if you want to run standalone bat.
		pause
		exit /b
	) else (
		echo "%ServiceName%" service is RUNNING.
	)
) else if not "%~2"=="soft" (
	echo "%ServiceName%" service is NOT running.
)

exit /b


:: REMOVE ==============================
:service_remove
cls
chcp 65001 > nul

net stop "%SERVICE_NAME%"
sc delete "%SERVICE_NAME%"

net stop "WinDivert"
sc delete "WinDivert"
net stop "WinDivert14"
sc delete "WinDivert14"

pause
goto menu


:: INSTALL =============================
:service_install
cls
chcp 65001 > nul

:: Main
cd /d "%~dp0"

:: Searching for .bat files in current folder, except files that start with "service"
echo Pick one of the options:
set "count=0"
for %%f in (*.bat) do (
	set "filename=%%~nxf"
	if /i not "!filename:~0,7!"=="service" if /i not "!filename:~0,17!"=="cloudflare_switch" if /i not "!filename:~0,6!"=="config" if /i not "!filename:~0,9!"=="functions" (
		set /a count+=1
		echo !count!. %%f
		set "file!count!=%%f"
	)
)

:: Choosing file
set "choice="
set /p "choice=Input file index (number): "
if "!choice!"=="" goto :eof

set "selectedFile=!file%choice%!"
if not defined selectedFile (
	echo Invalid choice, exiting...
	pause
	goto menu
)

:: Creating service
net stop %SERVICE_NAME% >nul 2>&1
sc delete %SERVICE_NAME% >nul 2>&1
call "%selectedFile%" "install"
sc config %SERVICE_NAME% DisplayName= "%SERVICE_DISPLAY_NAME%"
sc description %SERVICE_NAME% "%SERVICE_DESCRIPTION%"
sc start %SERVICE_NAME%
for %%F in ("!file%choice%!") do (
	set "filename=%%~nF"
)
reg add "HKLM\System\CurrentControlSet\Services\%SERVICE_NAME%" /v "zapret-discord-youtube" /t REG_SZ /d "!filename!" /f

pause
goto menu


:: CHECK UPDATES =======================
:service_check_updates
chcp 437 > nul
cls

:: Get the latest version from GitHub
for /f "delims=" %%A in ('powershell -command "(Invoke-WebRequest -Uri \"%GITHUB_VERSION_URL%\" -Headers @{\"Cache-Control\"=\"no-cache\"} -TimeoutSec 5).Content.Trim()" 2^>nul') do set "GITHUB_VERSION=%%A"

:: Error handling
if not defined GITHUB_VERSION (
	echo Warning: failed to fetch the latest version. Check your internet connection. This warning does not affect the operation of zapret
	pause
	if "%1"=="soft" exit 
	goto menu
)

:: Version comparison
if "%LOCAL_VERSION%"=="%GITHUB_VERSION%" (
	echo Latest version installed: %LOCAL_VERSION%
	
	if "%1"=="soft" exit 
	pause
	goto menu
) 

echo New version available: %GITHUB_VERSION%
echo Release page: %GITHUB_RELEASE_URL%%GITHUB_VERSION%

set "CHOICE="
set /p "CHOICE=Do you want to automatically download the new version? (Y/N) (default: Y) "
if "%CHOICE%"=="" set "CHOICE=Y"
if /i "%CHOICE%"=="y" set "CHOICE=Y"

if /i "%CHOICE%"=="Y" (
	echo Opening the download page...
	start "" "%GITHUB_DOWNLOAD_URL%%GITHUB_VERSION%.rar"
)


if "%1"=="soft" exit 
pause
goto menu


:: DIAGNOSTICS =========================
:service_diagnostics
chcp 437 > nul
cls

:: AdguardSvc.exe
tasklist /FI "IMAGENAME eq AdguardSvc.exe" | find /I "AdguardSvc.exe" > nul
if !errorlevel!==0 (
	call :PrintRed "[X] Adguard process found. Adguard may cause problems with Discord"
	call :PrintRed "https://github.com/Flowseal/zapret-discord-youtube/issues/417"
) else (
	call :PrintGreen "Adguard check passed"
)
echo:

:: Killer
sc query | findstr /I "Killer" > nul
if !errorlevel!==0 (
	call :PrintRed "[X] Killer services found. Killer conflicts with zapret"
	call :PrintRed "https://github.com/Flowseal/zapret-discord-youtube/issues/2512#issuecomment-2821119513"
) else (
	call :PrintGreen "Killer check passed"
)
echo:

:: Intel Connectivity Network Service
sc query | findstr /I "Intel" | findstr /I "Connectivity" | findstr /I "Network" > nul
if !errorlevel!==0 (
	call :PrintRed "[X] Intel Connectivity Network Service found. It conflicts with zapret"
	call :PrintRed "https://github.com/ValdikSS/GoodbyeDPI/issues/541#issuecomment-2661670982"
) else (
	call :PrintGreen "Intel Connectivity check passed"
)
echo:

:: Check Point
set "checkpointFound=0"
sc query | findstr /I "TracSrvWrapper" > nul
if !errorlevel!==0 (
	set "checkpointFound=1"
)

sc query | findstr /I "EPWD" > nul
if !errorlevel!==0 (
	set "checkpointFound=1"
)

if !checkpointFound!==1 (
	call :PrintRed "[X] Check Point services found. Check Point conflicts with zapret"
	call :PrintRed "Try to uninstall Check Point"
) else (
	call :PrintGreen "Check Point check passed"
)
echo:

:: SmartByte
sc query | findstr /I "SmartByte" > nul
if !errorlevel!==0 (
	call :PrintRed "[X] SmartByte services found. SmartByte conflicts with zapret"
	call :PrintRed "Try to uninstall or disable SmartByte through services.msc"
) else (
	call :PrintGreen "SmartByte check passed"
)
echo:

:: VPN
sc query | findstr /I "VPN" > nul
if !errorlevel!==0 (
	call :PrintYellow "[?] Some VPN services found. Some VPNs can conflict with zapret"
	call :PrintYellow "Make sure that all VPNs are disabled"
) else (
	call :PrintGreen "VPN check passed"
)
echo:

:: DNS
set "dnsfound=0"
for /f "skip=1 tokens=*" %%a in ('wmic nicconfig where "IPEnabled=true" get DNSServerSearchOrder /format:table') do (
	echo %%a | findstr /i "192.168." >nul
	if !errorlevel!==0 (
		set "dnsfound=1"
	)
)
if !dnsfound!==1 (
	call :PrintYellow "[?] DNS servers are probably not specified."
	call :PrintYellow "Provider's DNS servers are automatically used, which may affect zapret. It is recommended to install well-known DNS servers and setup DoH"
) else (
	call :PrintGreen "DNS check passed"
)
echo:

:: Discord cache clearing
:: Updated, added removal of PTB and Canary versions. See https://github.com/Flowseal/zapret-discord-youtube/pull/4088
set "CHOICE="
set /p "CHOICE=Do you want to clear the Discord cache? (Y/N) (default: Y)  "
if "!CHOICE!"=="" set "CHOICE=Y"
if "!CHOICE!"=="y" set "CHOICE=Y"

if /i "!CHOICE!"=="Y" (
	::  Close Discord processes (Discord.exe, DiscordPTB.exe, DiscordCanary.exe)
	for %%i in ("Discord.exe" "DiscordPTB.exe" "DiscordCanary.exe") do (
		tasklist /FI "IMAGENAME eq %%i" | findstr /I "%%i" > nul
		if !errorlevel!==0 (
			echo %%i is running, closing...
			taskkill /IM %%i /F > nul
			if !errorlevel! == 0 (
				call :PrintGreen "%%i was successfully closed"
			) else (
				call :PrintRed "Unable to close %%i"
			)
		)
	)

	set "discordCacheDir=%appdata%\discord"
	set "discordPTBCacheDir=%appdata%\discordptb"
	set "discordCanaryCacheDir=%appdata%\discordcanary"

	for %%d in ("Cache" "Code Cache" "GPUCache") do (
		set "dirPath=!discordCacheDir!\%%~d"
		if exist "!dirPath!" (
			rd /s /q "!dirPath!"
			if !errorlevel!==0 (
				call :PrintGreen "Successfully deleted !dirPath!"
			) else (
				call :PrintRed "Failed to delete !dirPath!"
			)
		) else (
			call :PrintRed "!dirPath! does not exist"
		)
	)
	
	if exist "!discordPTBCacheDir!\" (
		echo Cleaning Discord PTB cache...
		for %%d in ("Cache" "Code Cache" "GPUCache") do (
			set "dirPath=!discordPTBCacheDir!\%%~d"
			if exist "!dirPath!" (
				rd /s /q "!dirPath!"
				if !errorlevel!==0 (
					call :PrintGreen "Successfully deleted !dirPath!"
				) else (
					call :PrintRed "Failed to delete !dirPath!"
				)
			) else (
				call :PrintRed "!dirPath! does not exist"
			)
		)
	)

	if exist "!discordCanaryCacheDir!\" (
		echo Cleaning Discord Canary cache...
		for %%d in ("Cache" "Code Cache" "GPUCache") do (
			set "dirPath=!discordCanaryCacheDir!\%%~d"
			if exist "!dirPath!" (
				rd /s /q "!dirPath!"
				if !errorlevel!==0 (
					call :PrintGreen "Successfully deleted !dirPath!"
				) else (
					call :PrintRed "Failed to delete !dirPath!"
				)
			) else (
				call :PrintRed "!dirPath! does not exist"
			)
		)
	)
)
echo:

pause
goto menu


:: IPSET UPDATE =======================
:ipset_update
chcp 437 > nul
cls

echo Updating ipset-cloudflare...

call "%FUNCTIONS_SCRIPT%" download_file "%IPSET_CLOUDFLARE_URL%" "%IPSET_CLOUDFLARE_FILE%"

echo Updating ipset-amazon...

call "%FUNCTIONS_SCRIPT%" download_file "%IPSET_AMAZON_URL%" "%IPSET_AMAZON_FILE%"

echo Finished.

pause
goto menu


:: Utility functions

:PrintGreen
powershell -Command "Write-Host \"%~1\" -ForegroundColor Green"
exit /b

:PrintRed
powershell -Command "Write-Host \"%~1\" -ForegroundColor Red"
exit /b

:PrintYellow
powershell -Command "Write-Host \"%~1\" -ForegroundColor Yellow"
exit /b
