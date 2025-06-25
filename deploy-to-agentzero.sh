#!/bin/bash

# Excalidraw deployment script for AgentZero server

set -e

echo "=== Excalidraw Deployment Script ==="
echo "Target: excalidraw.parlaymojo.com"
echo ""

# 1. Create directory structure
echo "Creating directory structure..."
mkdir -p /home/pascal/www/excalidraw.parlaymojo.com
cd /home/pascal/www/excalidraw.parlaymojo.com

# 2. Clone repository
echo "Cloning repository..."
if [ -d "excalidraw-team" ]; then
    echo "Repository exists, pulling latest changes..."
    cd excalidraw-team
    git pull origin main
else
    git clone https://github.com/PascalAI2024/excalidraw-team.git
    cd excalidraw-team
fi

# 3. Set up environment variables
echo "Setting up environment variables..."
cat > .env << 'EOF'
# Database
DATABASE_URL=postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db
DIRECT_URL=postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db

# Clerk Auth (from GitHub secrets)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_c3VpdGFibGUtbWFyaW4tMTcuY2xlcmsuYWNjb3VudHMuZGV2JA
CLERK_SECRET_KEY=sk_test_N3Hqvn6bMX70FCvNnNLqHGBP7GhP9wEKJbZRYIAzgJ

# Server Configuration
PORT=5432
NODE_ENV=production
EOF

# 4. Install dependencies
echo "Installing dependencies..."
# Check if yarn is installed
if ! command -v yarn &> /dev/null; then
    echo "Installing yarn..."
    npm install -g yarn
fi

yarn install

# 5. Create database if not exists
echo "Setting up database..."
psql -U devuser -h localhost -c "CREATE DATABASE excalidraw_db;" || echo "Database already exists"

# 6. Build the application
echo "Building application..."
yarn build

# 7. Set up PM2 for backend
echo "Setting up PM2..."
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    npm install -g pm2
fi

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'excalidraw-backend',
    script: './server/index.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 5432,
      DATABASE_URL: 'postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db'
    }
  }]
};
EOF

# Stop existing PM2 process if running
pm2 stop excalidraw-backend || true
pm2 delete excalidraw-backend || true

# Start PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup || true

# 8. Configure nginx
echo "Configuring nginx..."
sudo tee /etc/nginx/sites-available/excalidraw.parlaymojo.com << 'EOF'
server {
    listen 80;
    server_name excalidraw.parlaymojo.com;

    location / {
        proxy_pass http://localhost:5432;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api {
        proxy_pass http://localhost:5432;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # WebSocket support
    location /socket.io/ {
        proxy_pass http://localhost:5432;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/excalidraw.parlaymojo.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# 9. Verify deployment
echo ""
echo "=== Deployment Complete ==="
echo "Checking services..."
echo ""

# Check PM2
echo "PM2 Status:"
pm2 status

# Check nginx
echo ""
echo "Nginx Status:"
sudo systemctl status nginx --no-pager

# Check if site is accessible
echo ""
echo "Testing site availability..."
curl -I http://localhost:5432 || echo "Backend not responding yet, may need a moment to start"

echo ""
echo "Deployment complete! The application should be available at:"
echo "http://excalidraw.parlaymojo.com"
echo ""
echo "To view logs:"
echo "  pm2 logs excalidraw-backend"
echo ""
echo "To monitor:"
echo "  pm2 monit"