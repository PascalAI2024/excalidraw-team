# Nginx Setup Guide for excalidraw.parlaymojo.com

The nginx configuration has been prepared and uploaded to the server at `/tmp/excalidraw.parlaymojo.com`.

## Manual Setup Steps

SSH into the server:
```bash
ssh -i ~/.ssh/excalidraw_deploy_key pascal@92.118.56.108
```

Then run these commands:

1. **Move the configuration to nginx sites-available:**
```bash
sudo mv /tmp/excalidraw.parlaymojo.com /etc/nginx/sites-available/excalidraw.parlaymojo.com
```

2. **Create a symlink to sites-enabled:**
```bash
sudo ln -sf /etc/nginx/sites-available/excalidraw.parlaymojo.com /etc/nginx/sites-enabled/
```

3. **Test the nginx configuration:**
```bash
sudo nginx -t
```

4. **If the test passes, reload nginx:**
```bash
sudo systemctl reload nginx
```

5. **Verify the site is working:**
```bash
curl -I http://excalidraw.parlaymojo.com
```

## Configuration Details

The nginx configuration will:
- Listen on port 80 for domain `excalidraw.parlaymojo.com`
- Proxy frontend requests to `http://localhost:5173` (PM2 serve)
- Proxy API requests from `/api` to `http://localhost:3001`
- Allow file uploads up to 50MB
- Set appropriate timeout values for large drawings

## Troubleshooting

If you encounter issues:

1. **Check nginx error log:**
```bash
sudo tail -f /var/log/nginx/error.log
```

2. **Check if the services are running:**
```bash
# Check if PM2 is serving on port 5173
sudo netstat -tlnp | grep 5173

# Check if API is running on port 3001
sudo netstat -tlnp | grep 3001
```

3. **Check nginx status:**
```bash
sudo systemctl status nginx
```

4. **If you need to remove the configuration:**
```bash
sudo rm /etc/nginx/sites-enabled/excalidraw.parlaymojo.com
sudo rm /etc/nginx/sites-available/excalidraw.parlaymojo.com
sudo systemctl reload nginx
```