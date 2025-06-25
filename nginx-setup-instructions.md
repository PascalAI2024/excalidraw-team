# Nginx Configuration Setup for excalidraw.parlaymojo.com

## Current Status

1. **Application Status**: 
   - Vite dev server is running on port 5173
   - PM2 is managing an excalidraw-frontend process (but no build directory exists)
   - The domain excalidraw.parlaymojo.com returns 404

2. **Configuration File**: 
   - A proper nginx configuration exists at `/home/pascal/dev/excalidraw/deploy/nginx.conf`
   - This config expects files to be served from `/var/www/excalidraw.parlaymojo.com/build`
   - The config includes SSL setup with Let's Encrypt

## Required Steps

### Option 1: Production Build Setup (Recommended)

1. **Build the application**:
   ```bash
   cd /home/pascal/dev/excalidraw
   yarn build
   ```

2. **Create the deployment directory** (requires sudo):
   ```bash
   sudo mkdir -p /var/www/excalidraw.parlaymojo.com
   sudo chown -R pascal:pascal /var/www/excalidraw.parlaymojo.com
   ```

3. **Copy the built files**:
   ```bash
   cp -r excalidraw-app/build /var/www/excalidraw.parlaymojo.com/
   ```

4. **Set up SSL certificates** (requires sudo):
   ```bash
   sudo certbot --nginx -d excalidraw.parlaymojo.com
   ```

5. **Deploy the nginx configuration** (requires sudo):
   ```bash
   sudo cp /home/pascal/dev/excalidraw/deploy/nginx.conf /etc/nginx/sites-available/excalidraw.parlaymojo.com
   sudo ln -s /etc/nginx/sites-available/excalidraw.parlaymojo.com /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

### Option 2: Development Proxy Setup (Quick Setup)

If you want to quickly set up a reverse proxy to the development server:

1. **Create a simple nginx config** at `/home/pascal/dev/excalidraw/nginx-dev-proxy.conf`:
   ```nginx
   server {
       listen 80;
       server_name excalidraw.parlaymojo.com;

       location / {
           proxy_pass http://localhost:5173;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }

       # API proxy if needed
       location /api {
           proxy_pass http://localhost:3001;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

2. **Deploy this configuration** (requires sudo):
   ```bash
   sudo cp nginx-dev-proxy.conf /etc/nginx/sites-available/excalidraw.parlaymojo.com
   sudo ln -s /etc/nginx/sites-available/excalidraw.parlaymojo.com /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

### Option 3: Use PM2 with Built Files

Since PM2 is already set up, you can:

1. **Build the application**:
   ```bash
   cd /home/pascal/dev/excalidraw
   yarn build
   ```

2. **Update PM2 to serve the built files**:
   ```bash
   pm2 delete excalidraw-frontend
   pm2 serve excalidraw-app/build 80 --name excalidraw-frontend --spa
   pm2 save
   ```

## Checking Current Nginx Setup

To understand how nginx is currently configured on this system:

1. **Find nginx configuration** (requires sudo):
   ```bash
   sudo find /etc -name "nginx.conf" 2>/dev/null
   sudo ls -la /etc/nginx/sites-enabled/
   ```

2. **Check which configuration is handling the domain**:
   ```bash
   sudo grep -r "excalidraw.parlaymojo.com" /etc/nginx/
   ```

## DNS Verification

Ensure the domain is pointing to this server:
```bash
dig excalidraw.parlaymojo.com +short
# Should return: 92.118.56.108
```

## Next Steps

1. First, verify DNS is correctly configured
2. Choose one of the options above based on your needs:
   - Option 1 for production setup
   - Option 2 for quick development access
   - Option 3 if you want to use PM2 for serving
3. Execute the commands with sudo access