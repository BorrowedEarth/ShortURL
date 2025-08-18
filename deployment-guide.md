# ShortURL Deployment Guide for Digital Ocean Droplet

## Prerequisites
- Digital Ocean Droplet with Ubuntu (IP: 68.183.57.115)
- SSH access to the droplet
- Domain name (eled.org) pointing to the droplet IP
- GitHub repository: BorrowedEarth/ShortURL

## Step 1: Connect to Your Droplet

```bash
ssh root@68.183.57.115
```

## Step 2: Initial Server Setup

### Update the system
```bash
apt update && apt upgrade -y
```

### Install Node.js (using NodeSource repository)
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs
```

### Install Nginx (reverse proxy)
```bash
apt install nginx -y
```

### Install PM2 (process manager)
```bash
npm install -g pm2
```

### Install Git
```bash
apt install git -y
```

## Step 3: Configure GitHub Access

### Option A: Using Personal Access Token (Recommended)

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (full control of private repositories)
4. Copy the generated token

### Clone the repository:
```bash
cd /var/www
git clone https://[USERNAME]:[TOKEN]@github.com/BorrowedEarth/ShortURL.git
cd ShortURL
```

### Option B: Using SSH Key (Alternative)

Generate SSH key on droplet:
```bash
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
cat ~/.ssh/id_rsa.pub
```

Add the public key to GitHub → Settings → SSH and GPG keys → New SSH key

Clone with SSH:
```bash
cd /var/www
git clone git@github.com:BorrowedEarth/ShortURL.git
cd ShortURL
```

## Step 4: Install Application Dependencies

```bash
cd /var/www/ShortURL
npm install
```

## Step 5: Generate URL Seed Data

```bash
npm run build
```

## Step 6: Configure PM2 Process Manager

Create PM2 ecosystem file:
```bash
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'shorturl',
    script: 'server.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
};
EOF
```

Start the application:
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## Step 7: Configure Nginx Reverse Proxy

Create Nginx configuration:
```bash
cat > /etc/nginx/sites-available/shorturl << 'EOF'
server {
    listen 80;
    server_name eled.org www.eled.org 68.183.57.115;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Health check endpoint
    location /healthz {
        proxy_pass http://localhost:3000/healthz;
        access_log off;
    }
    
    # Static file caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        proxy_pass http://localhost:3000;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF
```

Enable the site:
```bash
ln -s /etc/nginx/sites-available/shorturl /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx
```

## Step 8: Configure SSL Certificate (Optional but Recommended)

Install Certbot:
```bash
apt install certbot python3-certbot-nginx -y
```

Get SSL certificate:
```bash
certbot --nginx -d eled.org -d www.eled.org
```

## Step 9: Configure Firewall

```bash
ufw allow ssh
ufw allow 'Nginx Full'
ufw --force enable
```

## Step 10: Set Up Automatic Deployment

Create deployment script:
```bash
cat > /var/www/ShortURL/deploy.sh << 'EOF'
#!/bin/bash
cd /var/www/ShortURL
git pull origin main
npm ci --production
npm run build
pm2 restart shorturl
echo "Deployment completed at $(date)"
EOF

chmod +x /var/www/ShortURL/deploy.sh
```

## Step 11: Configure Domain DNS

In your domain registrar (where eled.org is managed), set up:

### A Records:
- `eled.org` → `68.183.57.115`
- `www.eled.org` → `68.183.57.115`

### Optional CNAME:
- `www` → `eled.org`

## Step 12: Testing the Deployment

1. Visit `http://eled.org` (or `http://68.183.57.115`)
2. Test a short URL: `http://eled.org/4526`
3. Check health endpoint: `http://eled.org/healthz`

## Maintenance Commands

### View application logs:
```bash
pm2 logs shorturl
```

### Restart application:
```bash
pm2 restart shorturl
```

### Update application:
```bash
cd /var/www/ShortURL
./deploy.sh
```

### Check Nginx status:
```bash
systemctl status nginx
```

### Check SSL certificate status:
```bash
certbot certificates
```

## Troubleshooting

### If URLs are not redirecting:
1. Check if `urls.data.js` was generated: `ls -la /var/www/ShortURL/urls.data.js`
2. Regenerate seed: `cd /var/www/ShortURL && npm run build`
3. Restart PM2: `pm2 restart shorturl`

### If site is not accessible:
1. Check PM2 status: `pm2 status`
2. Check Nginx status: `systemctl status nginx`
3. Check firewall: `ufw status`
4. Check DNS propagation: `dig eled.org`

### If SSL issues:
1. Check certificate: `certbot certificates`
2. Renew certificate: `certbot renew`
3. Check Nginx config: `nginx -t`

## Security Notes

1. Regularly update the server: `apt update && apt upgrade -y`
2. Monitor PM2 processes: `pm2 monit`
3. Set up log rotation for application logs
4. Consider setting up automated backups of the CSV data
5. Monitor SSL certificate expiration (Certbot auto-renewal should handle this)

## Performance Optimization

1. The application serves static files efficiently through Nginx
2. Gzip compression is enabled for text-based assets
3. Static assets are cached for 1 year
4. PM2 manages the Node.js process with auto-restart capabilities
