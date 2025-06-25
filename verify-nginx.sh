#!/bin/bash

echo "Verifying Excalidraw nginx setup..."
echo "=================================="

# Check DNS resolution
echo -n "DNS Resolution: "
if host excalidraw.parlaymojo.com > /dev/null 2>&1; then
    echo "✓ OK ($(host excalidraw.parlaymojo.com | grep "has address" | awk '{print $4}'))"
else
    echo "✗ FAILED"
fi

# Check HTTP response
echo -n "HTTP Response: "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://excalidraw.parlaymojo.com)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "502" ]; then
    echo "✓ Server responding (HTTP $HTTP_CODE)"
    if [ "$HTTP_CODE" = "502" ]; then
        echo "  ⚠ 502 Bad Gateway - Backend services may not be running"
    fi
else
    echo "✗ FAILED (HTTP $HTTP_CODE)"
fi

# Check if nginx config exists on server
echo -n "Nginx Config: "
ssh -i ~/.ssh/excalidraw_deploy_key pascal@92.118.56.108 "test -f /etc/nginx/sites-enabled/excalidraw.parlaymojo.com && echo '✓ Enabled' || echo '✗ Not found'"

# Check backend services
echo -e "\nBackend Services:"
echo "=================="
ssh -i ~/.ssh/excalidraw_deploy_key pascal@92.118.56.108 "
echo -n 'Frontend (5173): '
netstat -tln 2>/dev/null | grep :5173 > /dev/null && echo '✓ Listening' || echo '✗ Not listening'
echo -n 'API (3001): '
netstat -tln 2>/dev/null | grep :3001 > /dev/null && echo '✓ Listening' || echo '✗ Not listening'
"

echo -e "\nFull site test:"
echo "==============="
curl -sI http://excalidraw.parlaymojo.com | head -5