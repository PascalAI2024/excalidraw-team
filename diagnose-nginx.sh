#!/bin/bash

# Diagnostic script for nginx and excalidraw setup
# Can be run without sudo for most checks

echo "=== Excalidraw Nginx Diagnostics ==="
echo
echo "Date: $(date)"
echo "Server: $(hostname)"
echo

echo "1. DNS Check:"
echo -n "   excalidraw.parlaymojo.com resolves to: "
dig excalidraw.parlaymojo.com +short || echo "DNS lookup failed"
echo -n "   Current server IP: "
curl -s ifconfig.me || hostname -I | awk '{print $1}'
echo

echo "2. Service Status:"
echo -n "   Nginx: "
systemctl is-active nginx 2>/dev/null || echo "Cannot check (need sudo)"
echo -n "   Vite dev server (5173): "
curl -s -o /dev/null -w "Running (%{http_code})\n" http://localhost:5173 || echo "Not running"
echo -n "   API server (3001): "
curl -s -o /dev/null -w "Running (%{http_code})\n" http://localhost:3001 || echo "Not running"
echo

echo "3. Port Listeners:"
echo "   Checking ports 80, 443, 3001, 5173:"
ss -tlnp 2>/dev/null | grep -E "(:(80|443|3001|5173)\s)" | awk '{print "   " $4 " - " $6}' || \
netstat -tlnp 2>/dev/null | grep -E "(:(80|443|3001|5173)\s)" | awk '{print "   " $4}' || \
echo "   (Need sudo for process details)"
echo

echo "4. PM2 Status:"
pm2 list 2>/dev/null | grep excalidraw || echo "   No excalidraw processes in PM2"
echo

echo "5. HTTP Response Tests:"
echo -n "   http://excalidraw.parlaymojo.com: "
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://excalidraw.parlaymojo.com)
echo "Status $HTTP_STATUS"

echo -n "   https://excalidraw.parlaymojo.com: "
HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -m 5 https://excalidraw.parlaymojo.com)
echo "Status $HTTPS_STATUS"
echo

echo "6. Project Structure:"
echo -n "   Current directory: "
pwd
echo -n "   Build exists: "
[ -d "excalidraw-app/build" ] && echo "Yes" || echo "No"
echo -n "   Deployment directory exists: "
[ -d "/var/www/excalidraw.parlaymojo.com" ] && echo "Yes" || echo "No (or no permission)"
echo

echo "7. Available nginx configs in project:"
find . -name "*.conf" -path "*/nginx*" -o -name "nginx.conf" 2>/dev/null | head -5
echo

echo "8. Recent nginx logs (if accessible):"
if [ -r /var/log/nginx/error.log ]; then
    echo "   Last 3 error entries:"
    tail -3 /var/log/nginx/error.log | sed 's/^/   /'
else
    echo "   Cannot read nginx logs (need sudo)"
fi
echo

echo "=== Recommendations ==="
if [ "$HTTP_STATUS" != "200" ] && [ "$HTTPS_STATUS" != "200" ]; then
    echo "❌ Site is not accessible. Run: sudo ./setup-nginx.sh"
elif ! [ -d "excalidraw-app/build" ]; then
    echo "⚠️  No build directory found. Run: yarn build"
elif curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 | grep -q "200"; then
    echo "✓ Dev server is running. You can use the development proxy setup."
else
    echo "ℹ️  To start dev server: yarn dev"
fi

echo
echo "For detailed nginx configuration check, run:"
echo "  sudo nginx -T | grep -A 20 excalidraw.parlaymojo.com"