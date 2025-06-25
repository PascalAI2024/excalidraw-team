#!/bin/bash

echo "Testing SSH connectivity to AgentZero server..."
echo ""

# Test different SSH methods
echo "Method 1: Using SSH config (agentzero-prod):"
ssh -o BatchMode=yes -o ConnectTimeout=5 agentzero-prod echo "SUCCESS: Connected using SSH config" 2>&1

echo ""
echo "Method 2: Direct with key file:"
ssh -o BatchMode=yes -o ConnectTimeout=5 -i ~/.ssh/agentzero_key pascal@92.118.56.108 echo "SUCCESS: Connected with key file" 2>&1

echo ""
echo "Method 3: Using id_ed25519:"
ssh -o BatchMode=yes -o ConnectTimeout=5 -i ~/.ssh/id_ed25519 pascal@92.118.56.108 echo "SUCCESS: Connected with ed25519 key" 2>&1

echo ""
echo "Method 4: Using agentzero_production key:"
ssh -o BatchMode=yes -o ConnectTimeout=5 -i ~/.ssh/agentzero_production pascal@92.118.56.108 echo "SUCCESS: Connected with production key" 2>&1

echo ""
echo "If all methods fail, you may need to:"
echo "1. Add your SSH key passphrase to ssh-agent: ssh-add ~/.ssh/agentzero_key"
echo "2. Or manually copy and run the deployment script on the server"