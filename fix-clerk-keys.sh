#!/bin/bash

# Fix Clerk keys in deployed Excalidraw app
set -e

echo "=== Fixing Clerk Keys for Excalidraw ==="
echo ""

# Navigate to deployment directory
cd /home/pascal/www/excalidraw.parlaymojo.com/excalidraw-team

# Update .env.local with correct Clerk publishable key
echo "Updating frontend .env.local..."
cat > .env.local << 'EOF'
# Clerk Auth (corrected key)
VITE_CLERK_PUBLISHABLE_KEY=pk_test_YnJhdmUtY2FsZi0zMi5jbGVyay5hY2NvdW50cy5kZXYk

# Backend URL
VITE_APP_BACKEND_URL=http://excalidraw.parlaymojo.com:3001

# Production settings
MODE=production
EOF

# Update server/.env with correct Clerk secret key
echo "Updating backend server/.env..."
cat > server/.env << 'EOF'
# Database
DATABASE_URL=postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db
DIRECT_URL=postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db

# Clerk Auth (corrected key)
CLERK_SECRET_KEY=sk_test_N3Hqvn6bMX70FCvNnNLqHGBP7GhP9wEKJbZRYIAzgJ

# Server Configuration
PORT=3001
NODE_ENV=production
FRONTEND_URL=http://excalidraw.parlaymojo.com
EOF

# Rebuild the application
echo ""
echo "Rebuilding frontend application..."
yarn build:app

# Restart PM2 backend service
echo ""
echo "Restarting backend service..."
pm2 restart excalidraw-backend

# Wait for services to start
echo ""
echo "Waiting for services to start..."
sleep 5

# Verify the changes
echo ""
echo "=== Verification ==="
echo ""

# Check if backend is running
echo "Backend status:"
pm2 status excalidraw-backend

# Test the application
echo ""
echo "Testing application..."
curl -I http://excalidraw.parlaymojo.com 2>/dev/null | head -n 1

echo ""
echo "=== Clerk Keys Fixed ==="
echo "Frontend: http://excalidraw.parlaymojo.com"
echo ""
echo "The login should now appear. Please visit the site to verify."
echo ""
echo "If you need to check logs:"
echo "  Backend logs: pm2 logs excalidraw-backend"
echo "  Frontend: Check browser console for any errors"