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
    },
    error_file: '/var/log/pm2/shorturl-error.log',
    out_file: '/var/log/pm2/shorturl-out.log',
    log_file: '/var/log/pm2/shorturl.log',
    time: true
  }]
};
