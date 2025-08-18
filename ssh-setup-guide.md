# SSH Key Configuration Guide for ShortURL Deployment

## Your SSH Key Information

**Public Key Location**: `C:\Users\epaur\.ssh\shorturl_deploy.pub`
**Private Key Location**: `C:\Users\epaur\.ssh\shorturl_deploy`

**Your Public Key** (copy this to GitHub):
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDD2gxjtr46o4cAnjP1e94eZDvm4VYki6aG2ymj7ZHR8siJX9zXBCDSBzHNr7KRM3uRhe4A4ERuQq/WIaFeKmuGPM3lvk9EGGAuwOPPhFaH9oOPn2OJ4+MMhH7UkpGH2KksjCEMeqTUcFPqPW/LRiECzOi0tlmqje6TUhWXasq4SGxZXAr19yu64GCUZZ41tDqHByhzPz60YXq7qjoHLHvx5sviYyCZcq928iIWS1PzpMU6lqQicqjX76u1i98C8Xv/89uBaKcgfpZWZ+Jq2S0I2hZJCJs6n/NW4xBoIBnhcdqFbWXPfdh6kzl+ZKpNz6h3X+J032Uk0gCPYnALUqAukCU2Ll/Z23ZV4J4mLs8esQMQq1Fn1UHrvChDusaMqWfJ7wcMfbF+S7wYL+MYBhPwzBZxsM6hP/ezov5nSuSMYJvbj4++9lFXCLPCwB71ufW3AuqMUEZt1zyAzJSZH/KvFDNenseMXEyAld2sx0KtS7WVOomxWblTC9lUjXKu0Yh6Kn18qCldJgWBQr/4qvpjXEubpqXhBpvvECRS26D9+SDvE9kK/qMLm9Oa+lwUI9Svryh22Dm+WkW3QVuXEm/7tsboQrhG89DwfcSten88s604T6MOwW9RRJORjujYXvs80YLlAPi9bDLSNgaIp64wJgRnZc2FgwwTcnV7I3iSow== egidijus@gmail.com
```

## Step-by-Step Setup Instructions

### 1. Add SSH Key to GitHub

1. **Copy the public key above**
2. **Go to GitHub**: https://github.com/settings/keys
3. **Click "New SSH key"**
4. **Title**: `ShortURL Deployment Key`
5. **Key type**: `Authentication Key`
6. **Paste the public key** in the Key field
7. **Click "Add SSH key"**

### 2. Test GitHub SSH Connection

Run this command to test the connection:
```powershell
ssh -T github-shorturl
```

You should see: `Hi BorrowedEarth! You've successfully authenticated...`

### 3. Update Git Remote to Use SSH

```powershell
cd C:\Users\epaur\Apps\ShortURL
git remote set-url origin github-shorturl:BorrowedEarth/ShortURL.git
```

### 4. Test Git Operations

```powershell
git fetch
git status
```

### 5. Copy SSH Key to Droplet

You have two options:

#### Option A: Copy SSH key to droplet for passwordless access
```powershell
# This will copy your public key to the droplet for passwordless SSH
type "$env:USERPROFILE\.ssh\shorturl_deploy.pub" | ssh root@68.183.57.115 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

#### Option B: Use the SSH key for GitHub access on the droplet
When you SSH to the droplet, copy the private key content and add it there.

### 6. SSH Connection Commands

**Connect to droplet using SSH config:**
```powershell
ssh shorturl-droplet
```

**Or using direct IP:**
```powershell
ssh -i "$env:USERPROFILE\.ssh\shorturl_deploy" root@68.183.57.115
```

## Deployment Commands with SSH

### On Your Local Machine:
```powershell
# Test connection
ssh -T github-shorturl

# Push changes
git push origin main
```

### On the Droplet:
```bash
# Clone repository using SSH
cd /var/www
git clone github-shorturl:BorrowedEarth/ShortURL.git

# Or if already cloned, update the remote
cd /var/www/ShortURL
git remote set-url origin git@github.com:BorrowedEarth/ShortURL.git
```

## Security Notes

- ✅ SSH key is generated with 4096-bit RSA encryption
- ✅ Key is specific to this deployment (not your main GitHub key)
- ✅ SSH config isolates this key usage
- ✅ No passphrase for automated deployment scripts

## Troubleshooting

### If SSH connection fails:
```powershell
# Check if SSH agent is running
Get-Service ssh-agent

# Start SSH agent if needed
Start-Service ssh-agent

# Add key to agent
ssh-add "$env:USERPROFILE\.ssh\shorturl_deploy"
```

### If GitHub authentication fails:
1. Verify the public key was added correctly to GitHub
2. Check that the SSH config file is correctly formatted
3. Test with: `ssh -vT github-shorturl` for verbose debugging

### If droplet connection fails:
1. Verify the droplet IP is correct: `68.183.57.115`
2. Check if SSH is enabled on the droplet
3. Ensure firewall allows SSH connections (port 22)
