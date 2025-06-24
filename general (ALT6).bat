@echo off
chcp 65001 > nul
:: 65001 - UTF-8

cd /d "%~dp0"
call service.bat status_zapret
call service.bat check_updates
echo:

set "BIN=%~dp0bin\"
set "LISTS=%~dp0lists\"

rem 9000-9090,6600-6610,14815-14816

start "zapret: %~n0" /min "%BIN%winws.exe" --wf-tcp=80,443,1024-65535 --wf-udp=443,50000-50100,1024-65535 ^
--comment Discord --filter-udp=50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6 --new ^
--comment WARP --filter-tcp=443 --ipset-ip=162.159.36.1,162.159.46.1,2606:4700:4700::1111,2606:4700:4700::1001 --filter-l7=tls --dpi-desync=split2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq,hopbyhop2 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment QUIC --filter-udp=443 --hostlist="%LISTS%zapret-hosts-user.txt" --hostlist="%LISTS%zapret-hosts.txt" --hostlist-exclude="%LISTS%zapret-hosts-user-exclude.txt" --hostlist="%LISTS%zapret-hosts-auto.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--comment HTTP --filter-tcp=80 --hostlist="%LISTS%zapret-hosts-user.txt" --hostlist="%LISTS%zapret-hosts.txt" --hostlist-exclude="%LISTS%zapret-hosts-user-exclude.txt" --hostlist-auto="%LISTS%zapret-hosts-auto.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--comment HTTPS --filter-tcp=443 --hostlist="%LISTS%zapret-hosts-user.txt" --hostlist="%LISTS%zapret-hosts.txt" --hostlist-exclude="%LISTS%zapret-hosts-user-exclude.txt" --hostlist-auto="%LISTS%zapret-hosts-auto.txt" --dpi-desync=split2 --dpi-desync-repeats=2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq,hopbyhop2 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment Amazon --filter-udp=443 --ipset="%LISTS%ipset-amazonaws.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--comment Amazon --filter-tcp=80 --ipset="%LISTS%ipset-amazonaws.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--comment Amazon --filter-tcp=443,1024-65535 --ipset="%LISTS%ipset-amazonaws.txt" --dpi-desync=split2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq,hopbyhop2 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^
--comment Amazon --filter-udp=1024-65535 --ipset="%LISTS%ipset-amazonaws.txt" --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync-cutoff=n2 --new ^

--comment Cloudflare --filter-udp=443,64090-64110 --ipset="%LISTS%ipset-cloudflare.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--comment Cloudflare --filter-tcp=80,2099,5222-5223,8000-8020,8393-8400 --ipset="%LISTS%ipset-cloudflare.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--comment Cloudflare --filter-tcp=443,6695-6705 --ipset="%LISTS%ipset-cloudflare.txt" --dpi-desync=split2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq,hopbyhop2 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment ElectonicArts --filter-tcp=443 --ipset="%LISTS%ipset-elecronicarts.txt" --dpi-desync=split2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq,hopbyhop2 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^
--comment BattleNet --filter-tcp=1119 --ipset="%LISTS%ipset-battlenet.txt" --dpi-desync=split2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq,hopbyhop2 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment Warframe --filter-udp=3074-3480,4950-4955,4960-4965,4970-4975,4980-4985,4990-4995 --ipset="%LISTS%ipset-warframe.txt" --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%BIN%quic_initial_www_google_com.bin" --dpi-desync-cutoff=n2 --new ^
--comment Warframe --filter-tcp=6695-6705 --ipset="%LISTS%ipset-warframe.txt" --dpi-desync=split2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq,hopbyhop2 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin" --new ^

--comment Linode --filter-udp=443,1024-65535 --ipset="%LISTS%ipset-linodeusercontent.txt" --ipset="%LISTS%ipset-panicartstudios.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic="%BIN%quic_initial_www_google_com.bin" --new ^
--comment Linode --filter-tcp=80 --ipset="%LISTS%ipset-linodeusercontent.txt" --ipset="%LISTS%ipset-panicartstudios.txt" --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --new ^
--comment Linode --filter-tcp=443,1024-65535 --ipset="%LISTS%ipset-linodeusercontent.txt" --ipset="%LISTS%ipset-panicartstudios.txt" --dpi-desync=split2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq,hopbyhop2 --dpi-desync-split-seqovl-pattern="%BIN%tls_clienthello_www_google_com.bin"
