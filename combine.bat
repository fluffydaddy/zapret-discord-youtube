@echo off

cd /d "%~dp0"

if "%~1"=="" (
	set "ZAPRET_CUSTOM=%~dp0lists\custom\"
) else (
	set ZAPRET_CUSTOM="%1"
)

if "%~2"=="" (
	set "ZAPRET_IPSET=%~dp0lists\zapret-ipset.txt"
) else (
	set ZAPRET_IPSET="%2"
)

if "%~3"=="" (
	set "ZAPRET_HOSTS=%~dp0lists\zapret-hosts.txt"
) else (
	set ZAPRET_HOSTS="%3"
)

type NUL >"%ZAPRET_HOSTS%"
for /f "delims=|" %%f in ('dir /b "%ZAPRET_CUSTOM%list-*.txt"') do (
	type "%ZAPRET_CUSTOM%%%f" >>"%ZAPRET_HOSTS%"
	echo.>>"%ZAPRET_HOSTS%"
)

type NUL >"%ZAPRET_IPSET%"
for /f "delims=|" %%f in ('dir /b "%ZAPRET_CUSTOM%ipset-*.txt"') do (
	type "%ZAPRET_CUSTOM%%%f" >>"%ZAPRET_IPSET%"
	echo.>>"%ZAPRET_IPSET%"
)
