# GitHub Secrets Setup for Auto-Deployment

To enable auto-deployment to the AgentZero server, you need to configure the following GitHub secrets in your repository:

## Required Secrets

1. **AGENTZERO_SSH_KEY**
   - Your SSH private key for authentication
   - Generate with: `ssh-keygen -t ed25519 -C "github-actions@excalidraw"`
   - Add the public key to the server's `~/.ssh/authorized_keys`

2. **AGENTZERO_HOST**
   - Value: `92.118.56.108`
   - The IP address of the AgentZero server

3. **AGENTZERO_USER**
   - Value: `pascal`
   - The username for SSH connection

4. **AGENTZERO_DEPLOY_DIR**
   - Value: `/home/pascal/www/excalidraw.parlaymojo.com`
   - The deployment directory on the server

## How to Add Secrets

1. Go to your GitHub repository
2. Click on "Settings" tab
3. Navigate to "Secrets and variables" → "Actions"
4. Click "New repository secret"
5. Add each secret with the name and value specified above

## Workflow Triggers

The deployment workflow will trigger:
- On every push to `main` or `master` branch
- Manually via GitHub Actions UI (workflow_dispatch)

## Verification

After setting up the secrets:
1. Push to main/master branch or manually trigger the workflow
2. Check the Actions tab in GitHub to monitor the deployment
3. Visit https://excalidraw.parlaymojo.com to verify the deployment