# ShortURL Pre-Deployment Setup Script
# Run this on your local machine before deploying

Write-Host "🚀 ShortURL Pre-Deployment Setup" -ForegroundColor Green

# Check if we're in the correct directory
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Error: package.json not found. Please run this script from the ShortURL directory." -ForegroundColor Red
    exit 1
}

# Test local build
Write-Host "🧪 Testing local build..." -ForegroundColor Yellow
npm install
npm run build

if (-not (Test-Path "urls.data.js")) {
    Write-Host "❌ Error: urls.data.js was not generated. Check your CSV file." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Local build successful" -ForegroundColor Green

# Check git status
Write-Host "📋 Git status:" -ForegroundColor Yellow
git status --porcelain

# Commit new deployment files if needed
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "📝 Uncommitted changes detected. Do you want to commit them? (y/n)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -eq 'y' -or $response -eq 'Y') {
        git add .
        git commit -m "Add deployment configuration files"
        Write-Host "✅ Changes committed" -ForegroundColor Green
    }
}

# Push to GitHub
Write-Host "🔄 Pushing to GitHub..." -ForegroundColor Yellow
git push origin main

Write-Host "✅ Pre-deployment setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. SSH to your droplet: ssh root@68.183.57.115" -ForegroundColor White
Write-Host "2. Follow the deployment guide in deployment-guide.md" -ForegroundColor White
Write-Host "3. Your app will be available at http://eled.org" -ForegroundColor White
