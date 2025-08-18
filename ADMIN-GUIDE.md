# 🔧 ShortURL Production Administration Guide

## 🎯 **Quick Reference**
- **Production URL**: https://68.183.57.115
- **Server IP**: 68.183.57.115 (Digital Ocean Ubuntu 25.04)
- **SSH Access**: `ssh -i ~/.ssh/shorturl_deploy root@68.183.57.115`
- **Status**: ✅ Production Ready with SSL

---

## 🚀 **Daily Operations**

### **Quick Health Check**
```powershell
# Windows PowerShell - Check everything at once
ssh -i "$env:USERPROFILE\.ssh\shorturl_deploy" root@68.183.57.115 "pm2 status && systemctl status nginx --no-pager && curl -s -k https://localhost/healthz"
```

### **Application Status**
```bash
# Check PM2 application status
pm2 status shorturl-app

# View real-time logs
pm2 logs shorturl-app --lines 50

# Monitor application performance
pm2 monit
```

### **Web Server Status**
```bash
# Check Nginx status
systemctl status nginx

# Test Nginx configuration
nginx -t

# Check SSL certificate status
openssl x509 -in /etc/ssl/certs/shorturl.crt -noout -dates
```

---

## ⚡ **Emergency Procedures**

### **Application Down**
```bash
# Step 1: Check PM2 status
pm2 status

# Step 2: Restart application
pm2 restart shorturl-app

# Step 3: If still down, check logs
pm2 logs shorturl-app --lines 100

# Step 4: Force restart all PM2 processes
pm2 restart all
```

### **Server Unresponsive**
```bash
# From local machine - Emergency restart
ssh -i ~/.ssh/shorturl_deploy root@68.183.57.115 "systemctl restart nginx && pm2 restart shorturl-app"

# If SSH fails - Use Digital Ocean console
# 1. Login to Digital Ocean dashboard
# 2. Access droplet console
# 3. Run: systemctl restart nginx && pm2 restart shorturl-app
```

### **SSL Issues**
```bash
# Check SSL certificate
openssl x509 -in /etc/ssl/certs/shorturl.crt -noout -text

# Test SSL connection
curl -k -I https://localhost/

# Restart Nginx if SSL problems
systemctl restart nginx
```

---

## 📊 **Monitoring Commands**

### **System Resources**
```bash
# Check CPU and memory usage
htop

# Check disk usage
df -h

# Check memory details
free -h

# Check network connections
netstat -tulpn | grep -E ':(80|443|3000)'
```

### **Application Monitoring**
```bash
# Real-time application logs
pm2 logs shorturl-app --lines 100 --timestamp

# Application performance metrics
pm2 monit

# Check application memory usage
pm2 show shorturl-app
```

### **Web Server Monitoring**
```bash
# Monitor Nginx access logs
tail -f /var/log/nginx/access.log

# Monitor Nginx error logs
tail -f /var/log/nginx/error.log

# Check active connections
nginx -s status 2>/dev/null || echo "Status not available"
```

---

## 🔒 **Security Management**

### **SSL Certificate Management**
```bash
# Current certificate info
openssl x509 -in /etc/ssl/certs/shorturl.crt -noout -subject -dates

# Check certificate chain
openssl verify /etc/ssl/certs/shorturl.crt

# Future: Let's Encrypt renewal (after DNS update)
certbot renew --dry-run
```

### **Firewall Management**
```bash
# Check firewall status
ufw status verbose

# View firewall logs
grep UFW /var/log/syslog | tail -20

# Add temporary access (if needed)
ufw allow from YOUR_IP to any port 22
```

### **SSH Security**
```bash
# Check SSH connections
who

# View SSH logs
journalctl -u ssh | tail -20

# Check SSH key authentication
ssh-keygen -l -f ~/.ssh/authorized_keys
```

---

## 🔧 **Maintenance Tasks**

### **Weekly Maintenance**
```bash
# Update system packages
apt update && apt upgrade -y

# Clean up old logs
journalctl --vacuum-time=30d

# Check disk usage
df -h

# Verify all services
systemctl status nginx
pm2 status
```

### **Monthly Maintenance**
```bash
# Security updates
apt update && apt list --upgradable

# Check for Node.js updates
node --version
npm --version

# Review application logs for errors
pm2 logs shorturl-app --lines 1000 | grep -i error

# Backup configuration files
tar -czf backup-$(date +%Y%m%d).tar.gz /etc/nginx/sites-available/ /root/ShortURL/
```

### **Performance Optimization**
```bash
# Check PM2 process clustering
pm2 show shorturl-app

# Monitor response times
curl -w "@curl-format.txt" -s -k https://localhost/ -o /dev/null

# Check memory leaks
pm2 monit
```

---

## 📈 **Performance Monitoring**

### **Response Time Testing**
```bash
# Create curl timing format file
cat > /tmp/curl-format.txt << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF

# Test response times
curl -w "@/tmp/curl-format.txt" -s -k https://localhost/ -o /dev/null
```

