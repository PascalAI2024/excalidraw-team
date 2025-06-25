# Nginx Setup Summary for excalidraw.parlaymojo.com

## Current Situation

1. **DNS**: ✅ Correctly configured (excalidraw.parlaymojo.com → 92.118.56.108)
2. **Nginx**: ⚠️ Running but not configured for this domain (returns 404)
3. **Application**: 
   - ✅ Build exists in `excalidraw-app/build`
   - ❌ Vite dev server not running on port 5173
   - ✅ API server running on port 3001
   - ⚠️ PM2 process exists but not serving correctly

## Quick Setup Instructions

### Option 1: Production Setup (Recommended)

Run the following commands with sudo:

```bash
# 1. Run the setup script
sudo ./setup-nginx.sh
# Choose option 'b' for production build

# 2. If successful, the site should be available at:
# http://excalidraw.parlaymojo.com

# 3. For HTTPS (optional but recommended):
sudo certbot --nginx -d excalidraw.parlaymojo.com
```

### Option 2: Development Setup

If you want to run the development server:

```bash
# 1. Start the Vite dev server
cd /home/pascal/dev/excalidraw
yarn start

# 2. In another terminal, set up nginx proxy
sudo ./setup-nginx.sh
# Choose option 'a' for development proxy

# 3. Access at http://excalidraw.parlaymojo.com
```

### Option 3: Manual Nginx Setup

If the setup script doesn't work, manually configure nginx:

```bash
# 1. Copy the configuration
sudo cp /home/pascal/dev/excalidraw/deploy/nginx.conf /etc/nginx/sites-available/excalidraw.parlaymojo.com

# 2. Enable the site
sudo ln -s /etc/nginx/sites-available/excalidraw.parlaymojo.com /etc/nginx/sites-enabled/

# 3. Create deployment directory and copy files
sudo mkdir -p /var/www/excalidraw.parlaymojo.com
sudo cp -r /home/pascal/dev/excalidraw/excalidraw-app/build /var/www/excalidraw.parlaymojo.com/

# 4. Set permissions
sudo chown -R $USER:$USER /var/www/excalidraw.parlaymojo.com

# 5. Test and reload nginx
sudo nginx -t
sudo systemctl reload nginx
```

## Troubleshooting

1. **Check nginx configuration**:
   ```bash
   sudo nginx -T | grep -A 20 excalidraw.parlaymojo.com
   ```

2. **Check nginx errors**:
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

3. **Verify services**:
   ```bash
   ./diagnose-nginx.sh
   ```

4. **If nginx won't reload**:
   ```bash
   sudo systemctl status nginx
   sudo journalctl -xe
   ```

## Files Created

1. `setup-nginx.sh` - Automated setup script
2. `diagnose-nginx.sh` - Diagnostic tool
3. `nginx-dev-proxy.conf` - Development proxy configuration
4. `nginx-setup-instructions.md` - Detailed instructions

## Next Steps

1. Run `sudo ./setup-nginx.sh` and choose option 'b' for production
2. Verify the site is accessible
3. Set up HTTPS with Let's Encrypt if needed