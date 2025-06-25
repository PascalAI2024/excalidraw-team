#!/bin/bash

# Excalidraw Team Deployment Setup Script
# Run this on your server to set up the deployment environment

set -e

echo "Setting up Excalidraw Team deployment..."

# Update system
sudo apt update
sudo apt upgrade -y

# Install required packages
sudo apt install -y nginx postgresql postgresql-contrib nodejs npm git

# Install PM2 globally
sudo npm install -g pm2

# Create application directory
sudo mkdir -p /var/www/excalidraw.parlaymojo.com
sudo chown -R $USER:$USER /var/www/excalidraw.parlaymojo.com

# Clone repository
cd /var/www
git clone https://github.com/PascalAI2024/excalidraw-team.git excalidraw.parlaymojo.com
cd excalidraw.parlaymojo.com

# Create environment file
cat > .env.local << 'EOF'
# Clerk Authentication (Replace with your actual keys)
VITE_CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
CLERK_SECRET_KEY=your_clerk_secret_key

# Database Configuration
DATABASE_URL="postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db"

# App Configuration
VITE_APP_BACKEND_URL=https://excalidraw.parlaymojo.com/api
NODE_ENV=production
EOF

# Set up PostgreSQL
sudo -u postgres psql << EOF
CREATE USER devuser WITH PASSWORD 'Ansberga1';
CREATE DATABASE excalidraw_db OWNER devuser;
GRANT ALL PRIVILEGES ON DATABASE excalidraw_db TO devuser;
EOF

# Install dependencies
npm install --legacy-peer-deps
cd server && npm install && cd ..

# Generate Prisma client and run migrations
npx prisma generate
npx prisma migrate deploy

# Build the application
npm run build

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'excalidraw-backend',
      script: './server/src/index.js',
      cwd: '/var/www/excalidraw.parlaymojo.com',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      },
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      time: true
    },
    {
      name: 'excalidraw-frontend',
      script: 'serve',
      args: '-s build -l 5173',
      cwd: '/var/www/excalidraw.parlaymojo.com',
      env: {
        PM2_SERVE_PATH: './build',
        PM2_SERVE_PORT: 5173,
        PM2_SERVE_SPA: 'true',
        NODE_ENV: 'production'
      },
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      time: true
    }
  ]
}
EOF

# Create logs directory
mkdir -p logs

# Start applications with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup

echo "Server setup complete! Next steps:"
echo "1. Update .env.local with your Clerk API keys"
echo "2. Configure nginx (see nginx.conf)"
echo "3. Set up SSL with Let's Encrypt"
echo "4. Configure GitHub secrets for deployment"