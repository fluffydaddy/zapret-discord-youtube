@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
:: 65001 - UTF-8

call "%~dp0config.bat"

set DISCORD_STRATEGY=--dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-discord=0x00 --dpi-desync-fake-stun=0x00
set QUIC_STRATEGY=--dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%FAKE_QUIC%"
set UDP_STRATEGY=--dpi-desync=fake --dpi-desync-ttl=8 --dpi-desync-repeats=20 --dpi-desync-any-protocol=1 --dpi-desync-fooling=none --dpi-desync-fake-unknown-udp="%FAKE_UDP%" --dpi-desync-cutoff=n10
set SYNDATA_STRATEGY=--dpi-desync=syndata --dpi-desync-fooling=badseq,hopbyhop2 --dpi-desync-fake-tls="%FAKE_TLS%" --dpi-desync-cutoff=n4
set HTTP_STRATEGY=--dpi-desync=fake,fakedsplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-http="%FAKE_HTTP%"
set HTTPS_STRATEGY=--dpi-desync=fake,multidisorder --dpi-desync-split-pos=1,midsld --dpi-desync-repeats=11 --dpi-desync-autottl=5 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls-mod=rnd,dupsid,sni=www.google.com

set ARGUMENTS=--wf-tcp=80,443,444-65535 --wf-udp=443,50000-50100,444-65535

set ARGUMENTS=!ARGUMENTS! --filter-udp=50000-50100 --filter-l7=discord,stun %DISCORD_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=443 --filter-l7=tls --ipset-ip=162.159.36.1,162.159.46.1,2606:4700:4700::1111,2606:4700:4700::1001 %HTTPS_STRATEGY% --new

set ARGUMENTS=!ARGUMENTS! --filter-udp=443 --hostlist-exclude="%ZAPRET_HOSTS_EXCLUDE%" --hostlist="%ZAPRET_HOSTS_USER%" --hostlist="%ZAPRET_HOSTS%" --hostlist="%ZAPRET_HOSTS_AUTO%" %QUIC_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=80 --hostlist-exclude="%ZAPRET_HOSTS_EXCLUDE%" --hostlist="%ZAPRET_HOSTS_USER%" --hostlist="%ZAPRET_HOSTS%" --hostlist-auto="%ZAPRET_HOSTS_AUTO%" %HTTP_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=443 --hostlist-exclude="%ZAPRET_HOSTS_EXCLUDE%" --hostlist="%ZAPRET_HOSTS_USER%" --hostlist="%ZAPRET_HOSTS%" --hostlist-auto="%ZAPRET_HOSTS_AUTO%" %HTTPS_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=444-65535 --hostlist-exclude="%ZAPRET_HOSTS_EXCLUDE%" --hostlist="%ZAPRET_HOSTS_USER%" --hostlist="%ZAPRET_HOSTS%" --hostlist-auto="%ZAPRET_HOSTS_AUTO%" %SYNDATA_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-udp=444-65535 --hostlist-exclude="%ZAPRET_HOSTS_EXCLUDE%" --hostlist="%ZAPRET_HOSTS_USER%" --hostlist="%ZAPRET_HOSTS%" --hostlist="%ZAPRET_HOSTS_AUTO%" %UDP_STRATEGY% --new

set ARGUMENTS=!ARGUMENTS! --filter-udp=443 --ipset="%ZAPRET_IPSET_USER%" --ipset="%ZAPRET_IPSET%" %QUIC_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=80 --ipset="%ZAPRET_IPSET_USER%" --ipset="%ZAPRET_IPSET%" %HTTP_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=443 --ipset="%ZAPRET_IPSET_USER%" --ipset="%ZAPRET_IPSET%" %HTTPS_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-tcp=444-65535 --ipset="%ZAPRET_IPSET_USER%" --ipset="%ZAPRET_IPSET%" %SYNDATA_STRATEGY% --new
set ARGUMENTS=!ARGUMENTS! --filter-udp=444-65535 --ipset="%ZAPRET_IPSET_USER%" --ipset="%ZAPRET_IPSET%" %UDP_STRATEGY%

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

call "%FUNCTIONS_SCRIPT%" combine

:: External commands
set "WHAT=%~1"
shift

if "%WHAT%"=="install" (
	goto :install
) else (
	goto :main
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

call :combine

start "zapret: %~n0" /min "%ZAPRET_BIN%winws.exe" %ARGUMENTS%

goto :eof


:install
rem The arguments passed to the program calling this instance.

call "%FUNCTIONS_SCRIPT%" escape !ARGUMENTS! ARG_ESCAPED

sc create "%SERVICE_NAME%" binPath= "\"%ZAPRET_BIN%winws.exe\" %ARG_ESCAPED%" start= "%SERVICE_BOOT_FLAG%"

goto :eof

