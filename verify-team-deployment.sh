#!/bin/bash

echo "🔍 Verifying Excalidraw Team Features Deployment..."
echo "================================================"

# Check frontend
echo ""
echo "📱 Frontend Status:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 | grep -q "200"; then
    echo "✅ Frontend is running at http://localhost:5173"
else
    echo "❌ Frontend is not responding correctly"
fi

# Check backend
echo ""
echo "🔧 Backend Status:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3001 | grep -q "404\|200"; then
    echo "✅ Backend is running at http://localhost:3001"
else
    echo "❌ Backend is not responding correctly"
fi

# Check PM2 processes
echo ""
echo "🚀 PM2 Process Status:"
pm2 list | grep excalidraw

# Check for Clerk configuration
echo ""
echo "🔑 Clerk Configuration:"
if [ -f ".env.production.local" ] && grep -q "VITE_CLERK_PUBLISHABLE_KEY=pk_" ".env.production.local"; then
    echo "✅ Clerk key is configured in .env.production.local"
elif [ -f ".env" ] && grep -q "VITE_CLERK_PUBLISHABLE_KEY=pk_" ".env"; then
    echo "✅ Clerk key is configured in .env"
else
    echo "⚠️  Clerk key not configured - team features won't work"
    echo "   Add your key to .env.production.local"
fi

# Check build directory
echo ""
echo "📦 Build Information:"
if [ -f "excalidraw-app/build/index.html" ]; then
    echo "✅ Build directory exists"
    echo "   Last updated: $(stat -c '%y' excalidraw-app/build/index.html | cut -d' ' -f1,2)"
else
    echo "❌ Build directory not found"
fi

echo ""
echo "================================================"
echo ""
echo "📝 Next Steps:"
echo "1. Visit http://localhost:5173 in your browser"
echo "2. Check for the login button (requires Clerk key)"
echo "3. Monitor logs: pm2 logs excalidraw-frontend"
echo ""
echo "💡 If you don't see the login button:"
echo "   - Add your Clerk key to .env.production.local"
echo "   - Run: ./deploy-team-features.sh"