@echo off

set "SCRIPTS_DIR=%~dp0"
set "FUNCTIONS_SCRIPT=%SCRIPTS_DIR%functions.bat"

@REM if "%1"=="" (
@REM 	set ZAPRET_BASE="%~dp0"
@REM ) else (
@REM 	set ZAPRET_BASE="%1"
@REM )
set "ZAPRET_BASE=%~dp0"
set "ZAPRET_BIN=%ZAPRET_BASE%bin\"
set "ZAPRET_LISTS=%ZAPRET_BASE%lists\"
set "ZAPRET_CUSTOM=%ZAPRET_LISTS%custom\"

@REM SERVICE configuration begin
set "SERVICE_NAME=zapret"
set "SERVICE_DESCRIPTION=Zapret DPI bypass software"
set "SERVICE_DISPLAY_NAME=AntiZapret"
set "SERVICE_BOOT_FLAG=auto"
@REM end

@REM UPDATE configuration begin
@REM Set current version and URLs
set "GITHUB_VERSION_URL=https://raw.githubusercontent.com/fluffydaddy/zapret-discord-youtube/main/.service/version.txt"
set "GITHUB_RELEASE_URL=https://github.com/fluffydaddy/zapret-discord-youtube/releases/tag/"
set "GITHUB_DOWNLOAD_URL=https://github.com/fluffydaddy/zapret-discord-youtube/releases/latest/download/zapret-discord-youtube-"
@REM end

@REM begin
set "IPSET_CLOUDFLARE_FILE=%ZAPRET_CUSTOM%ipset-cloudflare.txt"
set "IPSET_CLOUDFLARE_URL=https://raw.githubusercontent.com/V3nilla/IPSets-For-Bypass-in-Russia/refs/heads/main/ipset-cloudflare.txt"

set "IPSET_AMAZON_FILE=%ZAPRET_CUSTOM%ipset-amazon.txt"
set "IPSET_AMAZON_URL=https://raw.githubusercontent.com/V3nilla/IPSets-For-Bypass-in-Russia/refs/heads/main/ipset-amazon.txt"
@REM end

@REM HOST/IPSET files begin
set "ZAPRET_IPSET=%ZAPRET_LISTS%zapret-ipset.txt"
set "ZAPRET_HOSTS=%ZAPRET_LISTS%zapret-hosts.txt"
set "ZAPRET_HOSTS_AUTO=%ZAPRET_LISTS%zapret-hosts-auto.txt"

set "ZAPRET_IPSET_USER=%ZAPRET_LISTS%zapret-ipset-user.txt"
set "ZAPRET_HOSTS_USER=%ZAPRET_LISTS%zapret-hosts-user.txt"
set "ZAPRET_HOSTS_EXCLUDE=%ZAPRET_LISTS%zapret-hosts-exclude.txt"
@REM end

@REM FAKES begin
set "FAKE_QUIC=%ZAPRET_BIN%quic_initial_google_com.bin"
set "FAKE_UDP=%ZAPRET_BIN%quic_initial_google_com.bin"
set "FAKE_HTTP=%ZAPRET_BIN%http_iana_org.bin"
set "FAKE_TLS=%ZAPRET_BIN%tls_clienthello_iana_org.bin"
@REM end
