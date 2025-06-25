#!/bin/bash

# Deployment script for Excalidraw with team features
set -e

echo "🚀 Starting Excalidraw Team Features Deployment..."

# Check if Clerk environment variables are set
CLERK_KEY_FOUND=false

# Check multiple sources for Clerk key
if [ -f ".env.production.local" ] && grep -q "VITE_CLERK_PUBLISHABLE_KEY=pk_" ".env.production.local"; then
    CLERK_KEY_FOUND=true
    echo "✅ Found Clerk key in .env.production.local"
elif [ -f ".env" ] && grep -q "VITE_CLERK_PUBLISHABLE_KEY=pk_" ".env"; then
    CLERK_KEY_FOUND=true
    echo "✅ Found Clerk key in .env"
elif [ -n "$VITE_CLERK_PUBLISHABLE_KEY" ] && [[ "$VITE_CLERK_PUBLISHABLE_KEY" == pk_* ]]; then
    CLERK_KEY_FOUND=true
    echo "✅ Found Clerk key in environment"
fi

if [ "$CLERK_KEY_FOUND" = false ]; then
    echo "⚠️  WARNING: Valid Clerk publishable key not found!"
    echo ""
    echo "To enable team features, you need to:"
    echo "1. Sign up at https://clerk.com"
    echo "2. Create a new application"
    echo "3. Copy your publishable key (starts with 'pk_')"
    echo "4. Add it to .env.production.local:"
    echo "   VITE_CLERK_PUBLISHABLE_KEY=pk_test_YOUR_KEY_HERE"
    echo ""
    read -p "Do you want to continue without team features? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Deployment cancelled. Please set up Clerk first."
        exit 1
    fi
fi

# Step 1: Ensure we're in the right directory
cd /home/pascal/dev/excalidraw
echo "📁 Working directory: $(pwd)"

# Step 2: Clean and install dependencies
echo "📦 Installing dependencies..."
yarn install

# Step 3: Build the project
echo "🔨 Building the project..."
yarn build:app:docker

# Step 4: Check if build was successful
if [ ! -d "excalidraw-app/build" ]; then
    echo "❌ Build failed! Build directory not found."
    exit 1
fi

echo "✅ Build completed successfully!"

# Step 5: Stop the current PM2 processes
echo "🛑 Stopping current PM2 processes..."
pm2 stop excalidraw-frontend excalidraw-backend

# Step 6: Restart PM2 processes
echo "🔄 Restarting PM2 processes..."
pm2 restart excalidraw-frontend
pm2 restart excalidraw-backend

# Step 7: Save PM2 configuration
echo "💾 Saving PM2 configuration..."
pm2 save

# Step 8: Check the status
echo "📊 Current PM2 status:"
pm2 list | grep excalidraw

# Step 9: Test the deployment
echo "🧪 Testing deployment..."
sleep 5  # Give services time to start

# Check if frontend is responding
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|304"; then
    echo "✅ Frontend is responding!"
else
    echo "⚠️  Frontend might not be responding correctly. Check logs with: pm2 logs excalidraw-frontend"
fi

# Check if backend is responding
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3002 | grep -q "200\|404"; then
    echo "✅ Backend is responding!"
else
    echo "⚠️  Backend might not be responding correctly. Check logs with: pm2 logs excalidraw-backend"
fi

echo ""
echo "🎉 Deployment completed!"
echo ""
echo "📝 Next steps:"
echo "1. Make sure VITE_CLERK_PUBLISHABLE_KEY is set in .env.production.local"
echo "2. Visit http://localhost:3000 to verify the login shows up"
echo "3. Check logs with: pm2 logs excalidraw-frontend"
echo ""
echo "💡 Tip: If login doesn't show, check browser console for errors"