# Excalidraw Database Setup

This document explains how to set up PostgreSQL for the Excalidraw application.

## Prerequisites

- PostgreSQL installed and running
- Node.js and npm installed
- Sudo access (for initial database setup)

## Quick Setup

1. **Run the PostgreSQL setup script** (requires sudo):
   ```bash
   sudo bash setup-postgres.sh
   ```
   This will:
   - Create the `devuser` with password `Ansberga1`
   - Create the `excalidraw_db` database
   - Grant all privileges to devuser

2. **Verify and run migrations**:
   ```bash
   bash setup-and-verify-db.sh
   ```
   This will:
   - Verify PostgreSQL is running
   - Check database connectivity
   - Generate Prisma Client
   - Run all pending migrations
   - Verify all tables are created

## Database Schema

The database includes three main tables:

- **User**: Stores user information (integrated with Clerk auth)
- **Drawing**: Stores Excalidraw drawings with JSON content
- **Share**: Manages drawing sharing between users with permissions

## Connection Details

- **Host**: localhost
- **Port**: 5432
- **Database**: excalidraw_db
- **User**: devuser
- **Password**: Ansberga1
- **Connection String**: `postgresql://devuser:Ansberga1@localhost:5432/excalidraw_db`

## Manual Commands

If you prefer to run commands manually:

```bash
# Generate Prisma Client
npx prisma generate

# Run migrations
npx prisma migrate deploy

# Check migration status
npx prisma migrate status

# Open Prisma Studio (GUI for database)
npx prisma studio
```

## Troubleshooting

If you encounter connection issues:

1. Ensure PostgreSQL is running:
   ```bash
   sudo systemctl status postgresql
   ```

2. Check PostgreSQL logs:
   ```bash
   sudo journalctl -u postgresql -n 50
   ```

3. Verify the database exists:
   ```bash
   PGPASSWORD=Ansberga1 psql -h localhost -U devuser -d excalidraw_db -c "\dt"
   ```

4. Reset the database (if needed):
   ```bash
   npx prisma migrate reset
   ```