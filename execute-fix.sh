#!/bin/bash

# Execute the Clerk keys fix on the remote server
echo "Copying fix script to server..."
scp fix-clerk-keys.sh pascal@92.118.56.108:/tmp/

echo ""
echo "Executing fix on server..."
ssh pascal@92.118.56.108 "bash /tmp/fix-clerk-keys.sh"

echo ""
echo "Cleaning up..."
ssh pascal@92.118.56.108 "rm /tmp/fix-clerk-keys.sh"

echo ""
echo "Fix complete! Please visit http://excalidraw.parlaymojo.com to verify the login appears."