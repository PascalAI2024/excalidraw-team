# Excalidraw Team - Collaborative Drawing Tool

This is a team collaboration version of [Excalidraw](https://excalidraw.com) with added features for teams:

## 🚀 Features

- **Authentication**: Secure user authentication with Clerk
- **Cloud Storage**: Save and load drawings from PostgreSQL database
- **Team Collaboration**: Share drawings with team members (View/Edit permissions)
- **Real-time Updates**: See changes from team members
- **Drawing Management**: Organize and manage your drawings with thumbnails

## 📋 Prerequisites

- Node.js 18.0.0 - 22.x.x
- PostgreSQL database
- Clerk account (free tier available at [clerk.com](https://clerk.com))

## 🛠️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/PascalAI2024/excalidraw-team.git
cd excalidraw-team
```

### 2. Install Dependencies

```bash
# Install root dependencies
npm install

# Install server dependencies
cd server
npm install
cd ..
```

### 3. Database Setup

Create a PostgreSQL database and run migrations:

```bash
# Create database (if not exists)
createdb excalidraw_db

# Run Prisma migrations
cd server
npx prisma migrate deploy
cd ..
```

### 4. Environment Variables

Create `.env.local` in the root directory:

```env
# Clerk Authentication
VITE_CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
CLERK_SECRET_KEY=your_clerk_secret_key

# Database Configuration
DATABASE_URL="postgresql://username:password@localhost:5432/excalidraw_db"

# App Configuration
VITE_APP_BACKEND_URL=http://localhost:3001
```

### 5. Start the Application

Run both backend and frontend:

```bash
# Option 1: Use the start script
chmod +x start-app.sh
./start-app.sh

# Option 2: Run manually in separate terminals
# Terminal 1:
cd server && npm run dev

# Terminal 2:
npm run start
```

## 📱 Usage

1. **Sign Up/In**: Create an account or sign in
2. **Create**: Draw using Excalidraw's tools
3. **Save**: Click "Save" to store your drawing
4. **Share**: Click "Share with Team" to share with teammates
5. **Collaborate**: Team members can view or edit shared drawings

## 🏗️ Architecture

- **Frontend**: React + Excalidraw library + Clerk authentication
- **Backend**: Express.js API server
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: Clerk for user management

## 🔒 Security

- All API endpoints require authentication
- User data isolation (users can only access their own drawings)
- Secure sharing with permission levels

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project extends Excalidraw which is MIT licensed. See the original [Excalidraw license](https://github.com/excalidraw/excalidraw/blob/master/LICENSE).

## 🙏 Acknowledgments

- [Excalidraw](https://github.com/excalidraw/excalidraw) - The amazing open-source drawing tool
- [Clerk](https://clerk.com) - Authentication and user management
- [Prisma](https://www.prisma.io) - Database ORM