#!/bin/bash

# ShortURL Deployment Script
# Usage: ./deploy.sh

set -e  # Exit on any error

echo "🚀 Starting deployment at $(date)"

# Navigate to project directory
cd /var/www/ShortURL

# Pull latest changes
echo "📥 Pulling latest changes from GitHub..."
git pull origin main

# Install/update dependencies
echo "📦 Installing dependencies..."
npm ci --production

# Generate fresh URL seed data
echo "🌱 Generating URL seed data..."
npm run build

# Restart the application
echo "🔄 Restarting application..."
pm2 restart shorturl

# Wait for application to start
sleep 3

# Check application health
echo "🔍 Checking application health..."
if curl -f http://localhost:3000/healthz > /dev/null 2>&1; then
    echo "✅ Application is healthy"
else
    echo "❌ Application health check failed"
    exit 1
fi

# Reload Nginx (in case of configuration changes)
echo "🔄 Reloading Nginx..."
nginx -t && systemctl reload nginx

echo "✅ Deployment completed successfully at $(date)"
echo "🌐 Application is running at http://eled.org"
