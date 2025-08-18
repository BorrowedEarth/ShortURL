# SSH Key Verification and Setup Script
# Run this AFTER adding the SSH key to GitHub

Write-Host "🔐 SSH Key Verification and Setup" -ForegroundColor Green
Write-Host ""

# Test GitHub SSH connection
Write-Host "🧪 Testing GitHub SSH connection..." -ForegroundColor Yellow
$sshTest = ssh -T github-shorturl 2>&1
if ($LASTEXITCODE -eq 1 -and $sshTest -like "*successfully authenticated*") {
    Write-Host "✅ GitHub SSH authentication successful!" -ForegroundColor Green
    
    # Update git remote to use SSH
    Write-Host "🔄 Updating git remote to use SSH..." -ForegroundColor Yellow
    git remote set-url origin github-shorturl:BorrowedEarth/ShortURL.git
    
    # Test git operations
    Write-Host "🧪 Testing git fetch..." -ForegroundColor Yellow
    git fetch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Git SSH access working!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎉 SSH setup complete! You can now:" -ForegroundColor Cyan
        Write-Host "   • Push code changes securely" -ForegroundColor White
        Write-Host "   • Deploy to your droplet using SSH" -ForegroundColor White
        Write-Host "   • Use automated deployment scripts" -ForegroundColor White
        Write-Host ""
        Write-Host "Next step: Connect to your droplet with:" -ForegroundColor Yellow
        Write-Host "   ssh shorturl-droplet" -ForegroundColor White
    } else {
        Write-Host "❌ Git fetch failed. Check your repository settings." -ForegroundColor Red
    }
} else {
    Write-Host "❌ GitHub SSH authentication failed." -ForegroundColor Red
    Write-Host "Make sure you've added the SSH key to GitHub:" -ForegroundColor Yellow
    Write-Host "https://github.com/settings/keys" -ForegroundColor White
    Write-Host ""
    Write-Host "Your public key:" -ForegroundColor Yellow
    Get-Content "$env:USERPROFILE\.ssh\shorturl_deploy.pub"
}
