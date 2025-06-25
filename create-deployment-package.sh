#!/bin/bash

# Create a deployment package for Excalidraw
echo "Creating deployment package..."

# Create temporary directory
PACKAGE_DIR="/tmp/excalidraw-deployment-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$PACKAGE_DIR"

# Copy deployment script
cp deploy-to-agentzero-v2.sh "$PACKAGE_DIR/"

# Create a README for the package
cat > "$PACKAGE_DIR/README.md" << 'EOF'
# Excalidraw Team Deployment Package

This package contains everything needed to deploy Excalidraw to the AgentZero server.

## Quick Start

1. Transfer this package to the server:
   ```
   scp -r excalidraw-deployment-* pascal@92.118.56.108:/home/pascal/
   ```

2. SSH into the server and run:
   ```
   cd /home/pascal/excalidraw-deployment-*
   chmod +x deploy-to-agentzero-v2.sh
   ./deploy-to-agentzero-v2.sh
   ```

## What Gets Deployed

- Frontend: Excalidraw app at http://excalidraw.parlaymojo.com
- Backend: API server at http://excalidraw.parlaymojo.com/api
- Database: PostgreSQL database `excalidraw_db`

## Environment Variables

The deployment script will set up all necessary environment variables including:
- Clerk authentication keys
- Database connection strings
- Server ports and URLs

## Post-Deployment

After deployment, you can:
- View logs: `pm2 logs excalidraw-backend`
- Monitor: `pm2 monit`
- Restart: `pm2 restart excalidraw-backend`
EOF

# Create a simple verification script
cat > "$PACKAGE_DIR/verify-deployment.sh" << 'EOF'
#!/bin/bash

echo "=== Excalidraw Deployment Verification ==="
echo ""

# Check if PM2 process is running
echo "Checking PM2 process..."
pm2 status | grep excalidraw-backend

# Check if nginx config exists
echo ""
echo "Checking nginx configuration..."
if [ -f /etc/nginx/sites-enabled/excalidraw.parlaymojo.com ]; then
    echo "✓ Nginx config exists"
else
    echo "✗ Nginx config not found"
fi

# Test backend
echo ""
echo "Testing backend..."
curl -s -o /dev/null -w "Backend HTTP Status: %{http_code}\n" http://localhost:3001/

# Test frontend
echo ""
echo "Testing frontend..."
curl -s -o /dev/null -w "Frontend HTTP Status: %{http_code}\n" http://localhost/

# Check database
echo ""
echo "Checking database..."
psql -U devuser -d excalidraw_db -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null || echo "Database check failed"

echo ""
echo "Deployment URL: http://excalidraw.parlaymojo.com"
EOF

chmod +x "$PACKAGE_DIR/verify-deployment.sh"

# Create archive
cd /tmp
tar -czf "excalidraw-deployment-$(date +%Y%m%d-%H%M%S).tar.gz" "excalidraw-deployment-$(date +%Y%m%d-%H%M%S)"

echo ""
echo "Deployment package created: /tmp/excalidraw-deployment-$(date +%Y%m%d-%H%M%S).tar.gz"
echo ""
echo "To deploy:"
echo "1. Transfer the package to the server"
echo "2. Extract: tar -xzf excalidraw-deployment-*.tar.gz"
echo "3. Run: ./excalidraw-deployment-*/deploy-to-agentzero-v2.sh"