### **Load Testing**
```bash
# Simple load test (install apache2-utils if needed)
ab -n 100 -c 10 https://68.183.57.115/

# Monitor during load test
watch -n 1 'pm2 monit'
```

### **Database Performance**
```bash
# Check URL database size
wc -l /root/ShortURL/urls.csv

# Monitor URL redirect performance
time curl -s -k https://localhost/4526 -o /dev/null
```

---

## 🛠️ **Configuration Management**

### **Nginx Configuration**
```bash
# Current active configuration
nginx -T | grep -A 50 "server {"

# Test configuration changes
nginx -t

# Reload configuration (without downtime)
systemctl reload nginx

# Backup current configuration
cp /etc/nginx/sites-available/shorturl-fixed /root/nginx-backup-$(date +%Y%m%d).conf
```

### **PM2 Configuration**
```bash
# View current PM2 configuration
pm2 show shorturl-app

# Save current PM2 setup
pm2 save

# View ecosystem file
cat /root/ShortURL/ecosystem.config.js

# Update PM2 configuration
pm2 reload ecosystem.config.js
```

### **Application Configuration**
```bash
# Check Node.js application settings
cat /root/ShortURL/server.js | grep -E "(port|listen|env)"

# Check package.json
cat /root/ShortURL/package.json

# Verify URLs database
head -10 /root/ShortURL/urls.csv
```

---

## 🚨 **Troubleshooting Guide**

### **Common Issues**

#### **Application Not Responding**
```bash
# Diagnosis
pm2 status
pm2 logs shorturl-app --lines 50

# Solution
pm2 restart shorturl-app

# If still failing
cd /root/ShortURL && npm install && pm2 restart shorturl-app
```

#### **502 Bad Gateway Error**
```bash
# Check if application is running
pm2 status shorturl-app

# Check if port 3000 is listening
netstat -tulpn | grep :3000

# Check Nginx proxy configuration
nginx -t
grep proxy_pass /etc/nginx/sites-available/shorturl-fixed
```

#### **SSL Certificate Issues**
```bash
# Check certificate validity
openssl x509 -in /etc/ssl/certs/shorturl.crt -noout -dates

# Check private key matches certificate
openssl rsa -in /etc/ssl/private/shorturl.key -noout -modulus | md5sum
openssl x509 -in /etc/ssl/certs/shorturl.crt -noout -modulus | md5sum
# These should match

# Test SSL configuration
openssl s_client -connect localhost:443 -servername localhost
```

#### **High Memory Usage**
```bash
# Check memory usage
free -h
ps aux --sort=-%mem | head -10

# Restart PM2 if needed
pm2 restart shorturl-app

# Check for memory leaks
pm2 monit
```

---

## 📋 **Backup & Recovery**

### **Configuration Backup**
```bash
# Create comprehensive backup
mkdir -p /root/backups/$(date +%Y%m%d)
cp -r /etc/nginx/sites-available/ /root/backups/$(date +%Y%m%d)/
cp -r /root/ShortURL/ /root/backups/$(date +%Y%m%d)/
cp /etc/ssl/certs/shorturl.crt /root/backups/$(date +%Y%m%d)/
cp /etc/ssl/private/shorturl.key /root/backups/$(date +%Y%m%d)/

# Create compressed backup
tar -czf /root/shorturl-backup-$(date +%Y%m%d).tar.gz /root/backups/$(date +%Y%m%d)/
```

### **Quick Recovery**
```bash
# Restore from backup (if needed)
# Extract backup
tar -xzf /root/shorturl-backup-YYYYMMDD.tar.gz

# Restore configurations
cp backup/nginx/sites-available/* /etc/nginx/sites-available/
cp backup/shorturl/* /root/ShortURL/

# Restart services
systemctl restart nginx
cd /root/ShortURL && pm2 restart shorturl-app
```

---

## 📞 **Contact Information**

### **Emergency Escalation**
1. **Application Issues**: Check PM2 logs and restart
2. **Server Issues**: Use Digital Ocean console
3. **SSL Issues**: Check certificate validity and Nginx config
4. **Performance Issues**: Monitor with `htop` and `pm2 monit`

### **Useful Resources**
- **PM2 Documentation**: https://pm2.keymetrics.io/docs/
- **Nginx Documentation**: https://nginx.org/en/docs/
- **Digital Ocean Tutorials**: https://www.digitalocean.com/community/

---

## ✅ **Production Checklist**

### **Daily Checks**
- [ ] Application responding (curl health check)
- [ ] PM2 status shows running
- [ ] Nginx status shows active
- [ ] No critical errors in logs

### **Weekly Checks**
- [ ] System updates available
- [ ] Disk usage under 80%
- [ ] Memory usage normal
- [ ] SSL certificate valid

### **Monthly Checks**
- [ ] Security updates applied
- [ ] Log rotation working
- [ ] Backup strategy verified
- [ ] Performance metrics reviewed

---

**📋 Status: Production system is healthy and operational** ✅

*Last Updated: August 18, 2025*
