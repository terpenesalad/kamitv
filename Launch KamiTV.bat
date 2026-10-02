@echo off
REM ============================================================
REM   KamiTV - WINDOWED (movable / resizable). Press f = fullscreen.
REM   Double-click the picture also toggles fullscreen.
REM   Finds kamitv.html sitting next to this file automatically.
REM ============================================================
set "PAGE=%~dp0kamitv.html"
set "CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
start "" "%CHROME%" ^
 --app="file:///%PAGE:\=/%" ^
 --user-data-dir="%TEMP%\kamitv-profile" ^
 --disable-web-security ^
 --autoplay-policy=no-user-gesture-required ^
 --window-size=1366,768
