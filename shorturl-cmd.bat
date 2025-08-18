@echo off
REM ShortURL Quick Commands
REM Usage: shorturl-cmd.bat [command]

set SSH_KEY=%USERPROFILE%\.ssh\shorturl_deploy
set DROPLET=root@68.183.57.115

if "%1"=="" goto :show_help
if "%1"=="help" goto :show_help
if "%1"=="status" goto :status
if "%1"=="logs" goto :logs
if "%1"=="restart" goto :restart
if "%1"=="deploy" goto :deploy
if "%1"=="ssl" goto :ssl_test
if "%1"=="connect" goto :connect

echo ❌ Unknown command: %1
goto :show_help

:show_help
echo.
echo 🌐 ShortURL Droplet Quick Commands
echo.
echo Usage: shorturl-cmd.bat [command]
echo.
echo Available commands:
echo   status    - Check application status
echo   logs      - View application logs
echo   restart   - Restart services
echo   deploy    - Deploy updates from GitHub
echo   ssl       - Test SSL certificate
echo   connect   - Interactive SSH session
echo   help      - Show this help
echo.
echo Examples:
echo   shorturl-cmd.bat status
echo   shorturl-cmd.bat deploy
echo   shorturl-cmd.bat connect
echo.
goto :end

:status
echo 📊 Checking ShortURL status...
ssh -i "%SSH_KEY%" %DROPLET% "pm2 status && echo '--- Nginx Status ---' && systemctl status nginx --no-pager"
goto :end

:logs
echo 📋 Viewing ShortURL logs...
ssh -i "%SSH_KEY%" %DROPLET% "pm2 logs shorturl --lines 20"
goto :end

:restart
echo 🔄 Restarting ShortURL services...
ssh -i "%SSH_KEY%" %DROPLET% "pm2 restart shorturl && systemctl reload nginx && echo '✅ Services restarted!'"
goto :end

:deploy
echo 🚀 Deploying ShortURL updates...
ssh -i "%SSH_KEY%" %DROPLET% "cd /var/www/ShortURL && ./deploy.sh"
goto :end

:ssl_test
echo 🔒 Testing SSL certificate...
ssh -i "%SSH_KEY%" %DROPLET% "curl -k -I https://localhost/ && echo '--- SSL Test Complete ---'"
goto :end

:connect
echo 🌐 Connecting to ShortURL Droplet...
ssh -i "%SSH_KEY%" %DROPLET%
goto :end

:end
pause
