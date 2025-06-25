# Auto-Deployment Setup Complete ✅

## What Was Done

1. **Created GitHub Actions Workflow** (`deploy-agentzero.yml`)
   - Triggers on push to `main` or `master` branches
   - Also supports manual triggering via workflow_dispatch
   - Builds the Excalidraw app
   - Deploys to AgentZero server (92.118.56.108)
   - Uses PM2 for process management
   - Includes health check after deployment

2. **Added Concurrency Control**
   - Prevents overlapping deployments
   - Uses deployment group to ensure sequential execution

3. **Created Documentation**
   - `GITHUB_SECRETS_SETUP.md` - Instructions for configuring required secrets

## Next Steps to Enable Auto-Deployment

### 1. Configure GitHub Secrets
Go to https://github.com/PascalAI2024/excalidraw-team/settings/secrets/actions and add:

- **AGENTZERO_SSH_KEY**: Your SSH private key
- **AGENTZERO_HOST**: `92.118.56.108`
- **AGENTZERO_USER**: `pascal`
- **AGENTZERO_DEPLOY_DIR**: `/home/pascal/www/excalidraw.parlaymojo.com`

### 2. Generate SSH Key (if needed)
```bash
# On your local machine
ssh-keygen -t ed25519 -C "github-actions@excalidraw" -f ~/.ssh/github-actions-excalidraw

# Copy the public key to the server
ssh-copy-id -i ~/.ssh/github-actions-excalidraw.pub pascal@92.118.56.108

# Use the private key content for AGENTZERO_SSH_KEY secret
cat ~/.ssh/github-actions-excalidraw
```

### 3. Verify Workflow
1. After adding secrets, push any change to main/master
2. Check Actions tab: https://github.com/PascalAI2024/excalidraw-team/actions
3. Monitor the deployment progress

### 4. Test Manual Deployment
You can also trigger deployment manually:
1. Go to Actions tab
2. Select "Deploy to AgentZero" workflow
3. Click "Run workflow"
4. Select branch and click "Run workflow"

## Deployment Details

- **Build Output**: `excalidraw-app/build/`
- **Server Location**: `/home/pascal/www/excalidraw.parlaymojo.com`
- **Process Manager**: PM2 (process name: `excalidraw-app`)
- **Local Port**: 5001
- **Public URL**: https://excalidraw.parlaymojo.com

## Troubleshooting

If deployment fails:
1. Check GitHub Actions logs
2. SSH to server and check PM2 logs: `pm2 logs excalidraw-app`
3. Verify nginx is configured and running
4. Ensure SSL certificate is valid