#!/bin/bash

# Excalidraw deployment script for AgentZero server
# This script will be copied to the server and executed there

set -e

echo "=== Excalidraw Team Deployment Script ==="
echo "Target: excalidraw.parlaymojo.com"
echo "Repository: https://github.com/PascalAI2024/excalidraw-team.git"
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
    git pull origin main || git pull origin master
else
    git clone https://github.com/PascalAI2024/excalidraw-team.git
    cd excalidraw-team
fi

# 3. Set up environment variables
echo "Setting up environment variables..."

# Create .env file for the backend server
cat > server/.env << 'EOF'
# Database
DATABASE_URL=postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db
DIRECT_URL=postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db

# Clerk Auth (from GitHub secrets)
CLERK_SECRET_KEY=sk_test_N3Hqvn6bMX70FCvNnNLqHGBP7GhP9wEKJbZRYIAzgJ

# Server Configuration
PORT=3001
NODE_ENV=production
FRONTEND_URL=http://excalidraw.parlaymojo.com
EOF

# Create .env.local for the frontend
cat > .env.local << 'EOF'
# Clerk Auth (from GitHub secrets)
VITE_APP_CLERK_PUBLISHABLE_KEY=pk_test_c3VpdGFibGUtbWFyaW4tMTcuY2xlcmsuYWNjb3VudHMuZGV2JA

# Backend URL
VITE_APP_BACKEND_URL=http://excalidraw.parlaymojo.com:3001

# Production settings
MODE=production
EOF

# 4. Install dependencies
echo "Installing dependencies..."
# Check if yarn is installed
if ! command -v yarn &> /dev/null; then
    echo "Installing yarn..."
    npm install -g yarn
fi

# Install root dependencies
yarn install

# Install server dependencies
cd server
yarn install
cd ..

# 5. Create database if not exists
echo "Setting up database..."
createdb -U devuser -h localhost excalidraw_db 2>/dev/null || echo "Database already exists"

# Run Prisma migrations
echo "Running database migrations..."
npx prisma generate --schema=./prisma/schema.prisma
npx prisma migrate deploy --schema=./prisma/schema.prisma

# 6. Build the server
echo "Building server..."
cd server
yarn build
cd ..

# 7. Build the frontend application
echo "Building frontend application..."
yarn build:app

# 8. Set up PM2 for backend
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
    script: './server/dist/index.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3001
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
EOF

# Create logs directory
mkdir -p logs

# Stop existing PM2 process if running
pm2 stop excalidraw-backend || true
pm2 delete excalidraw-backend || true

# Start PM2
pm2 start ecosystem.config.js
pm2 save

# 9. Configure nginx for both frontend and backend
echo "Configuring nginx..."
sudo tee /etc/nginx/sites-available/excalidraw.parlaymojo.com << 'EOF'
server {
    listen 80;
    server_name excalidraw.parlaymojo.com;

    # Frontend - serve static files
    location / {
        root /home/pascal/www/excalidraw.parlaymojo.com/excalidraw-team/excalidraw-app/dist;
        try_files $uri $uri/ /index.html;
        
        # Enable gzip compression
        gzip on;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Backend API
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
        
        # Increase body size limit for drawing uploads
        client_max_body_size 50M;
    }

    # WebSocket support for collaboration
    location /socket.io/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Redirect from port 3001 to main domain
server {
    listen 3001;
    server_name excalidraw.parlaymojo.com;
    return 301 http://excalidraw.parlaymojo.com$request_uri;
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/excalidraw.parlaymojo.com /etc/nginx/sites-enabled/

# Test nginx configuration
echo "Testing nginx configuration..."
sudo nginx -t

# Reload nginx
echo "Reloading nginx..."
sudo systemctl reload nginx

# 10. Set up systemd service for PM2 (if not already done)
echo "Setting up PM2 startup..."
pm2 startup systemd -u pascal --hp /home/pascal || true

# 11. Verify deployment
echo ""
echo "=== Deployment Complete ==="
echo ""

# Check PM2 status
echo "PM2 Status:"
pm2 status

# Check nginx status
echo ""
echo "Nginx Status:"
sudo systemctl status nginx --no-pager | head -n 10

# Test backend
echo ""
echo "Testing backend..."
sleep 3
curl -s http://localhost:3001/api/health || echo "Note: Backend may need a health endpoint"

# Display access information
echo ""
echo "=== Access Information ==="
echo "Frontend: http://excalidraw.parlaymojo.com"
echo "Backend API: http://excalidraw.parlaymojo.com/api"
echo ""
echo "To view backend logs:"
echo "  pm2 logs excalidraw-backend"
echo ""
echo "To monitor:"
echo "  pm2 monit"
echo ""
echo "To restart backend:"
echo "  pm2 restart excalidraw-backend"