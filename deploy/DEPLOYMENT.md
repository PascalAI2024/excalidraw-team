# Deployment Guide for excalidraw.parlaymojo.com

This guide explains how to set up automatic deployment for the Excalidraw Team application.

## 🚀 Quick Start

### 1. Server Setup (One-time)

SSH into your server and run:

```bash
wget https://raw.githubusercontent.com/PascalAI2024/excalidraw-team/main/deploy/setup-server.sh
chmod +x setup-server.sh
./setup-server.sh
```

### 2. Configure Nginx

```bash
# Copy nginx configuration
sudo cp /var/www/excalidraw.parlaymojo.com/deploy/nginx.conf /etc/nginx/sites-available/excalidraw.parlaymojo.com
sudo ln -s /etc/nginx/sites-available/excalidraw.parlaymojo.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3. Set up SSL with Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d excalidraw.parlaymojo.com
```

### 4. Configure GitHub Secrets

In your GitHub repository settings, add these secrets:

- `DEPLOY_HOST`: Your server IP or hostname
- `DEPLOY_USER`: SSH username
- `DEPLOY_KEY`: SSH private key (contents of ~/.ssh/id_rsa)
- `DEPLOY_PORT`: SSH port (usually 22)

### 5. Update Environment Variables

On the server, edit `/var/www/excalidraw.parlaymojo.com/.env.local`:

```bash
VITE_CLERK_PUBLISHABLE_KEY=your_actual_clerk_key
CLERK_SECRET_KEY=your_actual_clerk_secret
```

## 🔄 Auto-Deployment

Once configured, the app will automatically deploy when you push to the `main` branch.

### Manual Deployment

From your local machine:

```bash
cd deploy
chmod +x deploy.sh
# Edit deploy.sh with your server details
./deploy.sh
```

## 📊 Monitoring

### View logs:

```bash
# Backend logs
pm2 logs excalidraw-backend

# Frontend logs
pm2 logs excalidraw-frontend

# All logs
pm2 logs
```

### Check status:

```bash
pm2 status
pm2 monit
```

### Restart services:

```bash
pm2 restart all
# or
pm2 restart excalidraw-backend
pm2 restart excalidraw-frontend
```

## 🛠️ Troubleshooting

### Database Connection Issues

```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Test connection
psql -U devuser -d excalidraw_db -h localhost
```

### Build Failures

```bash
# Clear cache and rebuild
cd /var/www/excalidraw.parlaymojo.com
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
npm run build
```

### Nginx Issues

```bash
# Test configuration
sudo nginx -t

# Check error logs
sudo tail -f /var/log/nginx/error.log
```

### PM2 Issues

```bash
# Reset PM2
pm2 kill
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## 🔐 Security Checklist

- [ ] SSL certificate installed and auto-renewing
- [ ] Firewall configured (only ports 22, 80, 443 open)
- [ ] PostgreSQL secured (only localhost connections)
- [ ] Environment variables properly set
- [ ] Regular backups configured

## 📝 Backup Strategy

Create a backup script at `/home/user/backup-excalidraw.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/home/user/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup database
pg_dump -U devuser excalidraw_db > $BACKUP_DIR/excalidraw_db_$DATE.sql

# Backup uploads/files if any
tar -czf $BACKUP_DIR/excalidraw_files_$DATE.tar.gz /var/www/excalidraw.parlaymojo.com/uploads

# Keep only last 7 days of backups
find $BACKUP_DIR -name "excalidraw_*" -mtime +7 -delete
```

Add to crontab:
```bash
0 2 * * * /home/user/backup-excalidraw.sh
```