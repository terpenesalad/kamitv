@echo off
REM ============================================================
REM   KamiTV - TV MODE (locked fullscreen kiosk). Alt+F4 to exit.
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
 --start-fullscreen ^
 --kiosk
