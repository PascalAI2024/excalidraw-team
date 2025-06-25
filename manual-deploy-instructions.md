# Manual Deployment Instructions for Excalidraw Team

Since we're having SSH authentication issues, here are the manual steps to deploy Excalidraw to the AgentZero server.

## Step 1: Copy the deployment script to the server

Copy the file `deploy-to-agentzero-v2.sh` to the AgentZero server (92.118.56.108).

You can use SCP or any other method:
```bash
scp -i ~/.ssh/agentzero_key deploy-to-agentzero-v2.sh pascal@92.118.56.108:/home/pascal/
```

## Step 2: SSH into the server

```bash
ssh -i ~/.ssh/agentzero_key pascal@92.118.56.108
```

## Step 3: Run the deployment script

Once logged into the server:
```bash
chmod +x /home/pascal/deploy-to-agentzero-v2.sh
/home/pascal/deploy-to-agentzero-v2.sh
```

## What the script does:

1. **Creates directory**: `/home/pascal/www/excalidraw.parlaymojo.com`
2. **Clones repository**: https://github.com/PascalAI2024/excalidraw-team.git
3. **Sets up environment variables** with the Clerk auth keys from GitHub secrets
4. **Installs dependencies** using yarn
5. **Creates PostgreSQL database**: `excalidraw_db`
6. **Runs database migrations** using Prisma
7. **Builds the server** (TypeScript compilation)
8. **Builds the frontend** (Vite build)
9. **Sets up PM2** to run the backend server
10. **Configures nginx** for excalidraw.parlaymojo.com
11. **Starts everything** and verifies the deployment

## Environment Variables

The script sets up these environment variables:

### Backend (.env):
- DATABASE_URL=postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db
- CLERK_SECRET_KEY=sk_test_N3Hqvn6bMX70FCvNnNLqHGBP7GhP9wEKJbZRYIAzgJ
- PORT=3001
- FRONTEND_URL=http://excalidraw.parlaymojo.com

### Frontend (.env.local):
- VITE_APP_CLERK_PUBLISHABLE_KEY=pk_test_c3VpdGFibGUtbWFyaW4tMTcuY2xlcmsuYWNjb3VudHMuZGV2JA
- VITE_APP_BACKEND_URL=http://excalidraw.parlaymojo.com:3001

## Access URLs

Once deployed:
- Frontend: http://excalidraw.parlaymojo.com
- Backend API: http://excalidraw.parlaymojo.com/api

## Troubleshooting

If you encounter issues:

1. **Check PM2 logs**: `pm2 logs excalidraw-backend`
2. **Check nginx logs**: `sudo tail -f /var/log/nginx/error.log`
3. **Verify database**: `psql -U devuser -d excalidraw_db -c '\dt'`
4. **Test backend directly**: `curl http://localhost:3001/api/health`
5. **Restart services**:
   ```bash
   pm2 restart excalidraw-backend
   sudo systemctl restart nginx
   ```

## Manual Steps (if script fails)

If the automated script fails, you can run these commands manually on the server:

```bash
# 1. Create directory and clone
mkdir -p /home/pascal/www/excalidraw.parlaymojo.com
cd /home/pascal/www/excalidraw.parlaymojo.com
git clone https://github.com/PascalAI2024/excalidraw-team.git
cd excalidraw-team

# 2. Create environment files (copy from script)
# Create server/.env and .env.local with the content from the script

# 3. Install dependencies
yarn install
cd server && yarn install && cd ..

# 4. Setup database
createdb -U devuser -h localhost excalidraw_db
npx prisma generate --schema=./prisma/schema.prisma
npx prisma migrate deploy --schema=./prisma/schema.prisma

# 5. Build
cd server && yarn build && cd ..
yarn build:app

# 6. Start with PM2
pm2 start ecosystem.config.js

# 7. Configure nginx (copy config from script)
sudo nano /etc/nginx/sites-available/excalidraw.parlaymojo.com
sudo ln -sf /etc/nginx/sites-available/excalidraw.parlaymojo.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```