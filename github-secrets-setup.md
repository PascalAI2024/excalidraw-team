# GitHub Secrets Setup

The following secrets need to be set in your GitHub repository settings:

## Required Secrets

1. **VITE_CLERK_PUBLISHABLE_KEY**
   ```
   pk_test_YnJhdmUtY2FsZi0zMi5jbGVyay5hY2NvdW50cy5kZXYk
   ```

2. **DATABASE_URL**
   ```
   postgresql://ExcalidrawIGD_owner:npg_HrMNjW7qEIe3@ep-wandering-glitter-a8wbr1if-pooler.eastus2.azure.neon.tech/ExcalidrawIGD?sslmode=require&channel_binding=require
   ```

3. **CLERK_SECRET_KEY**
   - This value needs to be obtained from your Clerk dashboard
   - Not available in the current environment

## How to Set Secrets

If you have admin access to your repository:

```bash
# Set VITE_CLERK_PUBLISHABLE_KEY
gh secret set VITE_CLERK_PUBLISHABLE_KEY --body "pk_test_YnJhdmUtY2FsZi0zMi5jbGVyay5hY2NvdW50cy5kZXYk" -R your-username/your-repo

# Set DATABASE_URL
gh secret set DATABASE_URL --body "postgresql://ExcalidrawIGD_owner:npg_HrMNjW7qEIe3@ep-wandering-glitter-a8wbr1if-pooler.eastus2.azure.neon.tech/ExcalidrawIGD?sslmode=require&channel_binding=require" -R your-username/your-repo

# Set CLERK_SECRET_KEY (replace with your actual secret key)
gh secret set CLERK_SECRET_KEY --body "your-clerk-secret-key" -R your-username/your-repo

# List all secrets to verify
gh secret list -R your-username/your-repo
```

## Alternative: Manual Setup

1. Go to your repository on GitHub
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret with its corresponding value