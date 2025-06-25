# Deployment Secrets Configuration

This document outlines how to configure GitHub secrets for automated deployment.

## Prerequisites

1. A GitHub repository with admin access
2. A deployment server with SSH access
3. PostgreSQL database
4. Clerk account

## Setting Up GitHub Secrets

Navigate to your GitHub repository → Settings → Secrets and variables → Actions

### 1. SSH Deployment Secrets

These secrets are used by GitHub Actions to connect to your deployment server:

- **DEPLOY_HOST**: Your server's IP address or hostname
  - Example: `192.168.1.100` or `excalidraw.example.com`
  
- **DEPLOY_USER**: SSH username for deployment
  - Example: `deploy` or `ubuntu`
  
- **DEPLOY_KEY**: SSH private key for authentication
  - Generate with: `ssh-keygen -t rsa -b 4096`
  - Copy the entire private key including headers
  
- **DEPLOY_PORT**: SSH port
  - Default: `22`

### 2. Application Secrets

These secrets configure your application:

- **VITE_CLERK_PUBLISHABLE_KEY**: Clerk publishable key
  - Found in Clerk Dashboard → API Keys
  - Format: `pk_test_...` or `pk_live_...`
  
- **CLERK_SECRET_KEY**: Clerk secret key
  - Found in Clerk Dashboard → API Keys
  - Format: `sk_test_...` or `sk_live_...`
  
- **DATABASE_URL**: PostgreSQL connection string
  - Format: `postgresql://username:password@host:port/database`
  - Example: `postgresql://appuser:securepass@localhost:5432/excalidraw_prod`

### 3. Environment URLs

Configure these based on your deployment:

- **VITE_APP_BACKEND_URL**: Backend API URL
  - Example: `https://excalidraw.example.com/api`
  
- **FRONTEND_URL**: Frontend application URL
  - Example: `https://excalidraw.example.com`
  
- **BACKEND_PORT**: Backend server port
  - Example: `3001`

## Security Best Practices

1. **Never commit secrets**: All sensitive data should be in GitHub secrets
2. **Use strong passwords**: Generate secure database passwords
3. **Rotate keys regularly**: Update SSH keys and API keys periodically
4. **Limit access**: Only give repository access to trusted team members
5. **Use production keys**: Switch from test to production Clerk keys for live deployments

## Verifying Secrets

After setting up secrets, trigger a deployment to verify:

1. Go to Actions tab in GitHub
2. Select "Deploy to excalidraw.parlaymojo.com" workflow
3. Click "Run workflow"
4. Monitor the logs for any errors

## Troubleshooting

### SSH Connection Failed
- Verify DEPLOY_HOST is correct
- Check DEPLOY_KEY format (include full key with headers)
- Ensure the public key is added to server's `~/.ssh/authorized_keys`

### Database Connection Failed
- Check DATABASE_URL format
- Verify database server is accessible from deployment server
- Ensure database user has correct permissions

### Build Failures
- Check all VITE_ prefixed variables are set
- Verify Clerk keys are valid
- Review deployment logs for specific errors