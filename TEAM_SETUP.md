# Team Excalidraw Setup Guide

This is a customized version of Excalidraw with Clerk authentication and PostgreSQL database storage for team collaboration.

## Features

- **Clerk Authentication**: Secure user authentication and management
- **Cloud Storage**: Save and load drawings from PostgreSQL database
- **Team Collaboration**: Share drawings with team members (View/Edit permissions)
- **Shared Drawings**: Access drawings shared with you by teammates
- **Automatic Thumbnails**: Visual preview of saved drawings

## Prerequisites

- Node.js 18.0.0 - 22.x.x
- PostgreSQL database
- Clerk account (for authentication)

## Setup Instructions

### 1. Database Setup

Set up a PostgreSQL database with a connection string in the format:

```
postgresql://username:password@localhost:5432/excalidraw_db
```

Tables will be created automatically using Prisma migrations during setup.

### 2. Environment Variables

For deployment, all environment variables are managed through GitHub secrets. See the "Deployment Configuration" section below for details.

For local development, set the following environment variables in your shell or development environment:

```bash
# Clerk Authentication
export VITE_CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key_here
export CLERK_SECRET_KEY=your_clerk_secret_key_here

# Database Configuration
export DATABASE_URL="postgresql://your_db_user:your_db_password@localhost:5432/excalidraw_db"

# App Configuration
export VITE_APP_BACKEND_URL=http://localhost:3001
```

### 3. Install Dependencies

```bash
# Install root dependencies
npm install

# Install server dependencies
cd server
npm install
cd ..
```

### 4. Start the Application

You'll need two terminal windows:

**Terminal 1 - Backend Server:**

```bash
cd server
npm run dev
```

**Terminal 2 - Frontend App:**

```bash
npm run start
```

The application will open at http://localhost:5173

## Using the Application

### Authentication

1. Sign up or sign in using your email
2. Your profile appears at the top center

### Saving Drawings

1. Create your drawing
2. Click "Save" in the top-right panel
3. Enter a title for your drawing
4. Click "Save" or "Update" if editing existing

### Loading Drawings

1. Click "My Drawings" to see your saved drawings
2. Click on any drawing to load it
3. Thumbnails show a preview of each drawing

### Sharing with Team

1. Save your drawing first
2. Click "Share with Team" (green button, top-left)
3. Enter teammate's email address
4. Choose permission level (View or Edit)
5. Click "Share"

### Accessing Shared Drawings

1. Click "Shared with Me" (bottom-right)
2. See all drawings shared with you
3. Click to open any shared drawing
4. Edit permission allows modifications

## Project Structure

```
excalidraw/
├── excalidraw-app/         # Main application
│   ├── AppWithAuth.tsx     # Main app with authentication
│   ├── ClerkProvider.tsx   # Clerk authentication wrapper
│   └── components/         # Custom components
│       ├── CloudStorage.tsx    # Save/load functionality
│       ├── TeamShare.tsx       # Share drawings
│       └── SharedWithMe.tsx    # View shared drawings
├── server/                 # Backend API
│   └── src/
│       └── index.ts       # Express server with API endpoints
└── prisma/
    └── schema.prisma      # Database schema
```

## API Endpoints

- `GET /api/drawings` - Get user's drawings
- `POST /api/drawings` - Create new drawing
- `PUT /api/drawings/:id` - Update drawing
- `DELETE /api/drawings/:id` - Delete drawing
- `GET /api/drawings/shared` - Get shared drawings
- `POST /api/drawings/:id/share` - Share drawing
- `DELETE /api/drawings/:id/share/:shareId` - Remove share

## Troubleshooting

1. **Database Connection Issues**: Ensure PostgreSQL is running and credentials are correct
2. **Clerk Authentication**: Verify your Clerk keys are properly set in your environment variables
3. **Port Conflicts**: Backend runs on 3001, frontend on 5173 by default

## Security Notes

- Never store environment variables in files
- All API endpoints require authentication
- Users can only delete their own drawings
- Sharing requires ownership of the drawing

## Deployment Configuration

### GitHub Secrets Setup

For deployment, all environment variables are managed through GitHub secrets. Configure the following secrets in your GitHub repository settings:

#### Required GitHub Secrets:

1. **Deployment Connection:**
   - `DEPLOY_HOST` - Your server's IP address or hostname
   - `DEPLOY_USER` - SSH username for deployment
   - `DEPLOY_KEY` - SSH private key for authentication
   - `DEPLOY_PORT` - SSH port (usually 22)

2. **Application Secrets:**
   - `VITE_CLERK_PUBLISHABLE_KEY` - Clerk publishable key
   - `CLERK_SECRET_KEY` - Clerk secret key
   - `DATABASE_URL` - PostgreSQL connection string

3. **Environment URLs:**
   - `VITE_APP_BACKEND_URL` - Backend API URL (e.g., `https://excalidraw.parlaymojo.com/api`)
   - `FRONTEND_URL` - Frontend URL (e.g., `https://excalidraw.parlaymojo.com`)
   - `BACKEND_PORT` - Backend server port (e.g., `3001`)

### Local Development

For local development, DO NOT use GitHub secrets. Instead:

1. Set environment variables in your shell or development environment
2. Use a tool like `direnv` or export variables in your shell profile
3. Never store sensitive credentials in files

### Deployment Process

The deployment workflow (`/.github/workflows/deploy.yml`) automatically:
1. Connects to your server via SSH
2. Pulls the latest code
3. Creates environment files from GitHub secrets
4. Installs dependencies
5. Builds the application
6. Runs database migrations
7. Restarts services with PM2

Environment files are created fresh on each deployment from GitHub secrets, ensuring no sensitive data is stored in the repository.
