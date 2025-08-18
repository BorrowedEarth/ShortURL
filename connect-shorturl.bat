@echo off
REM ShortURL SSH Connection Script
REM No password required - uses SSH key authentication

echo 🌐 Connecting to ShortURL Droplet...
echo Using SSH key authentication (no password needed)
echo.

REM Check if SSH key exists
if not exist "%USERPROFILE%\.ssh\shorturl_deploy" (
    echo ❌ SSH key not found at %USERPROFILE%\.ssh\shorturl_deploy
    echo Please make sure the SSH key is properly set up.
    pause
    exit /b 1
)

REM Connect to droplet
ssh -i "%USERPROFILE%\.ssh\shorturl_deploy" root@68.183.57.115

echo.
echo 👋 Disconnected from ShortURL Droplet
pause
