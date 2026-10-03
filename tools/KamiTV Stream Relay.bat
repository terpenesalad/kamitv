@echo off
REM ============================================================
REM   KamiTV Stream Relay  (multi-stream)
REM   Converts streams the browser can't play (HEVC / AC3) AND
REM   pulls streams the browser refuses (CORS / 403 / Referer),
REM   re-serving them as H.264/AAC on localhost.
REM
REM   HOW TO USE:
REM   1) Add a line per stream in "DEFINE STREAMS" (unique port).
REM   2) For fussy channels (e.g. SBS) set a REFn referer too.
REM   3) Run this file - one window opens per stream; leave open.
REM   4) In KamiTV - Settings - Custom channels, add:
REM        http://127.0.0.1:<that stream's port>/kami.ts
REM   5) Start KamiTV with its launcher (.bat), then tune in.
REM
REM   Requires ffmpeg in C:\ffmpeg\bin. If a URL has a percent
REM   sign %  type it twice  %%
REM ============================================================

if "%~1"=="RELAY" goto :worker

set "FF=C:\ffmpeg\bin\ffmpeg.exe"

REM ====================  DEFINE STREAMS  ======================
REM  URLn  = stream link        PORTn = unique port
REM  ENCn  = A CPU h264 | B Nvidia GPU | C copy video (audio-only fix)
REM  REFn  = (optional) Referer header for channels that 403, e.g. SBS

set "URL1=PASTE_STREAM_1_URL" & set "PORT1=8088" & set "ENC1=A"
set "URL2=PASTE_SBS_URL"      & set "PORT2=8089" & set "ENC2=A" & set "REF2=https://www.sbs.com.au/"
REM set "URL3=..." & set "PORT3=8090" & set "ENC3=A"

set "COUNT=2"
REM ============================================================

for /L %%i in (1,1,%COUNT%) do start "KamiTV Relay %%i" "%~f0" RELAY %%i
echo.
echo  Launched %COUNT% relay window(s).
echo  Add a Custom channel in KamiTV for each (ports above), e.g.:
echo     http://127.0.0.1:8088/kami.ts
echo     http://127.0.0.1:8089/kami.ts
echo.
echo  You can close THIS window; the relay windows keep running.
timeout /t 8 >nul
exit /b

:worker
setlocal EnableDelayedExpansion
set "IDX=%~2"
set "PORT=!PORT%IDX%!"
set "SRC=!URL%IDX%!"
set "ENC=!ENC%IDX%!"
set "REF=!REF%IDX%!"
set "UA=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
if /I "!ENC!"=="A" set "VENC=-c:v libx264 -preset veryfast -tune zerolatency -pix_fmt yuv420p"
if /I "!ENC!"=="B" set "VENC=-c:v h264_nvenc -preset p4 -tune ll"
if /I "!ENC!"=="C" set "VENC=-c:v copy"
set "OUT=-map 0:v:0? -map 0:a:0? -sn !VENC! -c:a aac -b:a 192k -ac 2 -f mpegts -listen 1 http://127.0.0.1:!PORT!/kami.ts"
title KamiTV Relay !IDX!  -  port !PORT!
echo  Relay !IDX! serving http://127.0.0.1:!PORT!/kami.ts
echo  Leave this window open. Ctrl+C to stop.
:loop
if "!REF!"=="" (
  "%FF%" -hide_banner -loglevel warning -user_agent "!UA!" -i "!SRC!" !OUT!
) else (
  "%FF%" -hide_banner -loglevel warning -user_agent "!UA!" -headers "Referer: !REF!" -i "!SRC!" !OUT!
)
echo  Viewer disconnected or stream ended - restarting in 2s...
timeout /t 2 >nul
goto loop
