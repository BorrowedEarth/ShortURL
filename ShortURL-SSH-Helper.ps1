# ShortURL Production SSH Helper - Updated for Current Deployment
# Provides easy management of production ShortURL application on Digital Ocean
# 
# Production Status: ✅ ACTIVE
# SSL Status: ✅ HTTP/2 + TLS 1.2/1.3
# Application: ✅ 3,626 URLs Active
# Last Updated: August 18, 2025

# Production server configuration
$PRODUCTION_IP = "68.183.57.115"
$SSH_KEY_PATH = "$env:USERPROFILE\.ssh\shorturl_deploy"
$APP_NAME = "shorturl-app"
$APP_PATH = "/root/ShortURL"

# Function to connect to production server
function Connect-ShortURLServer {
    param(
        [string]$Command = $null,
        [switch]$ShowOutput = $true
    )
    
    if (-not (Test-Path $SSH_KEY_PATH)) {
        Write-Error "❌ SSH key not found at: $SSH_KEY_PATH"
        Write-Host "Please ensure SSH key is properly configured." -ForegroundColor Red
        return
    }
    
    if ($Command) {
        if ($ShowOutput) {
            Write-Host "🔧 Executing: $Command" -ForegroundColor Cyan
        }
        ssh -i $SSH_KEY_PATH root@$PRODUCTION_IP $Command
    } else {
        Write-Host "🌐 Connecting to ShortURL production server..." -ForegroundColor Green
        ssh -i $SSH_KEY_PATH root@$PRODUCTION_IP
    }
}

# Function to check complete application health
function Get-ShortURLHealth {
    Write-Host "🏥 Checking ShortURL Production Health..." -ForegroundColor Green
    Write-Host "=====================================`n" -ForegroundColor Green
    
    # Application status
    Write-Host "📱 Application Status:" -ForegroundColor Cyan
    Connect-ShortURLServer "pm2 status $APP_NAME"
    
    Write-Host "`n🌐 Web Server Status:" -ForegroundColor Cyan
    Connect-ShortURLServer "systemctl status nginx --no-pager -l | head -10"
    
    Write-Host "`n🔒 SSL Status:" -ForegroundColor Cyan
    Connect-ShortURLServer "curl -s -k -I https://localhost/ | head -5"
    
    Write-Host "`n💾 System Resources:" -ForegroundColor Cyan
    Connect-ShortURLServer "free -h && df -h | grep -E '(Filesystem|/dev/vda)'"
    
    Write-Host "`n✅ Health Check Complete`n" -ForegroundColor Green
}

# Function to view application logs with filtering
function Get-ShortURLLogs {
    param(
        [int]$Lines = 50,
        [string]$Filter = $null
    )
    
    Write-Host "📋 Viewing ShortURL Application Logs (Last $Lines lines)..." -ForegroundColor Yellow
    
    if ($Filter) {
        Write-Host "🔍 Filtering for: $Filter" -ForegroundColor Gray
        Connect-ShortURLServer "pm2 logs $APP_NAME --lines $Lines | grep -i '$Filter'"
    } else {
        Connect-ShortURLServer "pm2 logs $APP_NAME --lines $Lines"
    }
}

# Function to restart services safely
function Restart-ShortURLServices {
    param(
        [switch]$Force = $false
    )
    
    if (-not $Force) {
        Write-Host "⚠️  This will restart the production application. Continue? (y/N): " -ForegroundColor Yellow -NoNewline
        $confirm = Read-Host
        if ($confirm -ne 'y' -and $confirm -ne 'Y') {
            Write-Host "❌ Restart cancelled." -ForegroundColor Red
            return
# Emergency functions
function Get-ShortURLEmergencyStatus {
    Write-Host "🚨 Emergency Status Check..." -ForegroundColor Red
    Connect-ShortURLServer "pm2 status && systemctl is-active nginx && curl -s -k https://localhost/healthz | head -1"
}

function Restart-ShortURLEmergency {
    Write-Host "� Emergency Restart - No Confirmation Required" -ForegroundColor Red
    Connect-ShortURLServer "pm2 restart $APP_NAME && systemctl restart nginx && sleep 3 && curl -s -k https://localhost/healthz"
}

# Initialize and show summary on script load
Show-ShortURLSummary

# Aliases for convenience
Set-Alias ssh-shorturl Connect-ShortURLServer
Set-Alias shorturl-health Get-ShortURLHealth
Set-Alias shorturl-logs Get-ShortURLLogs
Set-Alias shorturl-restart Restart-ShortURLServices
Set-Alias shorturl-ssl Test-ShortURLSSL
Set-Alias shorturl-watch Watch-ShortURLPerformance
Set-Alias shorturl-test Test-ShortURLFunctionality
Set-Alias shorturl-emergency Get-ShortURLEmergencyStatus

Write-Host "� Quick aliases available:" -ForegroundColor Cyan
Write-Host "   ssh-shorturl, shorturl-health, shorturl-logs, shorturl-restart" -ForegroundColor Gray
Write-Host "   shorturl-ssl, shorturl-watch, shorturl-test, shorturl-emergency" -ForegroundColor Gray
Write-Host "`n🔗 Test your deployment: https://68.183.57.115" -ForegroundColor Green
Write-Host "🔗 Health check: https://68.183.57.115/healthz" -ForegroundColor Green
Write-Host "🔗 URL test: https://68.183.57.115/4526`n" -ForegroundColor Green

# Display help information
function Show-ShortURLHelp {
    Write-Host @"
🌐 ShortURL Droplet Management Commands:

Basic Commands:
  Connect-ShortURLDroplet                 # Interactive SSH session
  Connect-ShortURLDroplet "command"       # Execute single command

Management Commands:
  Deploy-ShortURL                         # Deploy updates from GitHub
  Get-ShortURLStatus                      # Check application status
  Get-ShortURLLogs                        # View application logs
  Restart-ShortURLServices                # Restart PM2 and Nginx
  Test-ShortURLSSL                        # Test SSL certificate

Examples:
  Connect-ShortURLDroplet "whoami"
  Connect-ShortURLDroplet "pm2 status"
  Deploy-ShortURL
  Get-ShortURLStatus

Configuration:
  SSH Key: $env:USERPROFILE\.ssh\shorturl_deploy
  Droplet IP: 68.183.57.115
  
No password required - using SSH key authentication!
"@ -ForegroundColor White
}

# Export functions
Export-ModuleMember -Function Connect-ShortURLDroplet, Deploy-ShortURL, Get-ShortURLStatus, Get-ShortURLLogs, Restart-ShortURLServices, Test-ShortURLSSL, Show-ShortURLHelp

# Display welcome message
Write-Host "🚀 ShortURL Management Tools Loaded!" -ForegroundColor Green
Write-Host "Run 'Show-ShortURLHelp' for available commands" -ForegroundColor Cyan
Write-Host "Quick start: Connect-ShortURLDroplet" -ForegroundColor Yellow
