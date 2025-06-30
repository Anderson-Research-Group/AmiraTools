set SESSION_ID=unknown
for /f "tokens=3-4" %%a in ('query session %username%') do @if "%%b"=="Active" set SESSION_ID=%%a
tscon %SESSION_ID% /dest:console
start "" "C:\Program Files\Amira-6.0.1\bin\arch-Win64VC10-Optimize\Amira.exe"
timeout /t 6
rundll32.exe user32.dll,LockWorkStation

