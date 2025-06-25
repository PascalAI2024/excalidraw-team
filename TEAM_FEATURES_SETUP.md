# Team Features Setup Guide

This guide will help you set up the team features for Excalidraw using Clerk authentication.

## Prerequisites

1. Node.js v18+ installed
2. Yarn package manager
3. A Clerk account (free tier available)

## Step 1: Set up Clerk

1. Sign up for a free account at [https://clerk.com](https://clerk.com)
2. Create a new application
3. Choose your authentication methods (recommended: Email + Google)
4. Copy your **Publishable Key** from the API Keys section (starts with `pk_`)

## Step 2: Configure Environment Variables

Add your Clerk key to `.env.production.local`:

```bash
VITE_CLERK_PUBLISHABLE_KEY=pk_test_your_actual_key_here
```

**Note**: Never commit this file to git. It's already in `.gitignore`.

## Step 3: Deploy with Team Features

Run the deployment script:

```bash
./deploy-team-features.sh
```

This script will:
- Check for Clerk configuration
- Build the application with team features
- Restart the PM2 services
- Verify the deployment

## Step 4: Verify Team Features

1. Visit http://localhost:3000
2. You should see a login button in the UI
3. Click login to test the authentication flow

## Troubleshooting

### Login button not showing?

1. Check browser console for errors
2. Verify Clerk key is correct: `pm2 logs excalidraw-frontend`
3. Make sure the build included your env variables

### Build failing?

1. Clear node_modules: `rm -rf node_modules && yarn install`
2. Check for TypeScript errors: `yarn test:typecheck`
3. Review build logs for specific errors

### PM2 issues?

```bash
# View logs
pm2 logs excalidraw-frontend

# Restart services
pm2 restart excalidraw-frontend excalidraw-backend

# Check status
pm2 status
```

## Features Included

When properly configured, team features include:

- User authentication (email/social)
- Personal cloud storage
- Team sharing capabilities
- Shared drawings management
- User profiles and settings

## Security Notes

- Always use HTTPS in production
- Keep your Clerk Secret Key secure (server-side only)
- Regularly rotate your API keys
- Monitor usage in Clerk dashboard