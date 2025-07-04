@echo off

set "ZAPRET_CUSTOM=%1"

set "ZAPRET_IPSET=%2"
set "ZAPRET_HOSTS=%3"

type NUL >"%ZAPRET_HOSTS%"
for /f "delims=|" %%f in ('dir /b "%ZAPRET_CUSTOM%list-*.txt"') do (
	type %ZAPRET_CUSTOM%%%f >>"%ZAPRET_HOSTS%"
)

type NUL >"%ZAPRET_IPSET%"
for /f "delims=|" %%f in ('dir /b "%ZAPRET_CUSTOM%ipset-*.txt"') do (
	type %ZAPRET_CUSTOM%%%f >>"%ZAPRET_IPSET%"
)
