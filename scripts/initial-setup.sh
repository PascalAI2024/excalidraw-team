#!/bin/bash

# Initial setup script for excalidraw.parlaymojo.com

echo "Setting up Excalidraw deployment..."

# Create directory
mkdir -p /home/pascal/www/excalidraw.parlaymojo.com
cd /home/pascal/www/excalidraw.parlaymojo.com

# Clone repository
if [ ! -d ".git" ]; then
    git clone https://github.com/PascalAI2024/excalidraw-team.git .
else
    git pull origin main
fi

# Create environment files from secrets (these will be replaced by GitHub Actions)
cat > .env.local << 'EOF'
VITE_CLERK_PUBLISHABLE_KEY=pk_test_YnJhdmUtY2FsZi0zMi5jbGVyay5hY2NvdW50cy5kZXYk
CLERK_SECRET_KEY=placeholder_will_be_replaced
DATABASE_URL="postgresql://ExcalidrawIGD_owner:npg_HrMNjW7qEIe3@ep-wandering-glitter-a8wbr1if-pooler.eastus2.azure.neon.tech/ExcalidrawIGD?sslmode=require&channel_binding=require"
VITE_APP_BACKEND_URL=https://excalidraw.parlaymojo.com/api
NODE_ENV=production
EOF

# Create server env
mkdir -p server
cat > server/.env << 'EOF'
DATABASE_URL="postgresql://ExcalidrawIGD_owner:npg_HrMNjW7qEIe3@ep-wandering-glitter-a8wbr1if-pooler.eastus2.azure.neon.tech/ExcalidrawIGD?sslmode=require&channel_binding=require"
FRONTEND_URL=https://excalidraw.parlaymojo.com
PORT=3001
EOF

# Install dependencies
echo "Installing dependencies..."
npm install --legacy-peer-deps

# Build
echo "Building application..."
npm run build

# Install server dependencies
cd server
npm install

# Install PM2 locally if not available globally
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    cd /home/pascal/www/excalidraw.parlaymojo.com
    npm install pm2
    export PATH=$PATH:./node_modules/.bin
fi

# Generate Prisma client
cd /home/pascal/www/excalidraw.parlaymojo.com
npx prisma generate

echo "Initial setup complete!"
echo "Next steps:"
echo "1. Update the deployment workflow to use /home/pascal/www/excalidraw.parlaymojo.com"
echo "2. Configure nginx manually"
echo "3. Start the application with PM2"