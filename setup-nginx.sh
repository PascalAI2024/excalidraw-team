#!/bin/bash

# Nginx configuration for excalidraw.parlaymojo.com
cat << 'EOF' > /tmp/excalidraw.parlaymojo.com
server {
    listen 80;
    server_name excalidraw.parlaymojo.com;

    # Frontend - proxy to PM2 serve
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

    # API proxy
    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Increase timeout for large drawings
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Max body size for drawing uploads
    client_max_body_size 50M;
}
EOF

# Move to nginx sites-available
sudo mv /tmp/excalidraw.parlaymojo.com /etc/nginx/sites-available/excalidraw.parlaymojo.com

# Create symlink to sites-enabled
sudo ln -sf /etc/nginx/sites-available/excalidraw.parlaymojo.com /etc/nginx/sites-enabled/

# Test nginx configuration
sudo nginx -t

# If test passes, reload nginx
if [ $? -eq 0 ]; then
    sudo systemctl reload nginx
    echo "Nginx configuration updated successfully!"
    
    # Test the site
    echo "Testing site..."
    curl -I http://excalidraw.parlaymojo.com
else
    echo "Nginx configuration test failed!"
    exit 1
fi