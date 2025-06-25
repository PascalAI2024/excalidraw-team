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

The database is already configured with the following connection:

```
postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db
```

Tables have been created using Prisma migrations.

### 2. Environment Variables

Create/update `.env.local` in the root directory:

```bash
# Clerk Authentication
VITE_CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key_here
CLERK_SECRET_KEY=your_clerk_secret_key_here

# Database Configuration
DATABASE_URL="postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db"

# App Configuration
VITE_APP_BACKEND_URL=http://localhost:3001
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
2. **Clerk Authentication**: Verify your Clerk keys are properly set in `.env.local`
3. **Port Conflicts**: Backend runs on 3001, frontend on 5173 by default

## Security Notes

- Never commit `.env.local` or `.env` files
- All API endpoints require authentication
- Users can only delete their own drawings
- Sharing requires ownership of the drawing
