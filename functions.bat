@echo off

set "WHAT=%~1"
shift

if "%WHAT%"=="" (
	exit /b
) else (
	goto :%WHAT%
)

:download_file
set "url=%~1"
set "outfile=%~2"

if exist "%SystemRoot%\System32\curl.exe" (
	curl -L -o "%outfile%" "%url%"
) else (
	powershell -Command ^
		"$url = '%url%';" ^
		"$out = '%outfile%';" ^
		"$dir = Split-Path -Parent $out;" ^
		"if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null };" ^
		"$res = Invoke-WebRequest -Uri $url -TimeoutSec 10 -UseBasicParsing;" ^
		"if ($res.StatusCode -eq 200) { $res.Content | Out-File -FilePath $out -Encoding UTF8 } else { exit 1 }"
)

exit /b


:combine
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

exit /b


:escape
set "in=%~1"
set "out="
for /f "delims=" %%A in ("!in!") do (
	set "line=%%A"
	set "line=!line:"=\"!"
	set "out=!line!"
)
set "%~2=%out%"

exit /b

