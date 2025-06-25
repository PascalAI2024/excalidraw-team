#!/bin/bash

# Local deployment script - run this from your local machine to deploy

set -e

# Configuration
SERVER_USER="your_server_user"
SERVER_HOST="your_server_ip"
SERVER_PORT="22"
APP_DIR="/var/www/excalidraw.parlaymojo.com"

echo "🚀 Deploying Excalidraw Team to excalidraw.parlaymojo.com..."

# Function to run commands on server
remote_exec() {
    ssh -p $SERVER_PORT $SERVER_USER@$SERVER_HOST "$1"
}

# Deploy
echo "📦 Pulling latest changes..."
remote_exec "cd $APP_DIR && git pull origin main"

echo "📦 Installing dependencies..."
remote_exec "cd $APP_DIR && npm install --legacy-peer-deps"
remote_exec "cd $APP_DIR/server && npm install"

echo "🔨 Building application..."
remote_exec "cd $APP_DIR && npm run build"

echo "🗄️ Running database migrations..."
remote_exec "cd $APP_DIR && npx prisma generate && npx prisma migrate deploy"

echo "🔄 Restarting services..."
remote_exec "cd $APP_DIR && pm2 restart ecosystem.config.js"

echo "✅ Deployment complete!"
echo "🌐 Visit https://excalidraw.parlaymojo.com"