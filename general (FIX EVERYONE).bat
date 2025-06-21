@echo off
chcp 65001 > nul
:: 65001 - UTF-8

cd /d "%~dp0"
call service.bat status_zapret
call service.bat check_updates
echo:

set "BIN=%~dp0bin\"
set "LISTS=%~dp0lists\"

start "zapret: general (FIX EVERYONE)" /min "%BIN%winws.exe" --wf-tcp=80,443,1119,61000-62000,6695-6705,8000-8020 --wf-udp=0-65535 ^
--comment Discord --filter-udp=50000-50100 --filter-l7=discord --dpi-desync=fake --dpi-desync-repeats=6 --new ^
--comment STUN --filter-udp=0-65535 --filter-l7=stun --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-stun="%BIN%stun.bin" --new ^
--comment DHT --filter-udp=0-65535 --filter-l7=dht --dpi-desync=tamper --dpi-desync-repeats=6 --dpi-desync-fake-dht="%BIN%dht_get_peers.bin" --new ^
--comment Amazon --filter-udp=0-65535 --ipset="%LISTS%ipset-amazonaws.txt" --dpi-desync=fake,split --dpi-desync-fooling=badseq --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n3 --dpi-desync-fake-unknown-udp=0x2954afd72932231e --new ^
--comment WireGuard --filter-udp=0-65535 --filter-l7=wireguard --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-any-protocol=1 --dpi-desync-cutoff=n3 --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync-fake-wireguard="%BIN%quic_initial_www_google_com.bin" --new ^
--comment WARP --filter-tcp=443 --ipset-ip=162.159.36.1,162.159.46.1,2606:4700:4700::1111,2606:4700:4700::1001 --filter-l7=tls --dpi-desync=fake --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --dpi-desync-start=n2 --dpi-desync-cutoff=n3 --dpi-desync-fooling=badseq --new ^
--comment UDP --filter-udp=443,3074-3480,4950-4955,4960-4965,4970-4975,4980-4985,4990-4995 --hostlist="%LISTS%zapret-hosts-user.txt" --hostlist="%LISTS%zapret-hosts.txt" --hostlist-exclude="%LISTS%zapret-hosts-user-exclude.txt" --hostlist="%LISTS%zapret-hosts-auto.txt" --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--comment HTTP --filter-tcp=80 --hostlist="%LISTS%zapret-hosts-user.txt" --hostlist="%LISTS%zapret-hosts.txt" --hostlist-exclude="%LISTS%zapret-hosts-user-exclude.txt" --hostlist-auto="%LISTS%zapret-hosts-auto.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-http="%BIN%http_iana_org.bin" --new ^
--comment HTTPS --filter-tcp=443 --hostlist="%LISTS%zapret-hosts-user.txt" --hostlist="%LISTS%zapret-hosts.txt" --hostlist-exclude="%LISTS%zapret-hosts-user-exclude.txt" --hostlist-auto="%LISTS%zapret-hosts-auto.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^
--comment ElectonicArts --filter-tcp=443,61000-62000 --ipset="%LISTS%ipset-elecronicarts.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^
--comment BattleNet --filter-tcp=1119,61000-62000 --ipset="%LISTS%ipset-battlenet.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^
--comment Warframe --filter-tcp=443,6695-6705 --ipset="%LISTS%ipset-warframe.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin" --new ^
--comment Cloudflare --filter-udp=443,64090-64110 --ipset="%LISTS%ipset-cloudflare.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--comment Cloudflare --filter-tcp=80,8000-8020 --ipset="%LISTS%ipset-cloudflare.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-fake-http="%BIN%http_iana_org.bin" --new ^
--comment Cloudflare --filter-tcp=443,6695-6705 --ipset="%LISTS%ipset-cloudflare.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=badseq --dpi-desync-fake-tls="%BIN%tls_clienthello_www_google_com.bin"
