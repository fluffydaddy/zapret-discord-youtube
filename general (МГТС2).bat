@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
:: 65001 - UTF-8

:: External commands
if "%~1"=="install" (
	rem %2 - service name
	rem %3 - service start
	call :install %2 %3
	exit /b
) else (
	call :main
	exit /b
)

:configure

set BIN=%~dp0bin\
set LISTS=%~dp0lists\

set ZAPRET_CUSTOM=%LISTS%custom\

set ZAPRET_IPSET=%LISTS%zapret-ipset.txt
set ZAPRET_IPSET_USER=%LISTS%zapret-ipset-user.txt

set ZAPRET_HOSTS=%LISTS%zapret-hosts.txt
set ZAPRET_HOSTS_USER=%LISTS%zapret-hosts-user.txt
set ZAPRET_HOSTS_AUTO=%LISTS%zapret-hosts-auto.txt
set ZAPRET_HOSTS_EXCLUDE=%LISTS%zapret-hosts-exclude.txt

set FAKE_QUIC=%BIN%quic_initial_vk_com.bin
set FAKE_UDP=%BIN%quic_initial_vk_com.bin
set FAKE_HTTP=%BIN%http_iana_org.bin
set FAKE_TLS=%BIN%tls_clienthello_vk_com.bin

set DISCORD_STRATEGY=--dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=6
set QUIC_STRATEGY=--dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=6 --dpi-desync-fake-quic="%FAKE_QUIC%"
set UDP_STRATEGY=--dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%FAKE_UDP%" --dpi-desync-cutoff=n3
set HTTP_STRATEGY=--dpi-desync=fake,multisplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-http="%FAKE_HTTP%"
set HTTPS_STRATEGY=--dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls="%FAKE_TLS%"

set ARGUMENTS=--wf-tcp=80,443,1024-65535 --wf-udp=443,50000-50100,1024-65535

set ARGUMENTS=!ARGUMENTS! --filter-udp=50000-50100 --filter-l7=discord,stun %DISCORD_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=443 --filter-l7=tls --ipset-ip=162.159.36.1,162.159.46.1,2606:4700:4700::1111,2606:4700:4700::1001 %HTTPS_STRATEGY% --new

set ARGUMENTS=!ARGUMENTS! --filter-udp=443 --hostlist-exclude="%ZAPRET_HOSTS_EXCLUDE%" --hostlist="%ZAPRET_HOSTS_USER%" --hostlist="%ZAPRET_HOSTS%" --hostlist="%ZAPRET_HOSTS_AUTO%" %QUIC_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=80 --hostlist-exclude="%ZAPRET_HOSTS_EXCLUDE%" --hostlist="%ZAPRET_HOSTS_USER%" --hostlist="%ZAPRET_HOSTS%" --hostlist-auto="%ZAPRET_HOSTS_AUTO%" %HTTP_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=443,1024-65535 --hostlist-exclude="%ZAPRET_HOSTS_EXCLUDE%" --hostlist="%ZAPRET_HOSTS_USER%" --hostlist="%ZAPRET_HOSTS%" --hostlist-auto="%ZAPRET_HOSTS_AUTO%" %HTTPS_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-udp=1024-65535 --hostlist-exclude="%ZAPRET_HOSTS_EXCLUDE%" --hostlist="%ZAPRET_HOSTS_USER%" --hostlist="%ZAPRET_HOSTS%" --hostlist="%ZAPRET_HOSTS_AUTO%" %UDP_STRATEGY% --new

set ARGUMENTS=!ARGUMENTS! --filter-udp=443 --ipset="%ZAPRET_IPSET_USER%" --ipset="%ZAPRET_IPSET%" %QUIC_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=80 --ipset="%ZAPRET_IPSET_USER%" --ipset="%ZAPRET_IPSET%" %HTTP_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=443,1024-65535 --ipset="%ZAPRET_IPSET_USER%" --ipset="%ZAPRET_IPSET%" %HTTPS_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-udp=1024-65535 --ipset="%ZAPRET_IPSET_USER%" --ipset="%ZAPRET_IPSET%" %UDP_STRATEGY%

if not exist "%ZAPRET_IPSET_USER%" (
	type NUL >"%ZAPRET_IPSET_USER%"
)
if not exist "%ZAPRET_HOSTS_USER%" (
	type NUL >"%ZAPRET_HOSTS_USER%"
)
if not exist "%ZAPRET_HOSTS_AUTO%" (
	type NUL >"%ZAPRET_HOSTS_AUTO%"
)
if not exist "%ZAPRET_HOSTS_EXCLUDE%" (
	type NUL >"%ZAPRET_HOSTS_EXCLUDE%"
)

goto :eof

:combine

call "%~dp0combine.bat" "%ZAPRET_CUSTOM%" "%ZAPRET_IPSET%" "%ZAPRET_HOSTS%"

goto :eof

:main

cd /d "%~dp0"
call service.bat status_zapret
call service.bat check_updates
echo:

call :configure
call :combine

start "zapret: %~n0" /min "%BIN%winws.exe" %ARGUMENTS%

goto :eof

:install
rem The arguments passed to the program calling this instance.

call :configure
call :combine

sc create %1 binPath= "\"%BIN%winws.exe\" %ARGUMENTS%" start= %2

goto :eof
