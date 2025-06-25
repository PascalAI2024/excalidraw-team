#\!/bin/bash
cd /home/pascal/www/excalidraw.parlaymojo.com
echo "Updating Clerk keys..."
cat > .env.local << 'ENV'
VITE_CLERK_PUBLISHABLE_KEY=pk_test_YnJhdmUtY2FsZi0zMi5jbGVyay5hY2NvdW50cy5kZXYk
CLERK_SECRET_KEY=sk_test_N3Hqvn6bMX70FCvNnNLqHGBP7GhP9wEKJbZRYIAzgJ
DATABASE_URL="postgresql://ExcalidrawIGD_owner:npg_HrMNjW7qEIe3@ep-wandering-glitter-a8wbr1if-pooler.eastus2.azure.neon.tech/ExcalidrawIGD?sslmode=require&channel_binding=require"
VITE_APP_BACKEND_URL=https://excalidraw.parlaymojo.com/api
NODE_ENV=production
ENV

cat > server/.env << 'ENV'
CLERK_SECRET_KEY=sk_test_N3Hqvn6bMX70FCvNnNLqHGBP7GhP9wEKJbZRYIAzgJ
DATABASE_URL="postgresql://ExcalidrawIGD_owner:npg_HrMNjW7qEIe3@ep-wandering-glitter-a8wbr1if-pooler.eastus2.azure.neon.tech/ExcalidrawIGD?sslmode=require&channel_binding=require"
FRONTEND_URL=https://excalidraw.parlaymojo.com
PORT=3001
ENV

echo "Rebuilding..."
npm run build
pm2 restart excalidraw-backend excalidraw-frontend
echo "Done\!"
